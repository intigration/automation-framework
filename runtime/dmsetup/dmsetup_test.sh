#!/bin/sh

###############################################################################
#  
# DESCRIPTION :
#	package test for dmsetup a low level logical volume management tool.
#	Script Verifies 
#		- creation of device, 
#		- listing devices, 
#		- checking its status and info,
#	    - removing of created device 	
# Author:  Muhammad Farhan
# 
###############################################################################

echo "About to run dmsetup package test..."

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# check if dmsetup package installed
dmsetup_package_check() {
	skip_list="dmsetup_version_check dmsetup_create_mapper_device_check dmsetup_list_device_check dmsetup_device_status_check dmsetup_device_info_check dmsetup_remove_device_check"
	echo "Checking if dmsetup Package available"
	check_if_package_installed dmsetup
	lava_test_result "dmsetup_package_check" "${skip_list}"
}

# dmsetup version check
dmsetup_version_check() {
	echo "Checking version of dmsetup package"
	dmsetup version
	lava_test_result "dmsetup_version_check"
}

# create zero target device. The "zero" target create that functions similarly to /dev/zero: All reads return binary zero, and all writes are discarded
dmsetup_create_mapper_device_check() {
	skip_list="dmsetup_list_device_check dmsetup_device_status_check dmsetup_device_info_check dmsetup_remove_device_check"
	echo "Checking if dmsetup able to create device mapper device"
	# This activates a new device mapper device. test_zero appears in /dev/mapper.
	# Syntax: dmsetup create <new device name> --tables <start sector> <end sector> <target name>
	# Here 100MB target is created. (1 sector = 512 bytes)
	dmsetup create test_zero --table '0 200 zero'
	lava_test_result "dmsetup_create_mapper_device_check" "${skip_list}"
}

# list device mapper devices
dmsetup_list_device_check() {
	skip_list="dmsetup_device_status_check dmsetup_device_info_check"
	echo "Checking if dmsetup able to list devices entered in /dev/mapper"
	dmsetup ls | grep test_zero
	lava_test_result "dmsetup_list_device_check" "${skip_list}"
}

# check status of device mapper device
dmsetup_device_status_check() {
	echo "Checking if dmsetup able to get status of created device"
	dmsetup status test_zero
	lava_test_result "dmsetup_device_status_check"
}

# check info of device mapper device
dmsetup_device_info_check() {
	echo "Checking if dmsetup able to get info of created device"
	dmsetup info test_zero
	lava_test_result "dmsetup_device_info_check"
}

# remove created zero target device
dmsetup_remove_device_check() {
	echo "Checking if dmsetup able to remove created device"
	dmsetup remove test_zero
	lava_test_result "dmsetup_remove_device_check"
}

# MAIN
dmsetup_package_check
(dmsetup_version_check)
dmsetup_create_mapper_device_check
dmsetup_list_device_check
(dmsetup_device_status_check)
(dmsetup_device_info_check)
dmsetup_remove_device_check
