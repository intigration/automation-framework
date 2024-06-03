#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script verifies the availability of grep package,
# Verifies its working with command and file,Verifies if its able to search for regular exressions.
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run grep package test..."
#textfile path
textFile="/tmp/textfile.txt"

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Deleting log file
cleanup() {
	if [ -f "$textFile" ]; then
		rm -f $textFile

	fi
}
setup() {
	touch $textFile
	printf '%s TextFile:' >> $textFile
	printf '%s\n This is a test file:' >> $textFile
	printf '%s\n Created for Grep package testing' >> $textFile
	printf '%s\n Test content for regular expression: 888-444-9999\n' >> $textFile
	cat $textFile
}

#Grep Package Test
grep_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="grep_withcommand_check grep_withfile_check grep_withre_check"
	echo "Checking for Grep Package"
	check_if_package_installed grep
	lava_test_result "grep_package_check" "${skip_list}"
}
#Using grep with command
grep_withcommand_check() {
	echo "Checking use of grep on result of a command"
	cat $textFile | grep -in "test"
        lava_test_result "grep_withcommand_check" 
}
#Using grep with file 
grep_withfile_check() {
	echo "Checking use of grep on result of a command..."
	grep -in "test" $textFile
	lava_test_result "grep_withfile_check" ""
}
#Using grep with regular expression 
grep_withre_check() {
	echo "Checking use of grep with regular expression"
	grep -e "...-...-...." $textFile
	lava_test_result "grep_withre_check" ""

}
cleanup
setup
grep_package_check
(grep_withcommand_check)
(grep_withfile_check)
(grep_withre_check)
cleanup
