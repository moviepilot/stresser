# Stresser

This gem is a wrapper around the httperf command which
can put all types of loads on a webserver. It's like
apachebench, but you can replay log files, define 
sessions, and so forth.

This gem calls httperf many times with different
concurrency settings and parses httperf's output into
a csv file, that you can then use to visualize your
application's performance at different concurrency
levels

## Installation

First install the gem

    $ gem install stresser

## Configuration

Please refer to the supplied `sample.conf` on how to
configure stresser. Also, see `man httperf` as all
options in `sample.conf` beginning with `httperf_`
go directly to the httperf commands.

## Examples

### Stresstest
You can call stresser from the command line:

    $ stresser your_app.conf -o result.csv

You will see the output of the httperf commands that
are issued, and a full report will be written to 
result.csv.

### Creating graphs
When you're done, you can create a graph of your testrun like this:

    $ stresser-grapher result.csv graph.png 

### Log generator
As a little helper to generate log files defining some
session workload that requires different urls,
`stresser-loggen` is supplied. Just create a log template
named `mylog.tpl` like this

    # My session workload
    /users/{{n}}
      /images/foo.gif
      /images/bar.gif
    /users{{n}}/dashboard

And then use `stresser-loggen` to reproduce these lines
as often as you like:

    stresser-loggen mylog.tpl 100 > mylog.conf

The `{{n}}` will be replaced with the numbers 0-99.

## Thanks

Stresser is based on igvita's autoperf driver for httperf.
