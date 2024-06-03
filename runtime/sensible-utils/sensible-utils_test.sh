#!/bin/bash
###############################################################################
#
# DESCRIPTION :
# This test script verifies the sensible-package functionalities on the target .
# This script contains the sensible-browser binary ,sensible-editor and
# sensible-pager check.
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

echo "About to run sensible-utils package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Declaring a variable to the text file path
TEXT_FILE=/tmp/test_file.txt

#Load a text to the text file
set_up() {
	echo "Hi mentor graphics" >> $TEXT_FILE
}

#Removing the created text file
clean_up() {
	echo "removing the txt file"
	rm -f $TEXT_FILE
}

sensible_utils_package_check() {
	skip_list="sensible_browser_check sensible_editor_check sensible_pager_check"
	echo "Checking the package of sensible-utils"
	check_if_package_installed sensible-utils
	lava_test_result "sensible_utils_package_check" "${skip_list}"
}

sensible_browser_check() {
	echo "Checking the binary of sensible browser"
	which sensible-browser
	lava_test_result "sensible_browser_check"
}

sensible_editor_check() {
	echo "Checking the binary of sensible editor"
	which sensible-editor
	lava_test_result "sensible_editor_check"
}

sensible_pager_check() {
	echo "Checking the binary of sensible pager"
	which sensible-pager
	exit_on_step_fail "sensible_pager_check"
	sensible-pager $TEXT_FILE | grep -i "mentor"
	lava_test_result "sensible_pager_check"	
}

#Main
clean_up
set_up
sensible_utils_package_check
(sensible_browser_check)
(sensible_editor_check)
(sensible_pager_check)
