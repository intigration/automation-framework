#!/bin/bash

###############################################################################
#
# DESCRIPTION :
# Test script  verifies mtd-utils package availablity,
# Verifies work of commands provided by the package.
#
Author: Muhammad Farhan
# 
###############################################################################

echo "About to run mtd-utils package test..."
#Importing Lava libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#mtd-utils Package Check
mtd_utils_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="mtd_utils_command_check"
	echo "Checking for mtd_utils package"
	check_if_package_installed mtd-utils
	lava_test_result "mtd_utils_package_check" "${skip_list}"
}
#Checking for commands provided by mtd-utils package
mtd_utils_command_check() {
	echo "Checking for commands provided by mtd-utils package"
	if [ "${lava_check}" = "true" ]; then
		file="mtd-utils/mtd_utils_commands_list.txt"
	else
		file="mtd-utils/mtd_utils_commands_list.txt"
	fi
	while read command ; 
	do 
		function=mtd_util_check_${command}
		eval "${function}()
		{
			echo "$command"
			which "$command"
			lava_test_result "mtd_utils_check_${command}"
		}"
		($function)
	done <$file
	
}

#main 
#function_call
mtd_utils_package_check
(mtd_utils_command_check)
