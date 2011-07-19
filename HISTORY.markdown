## 0.5
Added a 'shuffle' option that will take your wlog file and shuffle the
lines between each run. What it does in detail is:

1. Transform \0 to \n in your file
2. sort --random-sort your file
3. Transform \n to \0
4. Write to your_wlog.shuffled

This can be used to confuse caches. Just set `shuffle=true` in your
conf file.

## 0.4
 - added 'started at' column to csv export
 - refactored options pasing in stresser bin to match stresser-grapher and stresser-loggen
