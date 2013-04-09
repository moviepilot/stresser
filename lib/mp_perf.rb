require 'optparse'
require 'ruport'
require 'httperf'
require 'trollop'
require 'csv'

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

    Trollop::die :output_file, "must be a writeable file" unless @conf[:output_file]
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
    cloned_conf = conf.clone

    # Shuffle the logfile around?
    if conf['httperf_wlog'] and conf['shuffle']=='true'
      file = conf['httperf_wlog'].split(',').last
      `cat #{file} | tr "\\0" "\\n" | sort --random-sort | tr "\\n" "\\0" > #{file}.shuffled`
      cloned_conf['httperf_wlog'] = conf['httperf_wlog']+'.shuffled'
    end

    # Run httperf
    res = Httperf.run(cloned_conf)

    return res
  end

  def run_suite
    results = {}
    # report = nil
    report = CSV::Table.new([])
    (@conf['low_rate']..@conf['high_rate']).step(@conf['rate_step']) do |rate|

      # Run httperf
      results[rate] = single_benchmark(@conf.merge({'httperf_rate' => rate}))

      # Show that we're alive
      puts "#{results[rate].delete('output')}\n"
      puts "~"*80

      # Init table unless it's there already
      # report ||= CSV::Table.new(:column_names => ['rate'] + results[rate].keys.sort)
      # table_headers ||= ['rate'] + results[rate].keys
      table_headers ||= results[rate].keys + ['rate']
      report[0]     ||= CSV::Row.new(table_headers, [], true)

      # Save results of this run
      # report << results[rate].merge({'rate' => rate})
      report_hash = results[rate].merge({'rate' => rate})
      report << report_hash.values

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
