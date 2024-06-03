#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# This test case verifies if systemd-sysv package is available on target or not.
# also check the systemd-sysv overwrite /sbin/init with a link to systemd.
#
# # Author:  Muhammad Farhan
#
###############################################################################

echo "About to run systemd-sysv package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Check the systemd-sysv package is available on target or not.
systemd_sysv_package_check() {
	echo "Checking systemd-sysv package is available on target or not"
	skip_list="systemd_sysv_symlink_test"
	check_if_package_installed systemd-sysv
	lava_test_result "systemd_sysv_package_check_test"
}

# Check the /sbin/init with a link to systemd on target side.
systemd_sysv_symlink() {
	echo "Checking the /sbin/init with a link to systemd on target side"
	ls -l /sbin/init | grep -i "systemd"	
	lava_test_result "systemd_sysv_symlink_test"
}

#main
systemd_sysv_package_check
systemd_sysv_symlink

