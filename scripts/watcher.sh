#!/bin/sh
dir1=./anno/*.ttl
inotifywait -qmr --event modify --format '%w' $dir1 | while read FILE
do
   b=$(basename $FILE)
   ./makeviz.sh "anno/$b"
done
