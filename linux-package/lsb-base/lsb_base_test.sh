#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Test script  verifies the availability of lsb-base package.
# Verifies the init-functions shell library provided by the package.
# 
Author: Muhammad Farhan
# 
###############################################################################

echo "About to run lsb-base package test..."

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Verifying if lsb-base package is present or not
lsb_base_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="lsb_base_init_functions_check"
	echo "Checking for lsb-base package"
	check_if_package_installed lsb-base
	lava_test_result "lsb_base_package_check" "${skip_list}"
}
#Checking for the init-functions shell library provided by the package
lsb_base_init_functions_check() {
	echo "Checking for the init-functions shell library provided by the package"
	if [ -f "/lib/lsb/init-functions" ]; then
		lava_test_result "lsb_base_init_functions_check"
	fi
}

#main
#function
lsb_base_package_check
lsb_base_init_functions_check
