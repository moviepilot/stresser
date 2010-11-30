require "spec/spec_helper"

describe Httperf do

  describe "parsing httperf output" do

    before(:each) do
      @pipe = File.open("spec/httperf_session_based_output.txt") 
      Time.stub!(:now).and_return "Tue Nov 30 15:49:08 0100 2010"
      
      #
      # The friendly snail is greeting you!
      #
      IO.should_receive(:popen).and_yield @pipe
      @⚋♉ = Httperf.run({})
    end

    it "should parse the 'Total' line correctly" do
      @⚋♉['conns'].should    == 500
      @⚋♉['requests'].should == 600
      @⚋♉['replies'].should  == 300
      @⚋♉['duration'].should == 50.354
    end

    it "should parse the 'Connection rate' line correctly" do
      @⚋♉['conn/s'].should == 9.9
      @⚋♉['ms/connection'].should == 100.7
      @⚋♉['concurrent connections max'].should == 8
    end
    
    it "should parse the 'Connection time' line correctly" do
      @⚋♉['conn time min'].should    == 449.7
      @⚋♉['conn time avg'].should    == 465.1
      @⚋♉['conn time max'].should    == 2856.6
      @⚋♉['conn time median'].should == 451.5
      @⚋♉['conn time stddev'].should == 132.1
    end

    it "should parse the second 'Connection time' line correctly" do
      @⚋♉['conn time connect'].should == 74.1
    end

    it "should parse the 'Connection length' line correctly" do
      @⚋♉['conn length replies/conn'].should == 1.0
    end

    it "should parse the 'Request rate' line correctly" do
      @⚋♉['req/s'].should == 9.9
      @⚋♉['ms/req'].should == 100.7
    end

    it "should parse the 'Request size' line correctly" do
      @⚋♉['request size'].should == 65.0 
    end

    it "should parse the 'Reply rate' line correctly" do
      @⚋♉['replies/s min'].should    == 9.2
      @⚋♉['replies/s avg'].should    == 9.9
      @⚋♉['replies/s max'].should    == 10.0
      @⚋♉['replies/s stddev'].should == 0.3
    end

    it "should parse the 'Reply time' line correctly" do
      @⚋♉['reply time response'].should == 88.1
      @⚋♉['reply time transfer'].should == 302.9
    end

    it "should parse the 'Reply size' line correctly" do
      @⚋♉['reply size header'].should  == 274.0
      @⚋♉['reply size content'].should == 54744.0
      @⚋♉['reply size footer'].should  == 2.0
      @⚋♉['reply size total'].should   == 55020.0
    end

    it "should parse the 'Reply status' line correctly" do
      @⚋♉['status 1xx'].should == 1 
      @⚋♉['status 2xx'].should == 500
      @⚋♉['status 3xx'].should == 3 
      @⚋♉['status 4xx'].should == 4
      @⚋♉['status 5xx'].should == 5
    end
    
    it "should parse the 'CPU time' line correctly" do
      @⚋♉['cpu time user'].should     == 15.65
      @⚋♉['cpu time system'].should   == 34.65
      @⚋♉['cpu time user %'].should   == 31.1
      @⚋♉['cpu time system %'].should == 68.8
      @⚋♉['cpu time total %'].should  == 99.9
    end

    it "should parse the 'Net I/O' line correctly" do
      @⚋♉['net i/o (KB/s)'].should == 534.1
    end

    it "should parse the first 'Errors' line correctly" do
      @⚋♉['errors total'].should       == 1234
      @⚋♉['errors client-timo'].should == 2345
      @⚋♉['errors socket-timo'].should == 3456
      @⚋♉['errors connrefused'].should == 4567
      @⚋♉['errors connreset'].should   == 5678
    end

    it "should parse the second 'Errors' line correctly" do
      @⚋♉['errors fd-unavail'].should  == 1
      @⚋♉['errors addrunavail'].should == 2
      @⚋♉['errors ftab-full'].should   == 3
      @⚋♉['errors other'].should       == 4
    end
   
    it "should parse the 'Session rate' line correctly" do
      @⚋♉['session rate min'].should    == 35.80
      @⚋♉['session rate avg'].should    == 37.04
      @⚋♉['session rate max'].should    == 38.20
      @⚋♉['session rate stddev'].should == 0.98
      @⚋♉['session rate quota'].should  == "1000/1000"
    end 

    it "should parse the 'Session' line correctly" do
      @⚋♉['session avg conns/sess'].should == 2.00
    end

    it "should parse the 'Session lifetime' line correctly" do
      @⚋♉['session lifetime [s]'].should == 0.3
    end

    it "should parse the 'Session failtime' line correctly" do
      @⚋♉['session failtime [s]'].should == 0.0
    end

    it "should parse the 'Session length histogram' correctly" do
      @⚋♉['session length histogram'].should == "0 0 1000" 
    end

    it "should add a started at timestamp for each rate" do
      @⚋♉['started at'].should == "Tue Nov 30 15:49:08 0100 2010" 
    end

  end
end

