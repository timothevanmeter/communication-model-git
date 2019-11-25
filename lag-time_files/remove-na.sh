#!/bin/bash

for i in `seq -w 1 100`
do
	gawk -i inplace '!/NA/' "output-$i"
done
