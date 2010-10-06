Stresser
=====

This gem is a wrapper around the httperf command which
can put all types of loads on a webserver. It's like
apachebench, but you can replay log files, define 
sessions, and so forth.

This gem calls httperf many times with different
concurrency settings and parses httperf's output into
a csv file, that you can then use to visualize your
application's performance at different concurrency
levels

Installation
---------------

First install the gem

    $ gem install stresser

Then you cann call it from the command line:

    $ ruby stresser.rb -c your_app.conf -o result.csv

You will see the output of the httperf commands that
are issued, and a full report will be written to 
result.csv.

Configuration
---------------

Please refer to the supplied `sample.conf` on how to
configure stresser. Also, see `man httperf` as all
options in `sample.conf` beginning with `httperf_`
go directly to the httperf commands.

Example
---------------

TODO

Thanks
---------------

Stresser is based on igvita's autoperf driver for httperf.
