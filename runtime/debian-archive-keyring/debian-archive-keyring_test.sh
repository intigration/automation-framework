#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# The Debian project digitally signs its Release files. This package contains the archive keys used for that. 
#
# Check the debian-archive-keyring package is available on target or not.
# Check the list of debian-archive-keyrings available on target by-default 
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run debian-archive-keyring package test..."

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib
	
# Check the debian-archive-keyring package is available on target or not.
package_check() {
	echo "Checking debian-archive-keyring package is available on target or not"
	skip_list="debian-archive-keyring_default_keyrings"
	check_if_package_installed debian-archive-keyring
	lava_test_result "debian-archive-keyring_package_check" "${skip_list}"
}

# Check the list of debian-archive-keyrings available on target by-default
keyring_list() {
	echo "Checking list of debian-archive-keyrings available on target by-default"
	ls -l /usr/share/keyrings/debian-archive-*
	lava_test_result "debian-archive-keyring_default_keyrings"
}

#main
package_check
keyring_list
