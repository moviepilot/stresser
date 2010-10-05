module Httperf
  extend self
  
  def parse_output(pipe)
    res = Hash.new("")

    while((line = pipe.gets))
      res['output'] += line

      title, data = line.split(':')
      next unless title and data 
      nrs = get_numbers(data)

      case title 
      when "Total" then
        res['conns']    = nrs[0]
        res['requests'] = nrs[1]
        res['replies']  = nrs[2]
        res['duration'] = nrs[3]
      when "Connection rate" then 
        res['conn/s']               = nrs[0]
        res['ms/connection']        = nrs[1]
        res['concurrent connections max'] = nrs[2]
      when "Connection time [ms]" then
        next unless data.start_with?(" min")
        res['conn time min']    = nrs[0]
        res['conn time avg']    = nrs[1]
        res['conn time max']    = nrs[2]
        res['conn time median'] = nrs[3]
        res['conn time stddev'] = nrs[4]
      when "Request rate" then
        res['req/s']  = nrs[0]
        res['ms/req'] = nrs[1]
      when "Reply rate [replies/s]" then
        res['replies/s min']    = nrs[0]
        res['replies/s avg']    = nrs[1]
        res['replies/s max']    = nrs[2]
        res['replies/s stddev'] = nrs[3]
      when "Reply time [ms]" then
        res['reply time response'] = nrs[0] 
        res['reply time transfer'] = nrs[1]
      when "Reply status" then
        res['status 1xx'] = nrs[0] 
        res['status 2xx'] = nrs[1]
        res['status 3xx'] = nrs[2] 
        res['status 4xx'] = nrs[3]
        res['status 5xx'] = nrs[4] 
      when "Net I/O" then
        unit = line.match(/Net I\/O: [\d]+\.[\d+] ([^ ]+)/)
        res["net i/o (#{unit[1]})"] = nrs[0] 
      when "Errors" then
        next unless data.start_with?(' total')
        res['errors total']       = nrs[0]
        res['errors client-timo'] = nrs[1]
        res['errors socket-timo'] = nrs[2]
        res['errors connrefused'] = nrs[3]
        res['errors connreset']   = nrs[4]
      end
    end
    res
  end

  private

  def get_numbers(line)
    line.scan(/(\d+\.?\d*)[^x]/).flatten.map do |s|
      s.include?(".") ? s.to_f : s.to_i
    end
  end
end
