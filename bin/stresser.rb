
trap("INT") {
  puts "Terminating tests."
  Process.exit
}

 MPPerf.new
