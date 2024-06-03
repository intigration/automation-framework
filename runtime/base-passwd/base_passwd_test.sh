#!/bin/bash

###############################################################################
#
# DESCRIPTION :
# Test script verifies base-passwd package availablity.
# Verifies if all file provided by base-passwd packages are present or not.
# Verifies the working of update-passwd utility
#
# # Author:  Muhammad Farhan
# 
###############################################################################

echo "About to run base-passwd package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#base_passwd Package Check
base_passwd_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="base_passwd_password_file_check base_passwd_group_file_check base_passwd_update_passwd_check"
	echo "Checking for base_passwd Package"
	check_if_package_installed base-passwd
	lava_test_result "base_passwd_package_check" "${skip_list}"
}

#Checking for passwd files provided by base-passwd package
base_passwd_password_file_check() {
	echo "Checking for passwd master files provided by base-passwd package base_passwd_update_passwd_check"
	if [ -f "/etc/passwd" ] && [ -f "/usr/share/base-passwd/passwd.master" ]; then
		lava_test_result "base_passwd_password_file_check"
	else
		lava_test_result "base_passwd_password_file_check"
	fi

}

#Checking for group files provided by base-passwd package
base_passwd_group_file_check() {
	echo "Checking for group master files provided by base-passwd package"
	if [ -f "/etc/group" ] && [ -f "/usr/share/base-passwd/group.master" ]; then
		lava_test_result "base_passwd_group_file_check"
	else
		lava_test_result "base_passwd_group_file_check"
	fi

}

#Checking update-passwd utility provided by base-passwd package
base_passwd_update_passwd_check() {
	echo "Checking update-passwd utility provided by base-passwd package"
	update-passwd -vv -p /usr/share/base-passwd/passwd.master 
	lava_test_result "base_passwd_update_passwd_check"
}

#main 
#function call
base_passwd_package_check
(base_passwd_password_file_check)
(base_passwd_group_file_check)
base_passwd_update_passwd_check
