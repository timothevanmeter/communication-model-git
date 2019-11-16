#!/bin/bash
#######################################################
# Renames all files with specified pattern in file name
#######################################################
if [[ $1 ==  "help" ]] || [[ ! $1 ]] ; then
	echo "The rename.sh bash script renames all file containing a user-specified pattern by replacing this pattern with a second user-specified pattern."
	echo "USAGE for rename.sh is:"
	echo "machine@user$ ./rename.sh <pattern_to-replace> <pattern_to-add>"
else
	for f in *$1*
	do 
		mv "$f" "$(echo "$f" | sed s/$1/$2/)"
		echo "File renamed!"
	done
fi
###################################################
# USAGE:
# caca@toto$ ./rename.sh <old_name> <new_name>
# Author: Timothe Van Meter
###################################################

