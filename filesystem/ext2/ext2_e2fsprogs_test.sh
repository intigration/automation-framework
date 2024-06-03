#!/bin/sh
###############################################################################
#
# DESCRIPTION :

# Test if mke2fs (package e2fsprogs) can create a ext2 filesystem on a loop device
# Test badblocks (package e2fsprogs) can search in a ext2 filesystem on a loop device
# Test if debugfs (package e2fsprogs) can run a command request in read-write mode.
# Test if fsck.ext2 (package e2fsprogs) can check a filesystem on a loop device in read-only mode.
# Test if tune2fs (package e2fsprogs) can list the filesystem superblock.

 # Author:  Muhammad Farhan
#
###############################################################################

#Importing Lava libraries
. ../lib/sh-test-lib

echo "About to run ext2 mke2fs test..."

temp_dir="/tmp/test_mke2fs"

setup() {
	mkdir -p $temp_dir
}

# Test if mke2fs (package e2fsprogs) can create a ext2 filesystem on a loop device
ext2_mke2fs() {

	#----------------------Creating an image
	echo "mke2fs (package e2fsprogs) can create a ext2 filesystem on a loop device"
	skip_list="ext2_mke2fs_mount_image ext2_badblocks_check ext2_debugfs_read-write_check ext2_fsck_loop_device_check ext2_tune2fs_check"
	cd $temp_dir
	dd if=/dev/zero of=$temp_dir/myDisk.img bs=1M count=50
	exit_on_step_fail "ext2_mke2fs_image_creation" "${skip_list}"

	#----------------------Format the image
	mount
	lsof -n | grep loop*
	loopDev=$(losetup -f)
	if [ "$loopDev" = "" ]; then
		exit_on_step_fail "ext2_mke2fs_image_creation" "${skip_list}"
		exit -1
	fi

	losetup $loopDev $temp_dir/myDisk.img
	exit_on_step_fail "ext2_mke2fs_image_creation" "${skip_list}"

	mke2fs -F -vm0 $loopDev 2048
	lava_test_result "ext2_mke2fs_image_creation" "${skip_list}"

	mkdir $temp_dir/virtual

	#----------------------Mount the image
	mount -o loop $temp_dir/myDisk.img $temp_dir/virtual
	lava_test_result "ext2_mke2fs_mount_image" "${skip_list}"
}

# Test badblocks (package e2fsprogs) can search in a ext2 filesystem on a loop device
check_badblocks() {
	echo "badblocks (package e2fsprogs) can search in a ext2 filesystem on a loop device"
	badblocks -v $loopDev 2048
	lava_test_result "ext2_badblocks_check" "${skip_list}"
}

# Test if debugfs (package e2fsprogs) can run a command request in read-write mode.
check_debugfs() {
	echo "debugfs (package e2fsprogs) can run a command request in read-write mode"
	debugfs -w -R ls $loopDev > /dev/null
	lava_test_result "ext2_debugfs_read-write_check" "${skip_list}"
}

# Test if fsck.ext2 (package e2fsprogs) can check a filesystem on a loop device in read-only mode.
check_fsck() {
	echo "fsck.ext2 (package e2fsprogs) can check a filesystem on a loop device in read-only mode."
	fsck.ext2 -nfv $loopDev
	lava_test_result "ext2_fsck_loop_device_check" "${skip_list}"
}

# Test if tune2fs (package e2fsprogs) can list the filesystem superblock.
check_tune2fs() {
	echo "tune2fs (package e2fsprogs) can list the filesystem superblock."
	tune2fs -l $loopDev
	lava_test_result "ext2_tune2fs_check" "${skip_list}"
}

cleanup() {
	cd /
	if [ "$loopDev" != "" ]; then
		losetup -d $loopDev
	fi

	mount | grep $temp_dir/myDisk.img
	ret=$?
	if [ $ret -eq 0 ]; then
		umount -f $temp_dir/virtual
	fi
	rm -rf $temp_dir
}

# Main
setup
ext2_mke2fs
check_badblocks
check_debugfs
check_fsck
check_tune2fs
cleanup

