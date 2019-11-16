#!/bin/bash
################################################
# Append notes to a file with today's time-stamp
################################################
if [[ $1 ==  "help" ]] || [[ ! $1 ]] ; then
	echo "The notes.sh bash script writes the user-specified input string to the local expected notes file: ./VANMETER_PROJECT_NOTES.txt, preceded by today's date to keep track of progress."
	echo "USAGE for notes.sh is:"
	echo "machine@user$ ./notes.sh \"Your notes to add to the notes file\""
else
	date >> VANMETER_PROJECT_NOTES.txt
	echo $1 >> VANMETER_PROJECT_NOTES.txt
fi
###################################################
# USAGE:
# caca@toto$ ./notes.sh "Your notes to add to the notes file"
# Author: Timothe Van Meter
###################################################
