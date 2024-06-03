#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# This test case verifies if dash package is available on target or not.
# Check the current shell
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run dash package test..."

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Check the dash package is available on target or not.
package_check() {
	echo "Checking dash package is available on target or not"
	check_if_package_installed dash
	lava_test_result "dash_package_check_test"
}

# Check the shell of system
dash_shell_check() {
	echo "Checking the shell of the system"
	ls -l /bin/sh
	lava_test_result "dash_shell_check_test"
			
}

#main
package_check
(dash_shell_check)
