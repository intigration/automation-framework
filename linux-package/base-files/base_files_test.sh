#!/bin/bash

###############################################################################
#

#
# DESCRIPTION :
# Test script  verifies base-file package availablity.
# Verifies if all file provided by base-files packages are present or not.
# 
# AUTHOR :
#      Muhammad Farhan
#
# 
###############################################################################

echo "About to run base-files package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Base_files Package Check
base_files_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="base_files_file_check"
	echo "Checking for base_file Package"
	check_if_package_installed base-files
	lava_test_result "base_files_package_check" "${skip_list}"
}

#Chechking for files provided by base-files package
base_files_file_check() {
	textfile="base-files/base_files_list.txt"
	echo "Checking for files provided by base-files package"
	while read file ; 
	do 
		echo "$file"
		[ -f "$file" ]
		exit_on_step_fail "base_files_file_check"
	done <$textfile
	lava_test_result "base_files_file_check"
}

#main 
#function call

base_files_package_check
base_files_file_check
