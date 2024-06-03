#!/bin/bash
###############################################################################
#
# DESCRIPTION :
# This test script verifies mounting a loop device in debian environment.
# This test script contains mount package check,mount filesystem check
# mount filesystem creation and unmounting image
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

echo "About to run mount package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#removing the created directoey and image
clean_up() {
	echo "Removing the directories"
	remove_tmp_dir
}

#display mount package
mount_package_check() {
	echo "check the existance of mount package"
	skip_list="mount_filesystem_check mount_filesystem_creation mount_loop_device mount_unmount_image"
	check_if_package_installed mount
	lava_test_result "mount_package_check" "${skip_list}"

}
#checking for EXT4 filesystem 
mount_filesystem_check() {
	echo "Check the existance of EXT4 filesystem on the system"
	skip_list="mount_filesystem_creation mount_loop_device mount_unmount_image"
	cat /proc/filesystems | grep -i ext4
	ret=$?
	if [ $ret -eq 0 ] ; then
		lava_test_result "mount_filesystem_check" "${skip_list}"
	else
		modprobe ext4
		cat /proc/filesystems | grep -i ext4
		lava_test_result "mount_filesystem_check" "${skip_list}"
	fi
}
#creating EXT4 filesystem to the image created
mount_filesystem_creation() {
	echo "Creating a filesystem on the Image" 
	skip_list="mount_loop_device mount_unmount_image"

	#create an image of size 50MB
	dd if=/dev/zero of=$QA_TMP_DIR/FSImg bs=1M count=50
	exit_on_step_fail "mount_filesystem_creation" "${skip_list}"

	#creating ext4 filesystem on FSImg
	mkfs.ext4 -t ext4 -F $QA_TMP_DIR/FSImg
	lava_test_result "mount_filesystem_creation" "${skip_list}"
}
#mounting loop device on the specified path
mount_loop_device() {
	echo "mounting the loop device"
	skip_list="mount_unmount_image "
	mount -o loop -t ext4 $QA_TMP_DIR/FSImg $QA_TMP_DIR
	mount | grep -i $QA_TMP_DIR/FSImg
	lava_test_result "mount_loop_device" "${skip_list}"
}
#unmounting the directory 
mount_unmount_image() {
	echo "unmounting the loop device"
	umount -d $QA_TMP_DIR
	lava_test_result "mount_unmount_image"
}
#main
#Function calls
create_tmp_dir
mount_package_check	
mount_filesystem_check
mount_filesystem_creation
mount_loop_device
mount_unmount_image
clean_up
