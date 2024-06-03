#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script verifies the availability of bash package.
# bash package test which is sh-compatible command language interpreter that 
# executes commands read from the standard input or from a file.
# 
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run bash package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#bash Package Check
bash_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="bash_currentShell_check bash_processStatus_check "
	echo "Checking for Bash Package"
	check_if_package_installed bash
	lava_test_result "bash_package_check" "${skip_list}"
}

#bash currentShell Check
bash_currentShell_check() {
	echo "Checking Current Shell Check..."
	#Check the current shell
        echo $SHELL | grep -i bash
	lava_test_result "bash_currentShell_check" ""
}

#bash processProgress Check
bash_processStatus_check() {
	echo "Checking bash process status..."	
	#Check the status of all bash processes
	ps -aef | grep -i "bash"
        lava_test_result "bash_processStatus_check" ""   
}

#Main functions
bash_package_check
(bash_currentShell_check)
bash_processStatus_check
