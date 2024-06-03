#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Filesystem in Userspace (FUSE) which is a simple interface for userspace 
# programs to export a virtual filesystem to the Linux kernel.
# 
# Check the fuse package is available on target or not.
#
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run fuse package test..."

# Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Check the fuse package is available on target or not.
fuse_package_check() {
	echo "Checking fuse package is available on target or not"
	skip_list="fuse_kernel_config_check_test fuse_fs_entry_check_test fuse_mount_check_test"
	check_if_package_installed fuse
	lava_test_result "fuse_package_check_test"
}

# Check fuse filesystem support in kernel
fuse_kernel_support() {
	echo "Checking fuse filesystem config in kernel"
	cat /boot/config-$(uname -r) | grep -i fuse
	lava_test_result "fuse_kernel_config_check_test"
}
# Check fuse fs entry in /proc/filesystem
fuse_fs_entry() {
	echo "Checking fuse fs entry in /proc/filesystem"
	cat /proc/filesystems | grep -i fuse
	if [ $? -eq 0 ]; then
		lava_test_result "fuse_fs_entry_check_test"
	else
		insmod /lib/modules/$(uname -r)/kernel/fs/fuse/fuse.ko
		lava_test_result "fuse_fs_entry_check_test"
	fi
}
# Check fuse fs mount
fuse_mount() {
	echo "Checking fuse fs mount by-default"
	sleep 5
	mount | grep -i fuse
	lava_test_result "fuse_mount_check_test"
}

# main
fuse_package_check
(fuse_kernel_support)
(fuse_fs_entry)
fuse_mount
