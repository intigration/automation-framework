#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Verify for ext2 filesystem support
# Verify ext2 support in /proc
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

#Importing kernel config API
. ../lib/sh-debian-lib

echo "About to run ext2 filesystem test..."

temp_dir="/tmp/ext2_test"

setup() {
	mkdir -p $temp_dir
}

cleanup() {
	cd
	umount -f $temp_dir/fs_ext2_mnt_pt
	rm -rf $temp_dir
}

# Verify ext2 filesystem support in kernel
kernel_config() {
	echo "Test EXT2 FS support in Kernel"
	skip_list="ext2_proc_support_test ext2_image_creation_test ext2_mount_check_test ext2_file_directory_creation_test ext2_symbolic_link_creation_test ext2_symbolic_link_deletion_test ext2_unmount_test"
	check_kernel_config CONFIG_EXT4_USE_FOR_EXT2
	if [ $? -eq 0 ]; then
		lava_test_result "ext2_kernel_support_test" "${skip_list}"
	else
		check_kernel_config CONFIG_EXT2_FS
		lava_test_result "ext2_kernel_support_test" "${skip_list}"
	fi
}

# Verify ext2 support in /proc
check_proc_support() {
	echo "Test ext2 fs support in /proc/filesystems"
	skip_list="ext2_image_creation_test ext2_mount_check_test ext2_file_directory_creation_test ext2_symbolic_link_creation_test ext2_symbolic_link_deletion_test ext2_unmount_test"
	cat /proc/filesystems | grep -i ext2
	lava_test_result "ext2_proc_support_test" "${skip_list}"
}

# Verify creation of ext2 filesystem block
create_image() {
	echo "Test ext2 image Creating"
	skip_list="ext2_mount_check_test ext2_file_directory_creation_test ext2_symbolic_link_creation_test ext2_symbolic_link_deletion_test ext2_unmount_test"
	cd $temp_dir
	dd bs=1M count=50 if=/dev/zero of=$temp_dir/FSImg
	exit_on_step_fail "ext2_image_creation_test" "${skip_list}"

	mkfs.ext2 -t ext2 -F $temp_dir/FSImg
	lava_test_result "ext2_image_creation_test" "${skip_list}"
}

# Verify mounting of ext2 file system image
mount_check() {
	echo "Test mount ext2 image partition"
	skip_list="ext2_file_directory_creation_test ext2_symbolic_link_creation_test ext2_symbolic_link_deletion_test ext2_unmount_test"
	cd $temp_dir
	mkdir $temp_dir/fs_ext2_mnt_pt
	mount -o loop -t ext2 $temp_dir/FSImg $temp_dir/fs_ext2_mnt_pt
	exit_on_step_fail "ext2_mount_check_test" "${skip_list}"

	mount | grep $temp_dir/FSImg | grep fs_ext2_mnt_pt
	lava_test_result "ext2_mount_check_test" "${skip_list}"
}

# Verify creation of text file / dir at mount point
file_directory_creation() {
	echo "Test a directory and file creation under mounted path"
	skip_list="ext2_symbolic_link_creation_test ext2_symbolic_link_deletion_test"
	cd $temp_dir/fs_ext2_mnt_pt

	# ------------- Directory creation.

	mkdir -p ext2_folder1/ext2_folder2

	# ------------- Test file creation.

	echo "This is test message to file1" > ext2_file1.txt
	echo "This is test message to file2" > ext2_folder1/ext2_file2.txt

	ls -l  ext2_folder1/ext2_file2.txt
	lava_test_result "ext2_file_directory_creation_test" "${skip_list}"

	# ------------- Link creation.
	echo "Test symbolic link creation of a file under mounted path"
	ln -s ext2_folder1/ext2_file2.txt testlink
	ls -l testlink | grep ext2_file2.txt
	lava_test_result "ext2_symbolic_link_creation_test" "${skip_list}"

	# ------------- Remove link.
	echo "Test symbolic link remove under mounted path"
	cd $temp_dir/fs_ext2_mnt_pt
	rm testlink
	lava_test_result "ext2_symbolic_link_deletion_test" "${skip_list}"
}

# Verify unmounting of ext2 filesystem image
unmount_check() {
	echo "Test unmount of ext2 image"
	cd
	umount -f $temp_dir/fs_ext2_mnt_pt
	lava_test_result "ext2_unmount_test"
}

# Main
cleanup
setup
kernel_config
check_proc_support
create_image
mount_check
file_directory_creation
unmount_check
cleanup




