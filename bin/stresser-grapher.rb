#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'gruff'

module Grapher
  extend self

  def error_count(csv_file, outfile, options = {})

    # Prepare interesting columns
    columns = { "1xx" => "status 1xx/s",
                "2xx" => "status 2xx/s",
                "3xx" => "status 3xx/s",
                "4xx" => "status 4xx/s",
                "5xx" => "status 5xx/s" }

    # Draw graph
    g = graph(csv_file, columns, options) 

    # Save graph
    g.write(outfile)
  end

  def graph(csv_file, columns, options = {})
    
    # Load csv
    table = Table(csv_file)

    # Prepare data structure
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
    
    # Add datas
    data.each do |name, values|
      g.data name, values
    end

    # Add labels
    g.labels labels

    # Return graph
    g
  end
end
