#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# This is a transitional package used to ensure multiarch support is present
# in ld.so before unpacking libraries to the multiarch directories. 
# 
# This script check the multiarch-support package is available on target or not.
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run multiarch-support package test..."

# Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Check the multiarch-support package is available on target or not.
multiarch_support_package_check() {
	echo "Checking multiarch-support package is available on target or not"
	skip_list="multiarch_support_lib_path_check"
	check_if_package_installed multiarch-support
	lava_test_result "multiarch_support_package_check" "${skip_list}"
}

# Check if library triplets are added in to dynamic loader conf file 
multiarch_support_lib_path_check() {
	echo "Checking if multiarch library path available ld.so.conf.d/ files"
	cat /etc/ld.so.conf.d/* | grep -i "Multiarch" > /dev/null && cat /etc/ld.so.conf.d/*
	lava_test_result "multiarch_support_lib_path_check"
}

# main
multiarch_support_package_check
multiarch_support_lib_path_check
