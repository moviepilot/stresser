module Httperf
  extend self
  
  def parse_output(pipe)
    res = Hash.new("")

    while((line = pipe.gets))
      res['output'] += line

      case line
      when /^Total: connections (\d+) requests (\d+) replies (\d+) test-duration (\d+\.\d+) s/ then
        res['conns']    = $1
        res['requests'] = $2
        res['replies']  = $3
        res['duration'] = $4
      when /^Connection rate: (\d+\.\d)[^\d]+(\d+\.\d)[^\d]+(\d+)[^\d]/ then 
        res['conn/s']               = $1
        res['ms/connection']        = $2
        res['concurrent conns max'] = $3
      when /^Connection time .*min (\d+\.\d) avg (\d+\.\d) max (\d+\.\d) median (\d+\.\d) stddev (\d+\.\d)/ then
        res['conn time min']    = $1
        res['conn time avg']    = $2
        res['conn time max']    = $3
        res['conn time median'] = $4
        res['conn time stddev'] = $5
      when /^Request rate: (\d+\.\d)/ then res['req/s'] = $1
      when /^Reply rate .*min (\d+\.\d) avg (\d+\.\d) max (\d+\.\d) stddev (\d+\.\d)/ then
        res['replies/s min'] = $1
        res['replies/s avg'] = $2
        res['replies/s max'] = $3
        res['replies/s stddev'] = $4
      when /^Reply time .* response (\d+\.\d)/ then res['reply time'] = $1
      when /^Reply status.+ 1xx=(\d+) 2xx=(\d+) 3xx=(\d+) 4xx=(\d+) 5xx=(\d+)/ then
        res['status 1xx'] = $1 
        res['status 2xx'] = $2
        res['status 3xx'] = $3 
        res['status 4xx'] = $4
        res['status 5xx'] = $5 
      when /^Net I\/O: (\d+\.\d)/ then res['net io (KB/s)'] = $1
      when /^Errors: total (\d+)/ then res['errors'] = $1
      end
    end
    res
  end
end
