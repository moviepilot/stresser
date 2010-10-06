require 'lib/mp_perf'

trap("INT") {
  puts "Terminating tests."
  Process.exit
}

 MPPerf.new
