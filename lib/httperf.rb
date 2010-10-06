module Httperf
  extend self

  def run(conf)
    httperf_opt = conf.keys.grep(/httperf/).collect {|k| "--#{k.gsub(/httperf_/, '')}=#{conf[k]}"}.join(" ")
    httperf_cmd = "httperf --hog --server=#{conf['host']} --port=#{conf['port']} #{httperf_opt}"
    IO.popen("#{httperf_cmd} 2>&1") do |pipe|
      puts "\n#{httperf_cmd}"
      res = parse_output(pipe)

      # Now calculate the amount of stati per second
      (1..5).each do |i|
        begin
          res["status #{i}xx/s"] =  res["status #{i}xx"].to_i / res["duration"].to_i
        rescue
          res["status #{i}xx/s"] = -1
        end
      end
    end
    res 
  end

  def parse_output(pipe)
    res = Hash.new("")

    while((line = pipe.gets))
      res['output'] += line

      title, data = line.split(':')
      next unless title and data 
      nrs = grep_numbers(data)

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
        if data.start_with?(" min")
          res['conn time min']    = nrs[0]
          res['conn time avg']    = nrs[1]
          res['conn time max']    = nrs[2]
          res['conn time median'] = nrs[3]
          res['conn time stddev'] = nrs[4]
        else
          next unless data.start_with?(" connect")
          res['conn time connect'] = nrs[0]
        end          
      when "Connection length [replies/conn]" then
        res['conn length replies/conn'] = nrs[0]
      when "Request rate" then
        res['req/s']  = nrs[0]
        res['ms/req'] = nrs[1]
      when "Request size [B]"
        res['request size'] = nrs[0]
      when "Reply rate [replies/s]" then
        res['replies/s min']    = nrs[0]
        res['replies/s avg']    = nrs[1]
        res['replies/s max']    = nrs[2]
        res['replies/s stddev'] = nrs[3]
      when "Reply time [ms]" then
        res['reply time response'] = nrs[0] 
        res['reply time transfer'] = nrs[1]
      when "Reply size [B]" then
        res['reply size header']  = nrs[0]
        res['reply size content'] = nrs[1]
        res['reply size footer']  = nrs[2]
        res['reply size total']   = nrs[3]
      when "Reply status" then
        res['status 1xx'] = nrs[0] 
        res['status 2xx'] = nrs[1]
        res['status 3xx'] = nrs[2] 
        res['status 4xx'] = nrs[3]
        res['status 5xx'] = nrs[4] 
      when "CPU time [s]" then
        res['cpu time user']     = nrs[0]
        res['cpu time system']   = nrs[1]
        res['cpu time user %']   = nrs[2]
        res['cpu time system %'] = nrs[3]
        res['cpu time total %']  = nrs[4]
      when "Net I/O" then
        unit = line.match(/Net I\/O: [\d]+\.[\d+] ([^ ]+)/)
        res["net i/o (#{unit[1]})"] = nrs[0] 
      when "Errors" then
        if data.start_with?(' total')
          res['errors total']       = nrs[0]
          res['errors client-timo'] = nrs[1]
          res['errors socket-timo'] = nrs[2]
          res['errors connrefused'] = nrs[3]
          res['errors connreset']   = nrs[4]
        else
          res['errors fd-unavail']  = nrs[0]
          res['errors addrunavail'] = nrs[1]
          res['errors ftab-full']   = nrs[2]
          res['errors other']       = nrs[3]
        end
      when "Session rate [sess/s]" then
        res['session rate min']    = nrs[0]
        res['session rate avg']    = nrs[1]
        res['session rate max']    = nrs[2]
        res['session rate stddev'] = nrs[3]
        res['session rate quota']  = "#{nrs[4]}/#{nrs[5]}"
      when "Session" then
        res['session avg conns/sess'] = nrs[0]
      when "Session lifetime [s]" then
        res['session lifetime [s]'] = nrs[0]
      when "Session failtime [s]" then
        res['session failtime [s]'] = nrs[0]
      when "Session length histogram" then
        res['session length histogram'] = nrs.join(" ")
      end
    end
    res
  end

  private

  def grep_numbers(line)
    line.scan(/(\d+\.?\d*)[^x]/).flatten.map do |s|
      s.include?(".") ? s.to_f : s.to_i
    end
  end
end
