#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Test scripts check if usbutils is installed on target
# Check information about USB buses in the system
# Check physical USB device hierarchy as a tree
# Check Mass Storage device information
#
Author: Muhammad Farhan
#
###############################################################################

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

echo "About to run usbutils package test..."

# check if usbutils is installed on target
usbutils_package_check() {
	echo "checking if usbutils is installed on target" 
	skip_list="usbutils_device_bus_info_test usbutils_usb_device_tree_test usbutils_mass_storage_device_info_test"
	check_if_package_installed usbutils
	lava_test_result "usbutils_package_check_test" 
}

#Check the usb device bus information 
usb_device_bus_info() {
	echo "Checking the device bus information of the USB"
	find /dev/bus/ | grep -i usb
	lava_test_result "usbutils_device_bus_info_test"
}

# Check physical USB device hierarchy as a tree
usb_device_tree() {
	echo "Checking physical USB device hierarchy as a tree"
	lsusb -t
	lava_test_result "usbutils_usb_device_tree_test"
}

# Check Mass Storage device information
mass_storage_info() {
	echo "Checking Mass Storage device information"
	usb-devices | grep -i Manufacturer
	lava_test_result "usbutils_mass_storage_device_info_test" 
}

# Main
usbutils_package_check
(usb_device_bus_info)
(usb_device_tree)
(mass_storage_info)
