#!/bin/bash
# used this to find duplicate lines in derrida dedications 20180119 -pg
files=/home/pmgreen/Projects/ld4p/annotation_editor/dedications/turtle_20180112/*
for f in $files
do
	sort $f | uniq -d
done
