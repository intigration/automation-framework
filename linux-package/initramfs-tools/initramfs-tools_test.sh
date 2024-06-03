#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# initramfs-tools to create an initramfs for prepackaged Linux kernel images. The initramfs is an cpio archive.
# At boot time, the kernel unpacks that archive into ram, mounts and uses it as initial root file system. 
# From there on the mounting of the real root file system occurs in user space.
# klibc handles the boot-time networking setup. Supports nfs root system. Any boot loader with Initrd support is able to load an initramfs archive. 
#
# This test case verifies if initramfs-tools package is available on target or not.
# Create an initramfs for current running kernel.
# Check list initramfs content of current running kernel
# Update initramfs of current running kernel
# Extract content from an initramfs image
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run initramfs-tools package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Define variables
file="/tmp/initramfs-$(uname -r)"
extract_path="/tmp/initram/"

clean_up() {
	rm -f $file
	rm -rf $extract_path
}

# Check the initramfs-tools package is available on target or not.
initramfs_tools_package_check() {
	echo "Checking initramfs-tools package is available on target or not"
	skip_list="initramfs-tools_create_initramfs_test initramfs-tools_list_initramfs_test initramfs-tools_update_initramfs_test initramfs-tools_extract_initramfs_test"
	check_if_package_installed initramfs-tools
	lava_test_result "initramfs_tools_package_check_test"
}
# Create an initramfs for current running kernel.
initramfs_tools_create_initramfs() {
	echo "Creating an initramfs for current running kernel"
	mkinitramfs -o $file
	if [ -f "$file" ]; then
		lava_test_result "initramfs-tools_create_initramfs_test"
	fi
}

# Check list initramfs content of current running kernel
initramfs_tools_list_initramfs() {
	echo "Listing the content of an initramfs for current running kernel"
	lsinitramfs -l $file
	lava_test_result "initramfs-tools_list_initramfs_test"
}

# Update initramfs of current running kernel
initramfs_tools_update_initramfs() {
	echo "Updating an initramfs of current running kernel"
	update-initramfs -u
	lava_test_result "initramfs-tools_update_initramfs_test"
}

# Extract content from an initramfs image
initramfs_tools_extract_initramfs() {
	echo "Extracting contents from an initramfs image"
	unmkinitramfs $file $extract_path
	echo "Display the content of initramfs image"	
	ls -l $extract_path
	lava_test_result "initramfs-tools_extract_initramfs_test"
}

#main
initramfs_tools_package_check
(initramfs_tools_create_initramfs)
(initramfs_tools_list_initramfs)
(initramfs_tools_update_initramfs)
(initramfs_tools_extract_initramfs)
clean_up
