require 'ruport'
require 'gruff'

module Grapher
  extend self

  def error_count(csv_file, outfile)

    # Prepare interesting columns
    columns = { "requests/s" => "req/s", 
                "1xx/s" => "status 1xx/s",
                "2xx/s" => "status 2xx/s",
                "3xx/s" => "status 3xx/s",
                "4xx/s" => "status 4xx/s",
                "5xx/s" => "status 5xx/s" }

    # Draw graph
    g = graph(csv_file, columns, :title => 'Error rate' )

    # Save graph
    g.write(outfile)
  end

  def graph(csv_file, columns, options = {})
    # Load csv
    table = Table(csv_file)

    # Prepare data structure
    data = Hash.new
    labels = table.column "rate"
    columns.each do |label, column_name|
      data[label] = table.column column_name
    end

    # Draw graph
    g = line_graph( options[:title], data, labels )
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
    g.sort             = false
    g.x_axis_label     = "concurrency (req/s)"

    colors = %w{EFD279 95CBE9 024769 AFD775 2C5700 DE9D7F B6212D 7F5417}.map{|c| "\##{c}"} 

    g.theme = {
      :colors => colors,
      :marker_color => "#cdcdcd",
      :font_color => 'black',
      :background_colors => ['#fefeee', '#ffffff']
    }

  end


end

