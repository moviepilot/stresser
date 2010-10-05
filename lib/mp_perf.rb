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
    res = Hash.new("")
    IO.popen("#{httperf_cmd} 2>&1") do |pipe|
        puts "\n#{httperf_cmd}"

      # Parse hhtperf output
      while((line = pipe.gets))
        #puts "#{line}\n"
        res['output'] += line

        case line
        when /^Total: connections (\d+) requests (\d+) replies (\d+) test-duration (\d+\.\d+) s/ then
          res['conns']    = $1
          res['requests'] = $2
          res['replies']  = $3
          res['duration'] = $4
        when /^Connection rate: (\d+\.\d)[^\d]+(\d+\.\d)[^\d]+(\d+)[^\d]/ then 
          res['conn/s']               = $1
          res['ms/connection']        = $2
          res['concurrent conns max'] = $3
        when /^Connection time .*min (\d+\.\d) avg (\d+\.\d) max (\d+\.\d) median (\d+\.\d) stddev (\d+\.\d)/ then
          res['conn time min']    = $1
          res['conn time avg']    = $2
          res['conn time max']    = $3
          res['conn time median'] = $4
          res['conn time stddev'] = $5
        when /^Request rate: (\d+\.\d)/ then res['req/s'] = $1
        when /^Reply rate .*min (\d+\.\d) avg (\d+\.\d) max (\d+\.\d) stddev (\d+\.\d)/ then
          res['replies/s min'] = $1
          res['replies/s avg'] = $2
          res['replies/s max'] = $3
          res['replies/s stddev'] = $4
        when /^Reply time .* response (\d+\.\d)/ then res['reply time'] = $1
        when /^Reply status.+ 1xx=(\d+) 2xx=(\d+) 3xx=(\d+) 4xx=(\d+) 5xx=(\d+)/ then
          res['status 1xx'] = $1 
          res['status 2xx'] = $2
          res['status 3xx'] = $3 
          res['status 4xx'] = $4
          res['status 5xx'] = $5 
        when /^Net I\/O: (\d+\.\d)/ then res['net io (KB/s)'] = $1
        when /^Errors: total (\d+)/ then res['errors'] = $1
        end
      end

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

