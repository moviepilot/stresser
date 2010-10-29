require 'ruport'
require 'gruff'
require 'yaml'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

module Grapher
  extend self

  #
  #  Parses command line options and creates one or a bunch of 
  #  reports, stores them in the given directory, and advises
  #  the user to go ahead and open them
  #
  def generate_reports(options)

    # Let's keep things clean
    prefix = Time.now.strftime("%Y_%m_%d_%H_%M")

    # Generate a single report or all of them?
    report_keys = reports(options[:report_definitions]).keys
    report_keys = [options[:report]] if report_keys.include?(options[:report])

    # Generate report(s)
    report_keys.each do |report|
      outfile = File.join(options[:output_dir], "#{prefix}_#{report}.png")
      generate_report(report, options[:csv_file], outfile)
    end    

    # Tell user what to do next
    puts "~"*80
    puts "Great, now open the images with"
    puts "  open #{File.join(options[:output_dir], prefix)}*.png"
  end

  #
  #  Generates a single report given by name. Uses the yml file for
  #  report names
  #
  def generate_report(report_type, csv_file, outfile)
    puts "Generating #{report_type} to #{outfile}..."
    columns = (reports[report_type] or reports[reports.keys.first])
    save_graph(csv_file, columns, outfile, :title => report_type) 
  end

  #
  #  Creates and saves a graph
  #
  def save_graph(csv_file, columns, outfile, options = {})
    # Draw graph
    g = graph(csv_file, columns, :title => options[:title] )

    # Save graph
    g.write(outfile)
  end

  #
  #  Creates a graph from a csv file
  #
  def graph(csv_file, columns, options = {})
    table = Table(csv_file)

    # Prepare data structure
    data = Hash.new
    labels = table.column "rate"
    columns.each_index do |i|
      next unless i%2==0
      data[columns[i]] = table.column columns[i+1]
    end

    # Draw graph
    g = line_graph( options[:title], data, labels )
  end

  #
  #  Reads a YAML file that defines how reports are built
  #
  def reports(report = nil, yaml_file = File.join(File.dirname(__FILE__), "reports.yml"))
    y = YAML.load(File.read(yaml_file)) 
  end

  protected


  def line_graph(title, data, labels)

    # Prepare line graph
    g = Gruff::Line.new
    g.title = title
    set_defaults(g)   

    # Add datas
    data.each do |name, values|
      g.data name, values.map(&:to_i)
    end

    # Add labels
    g.labels = to_hash(labels) 

    # Return graph
    g
  end

  def to_hash(array)
    return array if array.class==Hash
    hash = Hash.new
    array.each_with_index{ |v, i| hash[i] = v }
    hash
  end

  def set_defaults(g)
    g.hide_dots        = true 
    g.line_width       = 2
    g.legend_font_size = 20
    g.marker_font_size = 10
    g.sort             = false
    g.x_axis_label     = "concurrency (amount of parallel req)"

    colors = %w{EFD279 95CBE9 024769 AFD775 2C5700 DE9D7F B6212D 7F5417}.map{|c| "\##{c}"} 

    g.theme = {
      :colors => colors,
      :marker_color => "#cdcdcd",
      :font_color => 'black',
      :background_colors => ['#fefeee', '#ffffff']
    }

  end


end

