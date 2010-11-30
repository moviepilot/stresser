require 'optparse'
require 'ruport'
require 'httperf'
require 'trollop'


#
#  Takes command line options and attempts to make a benchmark.
#
class MPPerf

  def initialize(opts = {})
    parse_options
    parse_config
    run_suite
    display_hints
  end

  #
  # Parse command line options
  #
  def parse_options
    @conf = Trollop::options do
      banner = MPPerf.options_banner
      opt :output_file, "The name of the csv file to write the results to. Warning: overwrites that file!",
                        :type => String
      opt :config_file, "The name of the .conf file defining your testsuite. See http://github.com/moviepilot/stresser",
                        :type => String
    end

    Trollop::die :output_file, "must be a writeable file" unless @conf[:config_file]
    Trollop::die :config_file, "must be a readable file"  unless @conf[:config_file]
  end

  #
  # Taken from http://github.com/igrigorik/autoperf
  #
  def parse_config
    config_file = @conf[:config_file]
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

    @conf.merge! conf
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

  def run_suite
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
    File.new(@conf[:output_file], "w").puts report.to_csv unless report.nil?
  end
  
  def display_hints
    puts "~"*80
    puts "Great, now create a graph with"
    puts "  stresser-grapher -o #{File.expand_path(File.dirname(@conf[:output_file]))} #{@conf[:output_file]}"
    puts ""
  end

  def self.options_banner
    <<BANNER
Runs a stresstest defined in a config file and write the results to a csv file.

Usage:
      stresser -c my_config_file -o results.csv
where options are:
BANNER
  end
end
