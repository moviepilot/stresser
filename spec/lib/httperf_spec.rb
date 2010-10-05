require "spec/spec_helper"

describe Httperf do

  describe "parsing httperf output" do

    before(:all) do
      @pipe = File.open("spec/httperf_output.txt") 
      @result = Httperf.parse_output(@pipe)
    end

    it "should parse the 'Total' line correctly" do
      @result['conns'].should    == 500
      @result['requests'].should == 600
      @result['replies'].should  == 300
      @result['duration'].should == 50.354
    end

    it "should parse the 'Connection rate' line correctly" do
      @result['conn/s'].should == 9.9
      @result['ms/connection'].should == 100.7
      @result['concurrent connections max'].should == 8
    end
    
    it "should parse the 'Connection time' line correctly" do
      @result['conn time min'].should    == 449.7
      @result['conn time avg'].should    == 465.1
      @result['conn time max'].should    == 2856.6
      @result['conn time median'].should == 451.5
      @result['conn time stddev'].should == 132.1
    end

    it "should parse the second 'Connection time' line correctly"
    it "should parse the 'Connection length' line correctly"

    it "should parse the 'Request rate' line correctly" do
      @result['req/s'].should == 9.9
      @result['ms/req'].should == 100.7
    end

    it "should parse the 'Request size' line correctly"

    it "should parse the 'Reply rate' line correctly" do
      @result['replies/s min'].should    == 9.2
      @result['replies/s avg'].should    == 9.9
      @result['replies/s max'].should    == 10.0
      @result['replies/s stddev'].should == 0.3
    end

    it "should parse the 'Reply time' line correctly" do
    end
  end

end

