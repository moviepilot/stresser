require 'rubygems'
require 'optparse'
require 'ruport'

class MPPerf

  def initialize(opts = {})
    @conf = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: autoperf.rb [-c config]"
      opts.on("-o", "--output [string]", String, "csv output file") do |v|
        @output_file = v
      end
      opts.on("-c", "--config [string]", String, "configuration file") do |v|
        @conf = parse_config(v)
      end
    end.parse!

    run()
  end

  def parse_config(config_file)
    raise Errno::EACCES, "#{config_file} is not readable" unless File.readable?(config_file)

    conf = {}
    open(config_file).each { |line|
      line.chomp
      unless (/^\#/.match(line))
        if(/\s*=\s*/.match(line))
          param, value = line.split(/\s*=\s*/, 2)
          var_name = "#{param}".chomp.strip
          value = value.chomp.strip
          new_value = ''
          if (value)
            if value =~ /^['"](.*)['"]$/
              new_value = $1
            else
              new_value = value
            end
          else
            new_value = ''
          end
          conf[var_name] = new_value =~ /^\d+$/ ? new_value.to_i : new_value
        end
      end
    }

    return conf
  end

  def benchmark(conf)
    httperf_opt = conf.keys.grep(/httperf/).collect {|k| "--#{k.gsub(/httperf_/, '')}=#{conf[k]}"}.join(" ")
    httperf_cmd = "httperf --hog --server=#{conf['host']} --port=#{conf['port']} #{httperf_opt}"
    IO.popen("#{httperf_cmd} 2>&1") do |pipe|
        puts "\n#{httperf_cmd}"
        res = Httperf.parse_output(pipe)

      # Now calculate the amount of stati per second
      (1..5).each do |i|
        begin
          res["status #{i}xx/s"] =  res["status #{i}xx"].to_i / res["duration"].to_i
        rescue
          res["status #{i}xx/s"] = -1
        end
      end

      # Try to keep old pending requests from influencing the next round
      sleeptime = 60
      puts "Sleeping #{sleeptime} seconds..."
      sleep(sleeptime)
      puts "Woke up!"
    end
    return res
  end

  def run
    results = {}
    report = Table(:column_names => ['rate',             'requests',        'duration',         'replies', 'conn/s',
                                     'ms/connection',    'concurrent conns max', 
                                     'conn time min',    'conn time avg',   'conn time max', 
                                     'conn time median', 'conn time stddev','req/s', 
                                     'replies/s min',    'replies/s avg',   'replies/s max', 
                                     'status 1xx',       'status 1xx/s',    'status 2xx',       'status 2xx/s',
                                     'status 3xx',       'status 3xx/s',    'status 4xx',       'status 4xx/s', 
                                     'status 5xx',       'status 5xx/s',    'replies/s stddev', 'reply time', 
                                     'net io (KB/s)',    'errors'])

    (@conf['low_rate']..@conf['high_rate']).step(@conf['rate_step']) do |rate|
      results[rate] = benchmark(@conf.merge({'httperf_rate' => rate}))
      report << results[rate].merge({'rate' => rate})
      
      puts results[rate]['output']
    end
    File.new(@output_file, "w").puts report.to_csv
  end
end

# trap("INT") {
#   puts "Terminating tests."
#   Process.exit
# }

