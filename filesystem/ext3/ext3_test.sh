#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Verify ext3 support in /proc
# Verify creation of ext2 filesystem block
# Verify mounting of ext2 filesystem image
# Verify creation of text file / dir at mount point
# Verify unmounting of ext2 filesystem image
#
 Author: Muhammad Farhan
#
###############################################################################

#Importing Lava libraries
. ../lib/sh-test-lib

echo "About to run ext3 filesystem test..."

temp_dir="/tmp/ext3_test"

setup() {
	mkdir -p $temp_dir
}

cleanup() {
	cd /
	umount -f $temp_dir/fs_ext3_mnt_pt
	rm -rf $temp_dir
}

# Verify ext3 support in /proc
check_proc_support() {
	echo "Test ext3 fs support in /proc/filesystems"
	skip_list="ext3_image_creation_test ext3_mount_check_test ext3_file_directory_creation_test ext3_symbolic_link_creation_test ext3_symbolic_link_deletion_test ext3_unmount_test"
	cat /proc/filesystems | grep -i ext3
	lava_test_result "ext3_proc_support_test" "${skip_list}"
}

# Verify creation of ext3 filesystem block
create_image() {
	echo "Test ext3 image Creating"
	skip_list="ext3_mount_check_test ext3_file_directory_creation_test ext3_symbolic_link_creation_test ext3_symbolic_link_deletion_test ext3_unmount_test"
	cd $temp_dir
	dd bs=1M count=50 if=/dev/zero of=$temp_dir/FSImg
	exit_on_step_fail "ext3_image_creation_test" "${skip_list}"

	mkfs.ext3 -t ext3 -F $temp_dir/FSImg
	lava_test_result "ext3_image_creation_test" "${skip_list}"
}

# Verify mounting of ext3 file system image
mount_check()	{
	echo "Test mount ext3 image partition"
	skip_list="ext3_file_directory_creation_test ext3_symbolic_link_creation_test ext3_symbolic_link_deletion_test ext3_unmount_test"
	cd $temp_dir
	mkdir $temp_dir/fs_ext3_mnt_pt
	mount -o loop -t ext3 $temp_dir/FSImg $temp_dir/fs_ext3_mnt_pt
	exit_on_step_fail "ext3_mount_check_test" "${skip_list}"

	mount | grep $temp_dir/FSImg | grep fs_ext3_mnt_pt
	lava_test_result "ext3_mount_check_test" "${skip_list}"
}

# Verify creation of text file / dir at mount point
file_directory_creation() {
	echo "Test a directory and file creation under mounted path"
	skip_list="ext3_symbolic_link_creation_test ext3_symbolic_link_deletion_test"
	cd $temp_dir/fs_ext3_mnt_pt

	# ------------- Directory creation.

	mkdir -p ext3_folder1/ext3_folder2

	# ------------- Test file creation.

	echo "This is test message to file1" > ext3_file1.txt
	echo "This is test message to file2" > ext3_folder1/ext3_file2.txt

	ls -l  ext3_folder1/ext3_file2.txt
	lava_test_result "ext3_file_directory_creation_test" "${skip_list}"

	# ------------- Link creation.
	echo "Test symbolic link creation of a file under mounted path"
	ln -s ext3_folder1/ext3_file2.txt testlink
	ls -l testlink | grep ext3_file2.txt
	lava_test_result "ext3_symbolic_link_creation_test" "${skip_list}"

	# ------------- Remove link.
	echo "Test symbolic link remove under mounted path"
	cd $temp_dir/fs_ext3_mnt_pt
	rm testlink
	lava_test_result "ext3_symbolic_link_deletion_test" "${skip_list}"
}

# Verify unmounting of ext3 filesystem image
unmount_check()	{
	echo "Test unmount of ext3 image"
	cd /
	umount -f $temp_dir/fs_ext3_mnt_pt
	lava_test_result "ext3_unmount_test"
}

# Main
cleanup
setup
check_proc_support
create_image
mount_check
file_directory_creation
unmount_check
cleanup

