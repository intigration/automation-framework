#!/bin/bash
###############################################################################
#
# DESCRIPTION :
# This test script verifies the udev package check,udev daemon process check . 
# And Identifying the Exact Hardware Device for a Device Node in /dev 
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

echo "About to run udev package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#checking the udev package availability
udev_package_check() {
	skip_list="udev_daemon_process_check udev_lising_devices udev_device_information_check"
	check_if_package_installed udev
	lava_test_result "udev_package_check" "${skip_list}"
}

#udev daemon check 
udev_daemon_process_check() {
	echo "display the udev daemon process"
	ps -aux | grep -i udev
	ret=$?
	if [ $ret -ne 0 ]; then
		exit_on_step_fail "udev_daemon_process_check"
	fi	
	ls -l /lib/systemd | grep -i udev
	lava_test_result "udev_daemon_process_check"
}

#udev listing the devices
udev_listing_devices() {
	echo "listing the devices which is connected to the machine"
	ls -lR /dev/disk 
	lava_test_result "udev_listing_block_devices"	
}

#Device information check
udev_device_information_check() {
	echo "Display the inormation of device"
	Eth_interface=`netstat -g | awk 'FNR == 5 {print $1}'`
	udevadm info -a -p /sys/class/net/$Eth_interface
	lava_test_result "udev_device_information_check"
}

# main
udev_package_check
udev_daemon_process_check
udev_listing_devices
udev_device_information_check

