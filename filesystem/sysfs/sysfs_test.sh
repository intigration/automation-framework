#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Verify sysfs filesystem support in kernel
# Verify devtmpfs mount by-default
# Verify /sys dir structure
#
 Author: Muhammad Farhan
#
###############################################################################

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing kernel config API
. ../lib/sh-debian-lib

echo "About to run sysfs filesystem test..."

# Verify sysfs filesystem support in kernel
kernel_config() {
	echo "Test sysFS support in Kernel"
	check_kernel_config CONFIG_SYSFS
	lava_test_result "sysfs_kernel_support"
}

# Verify sysfs mount by-default
mount_check() {
	echo "Checking sysfs mount "
	mount | grep sysfs
	lava_test_result "sysfs_default_mount_check"
}

#Verify /sys dir structure
structure_check() {
	not_matched=0

	for dir in "$@";
	do
		ls /sys | grep -i -w $dir
		ret=$?
		if [ $ret -eq 1 ]; then
			echo "$not_matched not found in /sys"
			not_matched=$((not_matched+1))
		fi
	done

	if [ $not_matched -eq 0 ]; then
		lava_test_result "sysfs_directory_structure_match_test"
	fi
}

# Main
(kernel_config)
(mount_check)
structure_check "block" "bus" "class" "dev" "devices" "firmware" "fs" "kernel" "module" "power"
