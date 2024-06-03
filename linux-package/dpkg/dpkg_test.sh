#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script  verifies dpkg package availability,
# Verifies the functionality provided by the package like getting list of default packages,
# checking if a specified package is installed or not and for location of any specified package.
# verifies the architecture of the corresponding bsp
#
Author: Muhammad Farhan
# 
###############################################################################

echo "About to run dpkg package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

#dpkg Package Check
dpkg_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="dpkg_list_default_packages_check dpkg_installed_package_check dpkg_package_location_check dpkg_architecture_check"
	echo "Checking for dpkg Package"
	cat /var/lib/dpkg/available | grep "Package: dpkg" 
	lava_test_result "dpkg_package_check" "${skip_list}"
}
#dpkg: check list of all default packages
dpkg_list_default_packages_check() {
	echo "dpkg: check list for all default packages..."
	dpkg -l | head -n 20
	lava_test_result "dpkg_list_default_packages_check"
}
#dpkg: check if the specifed package is installed or not
dpkg_installed_package_check() {
	echo "dpkg: check if the specified package is installed or not..."
	dpkg -s apt
	lava_test_result "dpkg_installed_package_check"
}
#dpkg: get location of specified package
dpkg_package_location_check() {
	echo "dpkg: get location of specified package..."
	dpkg -L apt	
	lava_test_result "dpkg_package_location_check"
}

#dpkg: Get the architecture of corresponding bsp
dpkg_architecture_check() {
	echo "dpkg: get the architecture of corresponding bsp "
	dpkg --print-architecture
	lava_test_result "dpkg_architecture_check"
}
#main 
dpkg_package_check
(dpkg_list_default_packages_check)
(dpkg_installed_package_check)
(dpkg_package_location_check)
dpkg_architecture_check

