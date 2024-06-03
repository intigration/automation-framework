#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Test scripts check if diffutils is installed on target
# Check compares two files and reports whether or in which bytes they differ using cmp 
# Check compares two files or directories and reports which lines in the files differ using diff
# Check compares three files line by line using diff3
# Check Merges two files and interactively outputs the results using sdiff

Author: Muhammad Farhan
#
###############################################################################

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

echo "About to run diffutils package test..."

#Define test files
setup() {
	file1="/tmp/testfile1.txt"
        touch "$file1"
	echo "Test File1:####This is a test file####" > "$file1"
	file2="/tmp/testfile2.txt"
	touch "$file2"
	echo "Test File1:####This is a test file####" > "$file2"
	file3="/tmp/testfile3.txt"
	touch "$file3"
	echo "Test File3:####This is a test file####" > "$file3"
}

# Deleting test files after use
cleanup() {
	rm -f "$file1" "$file2" "$file3"
}

# check if diffutils is installed on target
diffutils_package_check() {
	echo "checking if diffutils is installed on target" 
	skip_list="diffutils_cmp_check diffutils_diff_check diffutils_diff3_check diffutils_sdiff_check"
	check_if_package_installed diffutils
	lava_test_result "diffutils_package_check_test" 
}

# Compares two files and reports whether or in which bytes they differ using cmp
diffutils_cmp_check() {
	echo "Comparing two files and reports whether or in which bytes they differ using cmp"
	cmp -b "$file1" "$file2" 
	lava_test_result "diffutils_cmp_test" 		
}

# Compares two files or directories and reports which lines in the files differ using diff
diffutils_diff_check() {
	echo "comparing two files and reports which lines in the files differ using diff"
	diff "$file1" "$file2"
	lava_test_result "diffutils_diff_test"  
}

# Compares three files line by line using diff3
diffutils_diff3_check() {
	echo "Comparing three files line by line using diff3"
	diff3 "$file1" "$file2" "$file3"
	lava_test_result "diffutils_diff3_test" 
}

# Merges two files and interactively outputs the results using sdiff
diffutils_sdiff_check() {
	echo "Merging two files and interactively outputs the results using sdiff"
	sdiff "$file1" "$file2"
	lava_test_result "diffutils_sdiff_test"
}

# Main
cleanup
setup
diffutils_package_check
(diffutils_cmp_check)
(diffutils_diff_check)
(diffutils_diff3_check)
diffutils_sdiff_check
