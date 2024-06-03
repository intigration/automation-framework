#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# Verify libxml2 package on target
# Verify libxml file parse function
# Verify libxml file push function check
# Verify libxml xpath function check
#
 Author: Muhammad Farhan
#
###############################################################################

#Import LAVA libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Python packages needed to be installed by individually as
# multiple packages installation and requirements.txt method is failing.
setup() {
	echo "Installing python packages"

	#install setuptools package
	pip3 install setuptools

	if [ $? -eq 0 ]; then
		echo "setuptools package installed successfully"
	else
		echo "Failed to install setuptools package"
	fi

	#install libxml2-python3 package
	pip3 install libxml2-python3

	if [ $? -eq 0 ]; then
		echo "libxml2-python3 package installed successfully"
	else
		echo "Failed to install libxml2-python3 package"
	fi
}
libxml2_package_check() {
	echo "Check libxml2 package on target"
	skip_list="libxml2_file_push_check libxml2_file_parse_check libxml2_xpath_check"
	check_if_package_installed libxml2
	lava_test_result "libxml2_package_check"
}
libxml2_functions_check() {
	echo "Check the libxml2 file push check"
	python3 libxml2/libxml2_push.py
	lava_test_result "libxml2_file_push_check"

	echo "Check the libxml2 file parse check"
	python3 libxml2/libxml2_parse.py
	lava_test_result "libxml2_file_parse_check"

	echo "Check the libxml2 xpath check"
	python3 libxml2/libxml2_xpath.py
	lava_test_result "libxml2_xpath_check"

}
#Main
setup
libxml2_package_check
libxml2_functions_check
