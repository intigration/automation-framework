#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Verify devtmpfs filesystem support in kernel
# Verify devtmpfs mount by-default
# Verify Total number of files in /dev
# Verify devtmpfs entry in /proc/filesystems
#
# Author:  Muhammad Farhan
#
###############################################################################

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing kernel config API
. ../lib/sh-debian-lib

echo "About to run devtmpfs filesystem test..."

temp_dir="/tmp/tmpfs_test"

# Verify devtmpfs filesystem support in kernel
kernel_config() {
	echo "Test tmp FS support in Kernel"
	check_kernel_config CONFIG_DEVTMPFS
	lava_test_result "devtmpfs_kernel_support"
}

# Verify devtmpfs mount by-default
mount_check() {
	echo "Checking tmpfs mount "
	mount | grep devtmpfs
	lava_test_result "devtmpfs_default_mount_check"
}

# Verify Total number of files in /dev
files_check() {
	echo "Checking total number of files in /dev/"
	ls -1 /dev/ | wc -l
	ret=$?
	if [ $ret -eq 0 ]; then
		lava_test_result "devtmpfs_total_file_check"
	fi
}

# Verify devtmpfs entry in /proc/filesystems
proc_entry() {
	echo "Checking devtmpfs entry in /proc"
	cat /proc/filesystems | grep devtmpfs
	lava_test_result "devtmpfs_found_proc"
}

# Main
(kernel_config)
(mount_check)
(files_check)
(proc_entry)
