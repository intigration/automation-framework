#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# keyutils - In-kernel key management utilities 
# The keyutils package is a library and a set of utilities for accessing the kernel keyrings facility.
#
# Check the keyutils package is available on target or not.
# Check the keyctl package version.
# Checking what keyrings a process is subscribed
# Adding a key to a keyring
# Removing a key to a keyring
#
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run keyutils package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Check the keyutils package is available on target or not.
keyutils_package_check() {
	echo "Checking keyutils package is available on target or not"
	skip_list="keyctl_version_check_test keyctl_current_process_check_test keyctl_add_key_test keyctl_remove_key_test"
	check_if_package_installed keyutils
	lava_test_result "keyutils_package_check_test"
}

#Check the keyctl package version
keyctl_version_check() {
	echo "Checking keyctl package version"
	skip_list="keyctl_current_process_check_test keyctl_add_key_test keyctl_remove_key_test"
	keyctl --version
	lava_test_result "keyutils_version_check_test"
}

#Check the current running process by using keyctl command
keyctl_current_process_check() {
	echo "Checking what keyrings a process is subscribed to and what keys and keyrings they contain."
	skip_list="keyctl_add_key_test keyctl_remove_key_test"
	keyctl show
	lava_test_result "keyutils_current_process_check_test"
}

#Adding new key value to the keyring
keyctl_add_key() {
	echo "Adding a key to a keyring"
	skip_list="keyctl_remove_key_test"
	key_val=$(keyctl add user foo bar @s)
	if [ $? -eq 0 ]; then
	    keyctl show | grep -i "foo"
	    lava_test_result "keyutils_add_key_test" "${skip_list}"
	fi
}

#Remove added key value
keyctl_remove_key() {
	echo "Removing a key to a keyring"
	keyctl revoke $key_val
	if [ $? -eq 0 ]; then
	    keyctl show | grep -i "$key_val: key inaccessible"
	    lava_test_result "keyutils_remove_key_test"  
	fi
}
#main
keyutils_package_check
keyctl_version_check
keyctl_current_process_check
keyctl_add_key
keyctl_remove_key
