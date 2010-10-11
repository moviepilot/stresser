require 'ruport'
require 'gruff'

module Grapher
  extend self

  def error_count(csv_file, outfile, options = {})

    # Prepare interesting columns
    columns = { "req/s" => "rate", 
                "1xx/s" => "status 1xx/s",
                "2xx/s" => "status 2xx/s",
                "3xx/s" => "status 3xx/s",
                "4xx/s" => "status 4xx/s",
                "5xx/s" => "status 5xx/s" }

    # Draw graph
    g = graph(csv_file, columns, options) 

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
   
    # Some default options
    g.hide_dots = true
    g.theme_keynote
    g.line_width = 2

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
end

