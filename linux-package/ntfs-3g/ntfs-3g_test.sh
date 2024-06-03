#!/bin/sh

###############################################################################
#  
# DESCRIPTION :
#      NTFS-3G uses FUSE (Filesystem in Userspace) to provide support for the 
#      NTFS filesystem used by Microsoft Windows.
#      This script verifies mounting and file operations on ntfs-3g filesystem 
# 
# Author:  Muhammad Farhan
# 
###############################################################################

echo "About to run ntfs-3g package test..."

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

MOUNT_DIR="/tmp/ntfs-3g"
NTFS_FILE="/tmp/NtfsImg"

cleanup() {
	echo "Doing cleanup task"
	if [ -d $MOUNT_DIR ]; then
		umount $MOUNT_DIR
		rm -rf $MOUNT_DIR
	fi

	if [ -f $NTFS_FILE ]; then
		rm -f $NTFS_FILE
	fi
}

setup() {
	echo "creating mount point and generating filesystem block file"
	# create mount directory
	mkdir $MOUNT_DIR
	# generate file to create filesytem block
	dd bs=1M count=100 if=/dev/zero of=$NTFS_FILE
}

# check if ntfs-3g package installed
ntfs3g_package_check() {
	skip_list="ntfs3g_create_file_system_check ntfs3g_mount_check ntfs3g_file_operation_check ntfs3g_umount_check"
	echo "Checking if ntfs-3g Package available"
	check_if_package_installed ntfs-3g
	lava_test_result "ntfs3g_package_check" "${skip_list}"
}

# create a ntfs filesystem
ntfs3g_create_file_system_check() {
	skip_list="ntfs3g_mount_check ntfs3g_file_operation_check ntfs3g_umount_check"
	echo "Creating ntfs filesystem"
	mkfs.ntfs -F $NTFS_FILE 
	lava_test_result "ntfs3g_create_file_system_check" "${skip_list}"
}

# mount the created ntfs filesystem 
ntfs3g_mount_check() {
	skip_list="ntfs3g_file_operation_check ntfs3g_umount_check"
	echo "Mounting the created ntfs filesystem on directory $MOUNT_DIR"
	ntfs-3g $NTFS_FILE $MOUNT_DIR
	lava_test_result "ntfs3g_mount_check" "${skip_list}"
}

# verify creation of files and directories under mount point
ntfs3g_file_operation_check() {
	echo "Checking file operation i.e create file and write to file at mount point"
	echo "Hello world" > $MOUNT_DIR/testfile1
	cat $MOUNT_DIR/testfile1 | grep "Hello world"
	lava_test_result "ntfs3g_file_operation_check"
}

# unmount
ntfs3g_umount_check() {
	echo "Unmounting ntfs-3g filesystem from $MOUNT_DIR"
	umount $MOUNT_DIR
	lava_test_result "ntfs3g_umount_check"
}

# MAIN
cleanup
setup
ntfs3g_package_check
ntfs3g_create_file_system_check
ntfs3g_mount_check
(ntfs3g_file_operation_check)
ntfs3g_umount_check
