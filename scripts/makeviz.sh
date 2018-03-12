#!/bin/bash
#FILES=anno/*.ttl
FILES=$1
echo "$FILES"
for f in $FILES
do
  filename=$(echo $f | cut -f 1 -d '.')
  rapper -i turtle -o dot $f | dot -Tsvg -o$filename.svg  
  python makehtml.py $filename.svg
done
