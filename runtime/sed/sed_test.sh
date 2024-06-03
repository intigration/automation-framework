#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script verifies sed package availability and some of its functionalities
# which includes appending new lines, substituting a string and deleting a string.
#
Author: Muhammad Farhan
# 
###############################################################################

echo "About to run sed package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

sedTestFile="/tmp/sedtest.txt"

cleanup() {
	if [ -f $sedTestFile ]; then
		rm $sedTestFile
	fi
}
setup() {
	touch $sedTestFile
	echo "This File is created to test sed package" >> $sedTestFile
}

#sed Package Check
sed_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="sed_line_append_check sed_string_substitution_check sed_string_delete_check"
	echo "Checking for Sed Package..."
	check_if_package_installed sed
	lava_test_result "sed_package_check" "${skip_list}"
}

#sed append lines to a file Check
sed_line_append_check() {
	skip_list="sed_string_substitution_check sed_string_delete_check"
	echo "Appending of lines in the test file..." 
	sed -i "$ a line1\nline2\nline3\nline4" $sedTestFile
	if [ $? -eq 0 ]; then
		cat $sedTestFile | grep "line"
		lava_test_result "sed_line_append_check" "${skip_list}"
	fi
}

#sed substitution Check
sed_string_substitution_check() {
	echo "Substituting string in test file..."
	sed 's/line/Test/g' $sedTestFile | grep "Test"
	lava_test_result "sed_string_substitution_check"
}

#sed delete line output
sed_string_delete_check() {
	echo "deleting string from test file..."
  	sed '/line1/d' $sedTestFile | grep "line1"
	if [ $? -ne 0 ]; then
		lava_test_result "sed_string_delete_check"
	fi
}


# main
cleanup
setup
sed_package_check
sed_line_append_check
(sed_string_substitution_check)
sed_string_delete_check

