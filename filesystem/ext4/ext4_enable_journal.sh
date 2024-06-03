#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Verify for ext4 filesystem journal enable support
#
 Author: Muhammad Farhan
#
###############################################################################

#Importing Lava libraries
. ../lib/sh-test-lib

echo "About to run ext4 filesystem journal enable test..."

IMAGE_PATH=/tmp/FS_image
MOUNT_PATH=/tmp/ext4_mount

#Create the directory to mount
set_up() {
	echo "Check e2fsprogs package availability on rootfs"
	mkdir $MOUNT_PATH
	dpkg -l | grep -i "e2fsprogs"
	ret=$?
	if [ $ret -eq 0 ]; then
		echo "e2fsprogs utility installed "
	else
		echo "e2fsprogs utility not installed "
		exit 1
	fi
}

#Delete the created directories
cleanup() {
	rm -rf $IMAGE_PATH
	rm -rf $MOUNT_PATH
}

#Check the enabling of ext4 journal
journal_check() {
	#Creating filesystem image
	echo "Creating an 100MB image"
	dd if=/dev/zero of=$IMAGE_PATH bs=1M count=100
	exit_on_step_fail "ext4_journal_enable_image_create"

	#Creating the EXT4 file system on the image
	echo "Creating an EXT4 file system on the created image"
	mkfs.ext4 $IMAGE_PATH
	exit_on_step_fail "ext4_journal_enable_image_create"

	#Enabling the journal
	echo "Enabling the EXT4 journal"
	tune2fs -O has_journal $IMAGE_PATH
	lava_test_result "ext4_journal_enable_test"

	#mount the filesystem image
	echo "mount the filesystem image"
	mount -o loop -t ext4 $IMAGE_PATH $MOUNT_PATH
	mount | grep -i $MOUNT_PATH
	lava_test_result "ext4_journal_enable_mount_check"

	#Check for the journal flag
	echo "check for journal flag"
	dumpe2fs $IMAGE_PATH | grep journal
	lava_test_result "ext4_journal_enable_flag_check"

	#unmount the filesystem image
	echo "Unmount the filesystem image"
	umount $MOUNT_PATH
	lava_test_result "ext4_journal_enable_unmount_check"
}

#Main
set_up
journal_check
cleanup
