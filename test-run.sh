#!/bin/bash
# A bash script to run behaviourspace in netlogo headless through terminal:

netlogo-headless.sh \
	--model Fire.nlogo \
	--experiment experiment2 \
	--table table-output.csv \
	--spreadsheet spreadsheet-output.csv \
	--max-pxcor 100 \
	--min-pxcor -100 \
	--max-pycor 100 \
	--min-pycor -100
