#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# initramfs-tools-core contains the mkinitramfs program that can be used to create a bootable initramfs for a Linux kernel. 
#
# This test case verifies if initramfs-tools-core package is available on target or not.
# Check for mkinitramfs on the target side.
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run initramfs-tools-core package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Check the initramfs-tools package is available on target or not.
initramfs_tools_core_package_check() {
	echo "Checking initramfs-tools-core package is available on target or not"
	skip_list="initramfs-tools-core_mkinitramfs_binary_check_test"
	check_if_package_installed initramfs-tools-core
	lava_test_result "initramfs-tools-core_package_check_test"
}

#Check for mkinitramfs on the target side.
check_for_mkinitramfs() {
	echo "Checking for mkinitramfs on the target side"
	ls -l /usr/sbin/ | grep "mkinitramfs"
	lava_test_result "initramfs-tools-core_mkinitramfs_binary_check_test"
}

#main
initramfs_tools_core_package_check
check_for_mkinitramfs
