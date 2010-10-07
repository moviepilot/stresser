#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'mpperf'

trap("INT") {
  puts "Terminating tests."
  Process.exit
}

MPPerf.new
