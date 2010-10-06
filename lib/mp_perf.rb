require 'rubygems'
require 'ruby-debug'
require 'optparse'
require 'ruport'
require 'lib/httperf'

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

  #
  # Taken from http://github.com/igrigorik/autoperf
  #
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

  #
  #  Runs a single benchmark (this method will be called many times
  #  with different concurrency levels)
  #
  def single_benchmark(conf)
   
    # Run httperf 
    res = Httperf.run(conf)


    return res
  end

  def run
    results = {}
    # report = Table(:column_names => ['rate',             'requests',        'duration',         'replies', 'conn/s',
    #                                  'ms/connection',    'concurrent conns max', 
    #                                  'conn time min',    'conn time avg',   'conn time max', 
    #                                  'conn time median', 'conn time stddev','req/s', 
    #                                  'replies/s min',    'replies/s avg',   'replies/s max', 
    #                                  'status 1xx',       'status 1xx/s',    'status 2xx',       'status 2xx/s',
    #                                  'status 3xx',       'status 3xx/s',    'status 4xx',       'status 4xx/s', 
    #                                  'status 5xx',       'status 5xx/s',    'replies/s stddev', 'reply time', 
    #                                  'net io (KB/s)',    'errors'])
    report = nil
    (@conf['low_rate']..@conf['high_rate']).step(@conf['rate_step']) do |rate|

      # Run httperf
      results[rate] = single_benchmark(@conf.merge({'httperf_rate' => rate}))

      # Show that we're alive 
      puts "#{results[rate].delete('output')}\n"
      puts "~"*80

      # Init table unless it has been 
      report ||= Table(:column_names => ['rate'] + results[rate].keys.sort)

      # Save results of this run
      report << results[rate].merge({'rate' => rate})

      # Try to keep old pending requests from influencing the next round
      sleep(10)
    end

    # Write csv
    File.new(@output_file, "w").puts report.to_csv
  end
end



