require "spec_helper"

describe Httperf do

  describe "converting config to command line options" do
    let(:conf) do
      {
        "host"=>"localhost", "uri"=>"/", "port"=>80,
        "low_rate"=>5, "high_rate"=>50, "rate_step"=>5, "sleep_time"=>10,
        "httperf_wsesslog"=>"100,10,urls.log", "httperf_num-conns"=>100,
        "httperf_num-calls"=>1, "httperf_timeout"=>5,
        "httperf_burst-length"=>1,
        "httperf_rate"=>5
      }
    end

    context "when conf value is nil" do
      it "doesn't set value for command line option" do
        IO.should_receive(:popen).with(/ --session-cookie /)

        Httperf.run(conf.merge({"httperf_session-cookie"=>"nil"}))
      end
    end

    context "add-header is double quoted" do
      it "sets correct --add-header option" do
        IO.should_receive(:popen).with(/ --add-header='Authorization: Basic hash\n' /)

        Httperf.run(conf.merge({"httperf_add-header"=>"'Authorization: Basic hash\n'"}))
      end
    end
  end
  describe "parsing httperf output" do

    before(:each) do
      @pipe = File.open("spec/httperf_session_based_output.txt")
      Time.stub!(:now).and_return "Tue Nov 30 15:49:08 0100 2010"

      #
      # The friendly snail is greeting you!
      #
      IO.should_receive(:popen).and_yield @pipe
      @httperf = Httperf.run({})
    end

    it "should parse the 'Total' line correctly" do
      @httperf['conns'].should    == 500
      @httperf['requests'].should == 600
      @httperf['replies'].should  == 300
      @httperf['duration'].should == 50.354
    end

    it "should parse the 'Connection rate' line correctly" do
      @httperf['conn/s'].should == 9.9
      @httperf['ms/connection'].should == 100.7
      @httperf['concurrent connections max'].should == 8
    end

    it "should parse the 'Connection time' line correctly" do
      @httperf['conn time min'].should    == 449.7
      @httperf['conn time avg'].should    == 465.1
      @httperf['conn time max'].should    == 2856.6
      @httperf['conn time median'].should == 451.5
      @httperf['conn time stddev'].should == 132.1
    end

    it "should parse the second 'Connection time' line correctly" do
      @httperf['conn time connect'].should == 74.1
    end

    it "should parse the 'Connection length' line correctly" do
      @httperf['conn length replies/conn'].should == 1.0
    end

    it "should parse the 'Request rate' line correctly" do
      @httperf['req/s'].should == 9.9
      @httperf['ms/req'].should == 100.7
    end

    it "should parse the 'Request size' line correctly" do
      @httperf['request size'].should == 65.0
    end

    it "should parse the 'Reply rate' line correctly" do
      @httperf['replies/s min'].should    == 9.2
      @httperf['replies/s avg'].should    == 9.9
      @httperf['replies/s max'].should    == 10.0
      @httperf['replies/s stddev'].should == 0.3
    end

    it "should parse the 'Reply time' line correctly" do
      @httperf['reply time response'].should == 88.1
      @httperf['reply time transfer'].should == 302.9
    end

    it "should parse the 'Reply size' line correctly" do
      @httperf['reply size header'].should  == 274.0
      @httperf['reply size content'].should == 54744.0
      @httperf['reply size footer'].should  == 2.0
      @httperf['reply size total'].should   == 55020.0
    end

    it "should parse the 'Reply status' line correctly" do
      @httperf['status 1xx'].should == 1
      @httperf['status 2xx'].should == 500
      @httperf['status 3xx'].should == 3
      @httperf['status 4xx'].should == 4
      @httperf['status 5xx'].should == 5
    end

    it "should parse the 'CPU time' line correctly" do
      @httperf['cpu time user'].should     == 15.65
      @httperf['cpu time system'].should   == 34.65
      @httperf['cpu time user %'].should   == 31.1
      @httperf['cpu time system %'].should == 68.8
      @httperf['cpu time total %'].should  == 99.9
    end

    it "should parse the 'Net I/O' line correctly" do
      @httperf['net i/o (KB/s)'].should == 534.1
    end

    it "should parse the first 'Errors' line correctly" do
      @httperf['errors total'].should       == 1234
      @httperf['errors client-timo'].should == 2345
      @httperf['errors socket-timo'].should == 3456
      @httperf['errors connrefused'].should == 4567
      @httperf['errors connreset'].should   == 5678
    end

    it "should parse the second 'Errors' line correctly" do
      @httperf['errors fd-unavail'].should  == 1
      @httperf['errors addrunavail'].should == 2
      @httperf['errors ftab-full'].should   == 3
      @httperf['errors other'].should       == 4
    end

    it "should parse the 'Session rate' line correctly" do
      @httperf['session rate min'].should    == 35.80
      @httperf['session rate avg'].should    == 37.04
      @httperf['session rate max'].should    == 38.20
      @httperf['session rate stddev'].should == 0.98
      @httperf['session rate quota'].should  == "1000/1000"
    end

    it "should parse the 'Session' line correctly" do
      @httperf['session avg conns/sess'].should == 2.00
    end

    it "should parse the 'Session lifetime' line correctly" do
      @httperf['session lifetime [s]'].should == 0.3
    end

    it "should parse the 'Session failtime' line correctly" do
      @httperf['session failtime [s]'].should == 0.0
    end

    it "should parse the 'Session length histogram' correctly" do
      @httperf['session length histogram'].should == "0 0 1000"
    end

    it "should add a started at timestamp for each rate" do
      @httperf['started at'].should == "Tue Nov 30 15:49:08 0100 2010"
    end

  end
end

