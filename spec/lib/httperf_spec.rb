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
  end

end

