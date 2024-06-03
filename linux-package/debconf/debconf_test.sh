#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Debconf is a configuration management system for debian packages. Packages use Debconf to ask questions when they are installed. 
#
# Check the debconf package is available on target or not.
# Check if debconf configuration file exists or not
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run debconf package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib
	
# Check the debconf package is available on target or not.
package_check() {
	echo "Checking debconf package is available on target or not"
	skip_list="debconf_configuration_file_exist_check"
	check_if_package_installed debconf
	lava_test_result "debconf_package_check_test" "${skip_list}"
}

# Check if debconf configuration file exists or not
debconf_file_check() {
	echo "Checking if debconf configuration file exists or not"
	if [ -f "/etc/debconf.conf" ] ;then
	lava_test_result "debconf_configuration_file_exist_check"
	fi
}

#main
package_check
debconf_file_check
