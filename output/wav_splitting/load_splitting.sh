#! /bin/sh



for line in `cat wavlist`
do
	python splitting.py $line
done
