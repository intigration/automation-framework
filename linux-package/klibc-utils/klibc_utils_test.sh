#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Checking klibc-utils package on target  
# Listing the binaries of klibc 
# Checking the kernel log using klibc dmesg command 
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

echo "About to run klibc_utils package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#check the availability of klibc-utils package
klibc_utils_package_check() {
	echo "Checking the klibc-utils package on target"
	skip_list="klibc_utils_listing_binaries klibc_utils_dmesg_command_check"
	check_if_package_installed klibc-utils
	lava_test_result "klibc_utils_package_check" "${skip_list}"
}
#Listing the binaries of klibc 
klibc_utils_listing_binaries() {
	echo "Checking the klibc-utils package on target"
	ls -l /usr/lib/klibc/bin
	lava_test_result "klibc_utils_listing_binaries"
}
#Check the dmesg binary function check
klibc_utils_dmesg_command_check() {
	echo "Checking the kernel log using klibc dmesg command"
	dmesg | tail
	lava_test_result "klibc_utils_dmesg_command_check"

}
#Main
klibc_utils_package_check
(klibc_utils_listing_binaries)
(klibc_utils_dmesg_command_check)
