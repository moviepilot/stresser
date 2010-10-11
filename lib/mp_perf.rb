require 'optparse'
require 'ruport'
require 'httperf'

class MPPerf

  def initialize(opts = {})
    @conf = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: autoperf.rb -c your.conf -o output.csv"
      opts.on("-o", "--output FILE", String, "This file will be overwritten with a detailed report of the stresstest") do |v|
        @output_file = v
      end
      opts.on( "-c", "--config FILE", String, "Your strexser configuration file with stresstest options and parameters directly passed to httperf") do |v|
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
    report = nil
    (@conf['low_rate']..@conf['high_rate']).step(@conf['rate_step']) do |rate|

      # Run httperf
      results[rate] = single_benchmark(@conf.merge({'httperf_rate' => rate}))

      # Show that we're alive 
      puts "#{results[rate].delete('output')}\n"
      puts "~"*80

      # Init table unless it's there already
      report ||= Table(:column_names => ['rate'] + results[rate].keys.sort)

      # Save results of this run
      report << results[rate].merge({'rate' => rate})

      # Try to keep old pending requests from influencing the next round
      sleep(@conf['sleep_time'] || 0)
    end

    # Write csv
    File.new(@output_file, "w").puts report.to_csv unless report.nil?
  end
end



