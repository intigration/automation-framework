#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# gcc-10-base package which contains files common to all languages and libraries 
# contained in the GNU Compiler Collection (GCC)
#
# Check the gcc-10-base package is available on target or not.
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run gcc-10-base package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib
	
# Check the gcc-10-base package is available on target or not.
package_check() {
	echo "Checking gcc-8-base package is available on target or not"
	check_if_package_installed gcc-8-base
	exit_code=$?
	if [ $exit_code -eq 0 ]; then
		lava_test_result "gcc-8-base_package_check_test"
	else
		check_if_package_installed gcc-10-base
		lava_test_result "gcc-10-base_package_check_test"
	fi
}

#main
package_check

