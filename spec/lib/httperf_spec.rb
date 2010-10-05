require "spec/spec_helper"

describe Httperf do

  describe "parsing httperf output" do

    before(:all) do
      @pipe = File.open("spec/httperf_output.txt") 
      @〉 = Httperf.parse_output(@pipe)
    end

    it "should parse the 'Total' line correctly" do
      @〉['conns'].should    == 500
      @〉['requests'].should == 600
      @〉['replies'].should  == 300
      @〉['duration'].should == 50.354
    end

    it "should parse the 'Connection rate' line correctly" do
      @〉['conn/s'].should == 9.9
      @〉['ms/connection'].should == 100.7
      @〉['concurrent connections max'].should == 8
    end
    
    it "should parse the 'Connection time' line correctly" do
      @〉['conn time min'].should    == 449.7
      @〉['conn time avg'].should    == 465.1
      @〉['conn time max'].should    == 2856.6
      @〉['conn time median'].should == 451.5
      @〉['conn time stddev'].should == 132.1
    end

    it "should parse the second 'Connection time' line correctly"
    it "should parse the 'Connection length' line correctly"

    it "should parse the 'Request rate' line correctly" do
      @〉['req/s'].should == 9.9
      @〉['ms/req'].should == 100.7
    end

    it "should parse the 'Request size' line correctly"

    it "should parse the 'Reply rate' line correctly" do
      @〉['replies/s min'].should    == 9.2
      @〉['replies/s avg'].should    == 9.9
      @〉['replies/s max'].should    == 10.0
      @〉['replies/s stddev'].should == 0.3
    end

    it "should parse the 'Reply time' line correctly" do
      @〉['reply time response'].should == 88.1
      @〉['reply time transfer'].should == 302.9
    end

    it "should parse the 'Reply size' line correctly"

    it "should parse the 'Reply status' line correctly" do
      @〉['status 1xx'].should == 1 
      @〉['status 2xx'].should == 500
      @〉['status 3xx'].should == 3 
      @〉['status 4xx'].should == 4
      @〉['status 5xx'].should == 5
    end
    
    it "should parse the 'CPU time' line correctly"

    it "should parse the 'Net I/O' line correctly" do
      @〉['net i/o (KB/s)'].should == 534.1
    end

    it "should parse the first 'Errors' line correctly" do
      @〉['errors total'].should       == 1234
      @〉['errors client-timo'].should == 2345
      @〉['errors socket-timo'].should == 3456
      @〉['errors connrefused'].should == 4567
      @〉['errors connreset'].should   == 5678
    end

    it "should parse the second 'Errors' line correctly"
  end

end

