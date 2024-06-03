#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Verify for ext4 filesystem support in kernel
# Verify ext4 support in /proc
# Verify creation of ext4 filesystem block
# Verify mounting of ext4 filesystem image
# Verify creation of text file / dir at mount point
# Verify unmounting of ext4 filesystem image
#
 Author: Muhammad Farhan
#
###############################################################################

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing kernel config API
. ../lib/sh-debian-lib

echo "About to run ext4 filesystem test..."

temp_dir="/tmp/ext4_test"

setup() {
	mkdir -p $temp_dir
}

cleanup() {
	cd
	umount -f $temp_dir/fs_ext4_mnt_pt
	rm -rf $temp_dir
}

# Verify ext4 filesystem support in kernel
kernel_config() {
	echo "Test EXT4 FS support in Kernel"
	skip_list="ext4_proc_support_test ext4_image_creation_test ext4_mount_check_test ext4_file_directory_creation_test ext4_symbolic_link_creation_test ext4_symbolic_link_deletion_test ext4_unmount_test"
	check_kernel_config CONFIG_EXT4_FS
	lava_test_result "ext4_kernel_support_test" "${skip_list}"
}

# Verify ext4 support in /proc
check_proc_support() {
	echo "Test ext4 fs support in /proc/filesystems"
	skip_list="ext4_image_creation_test ext4_mount_check_test ext4_file_directory_creation_test ext4_symbolic_link_creation_test ext4_symbolic_link_deletion_test ext4_unmount_test"
	cat /proc/filesystems | grep -i ext4
	lava_test_result "ext4_proc_support_test" "${skip_list}"
}

# Verify creation of ext4 filesystem block
create_image() {
	echo "Test ext4 image Creating"
	skip_list="ext4_mount_check_test ext4_file_directory_creation_test ext4_symbolic_link_creation_test ext4_symbolic_link_deletion_test ext4_unmount_test"
	cd $temp_dir
	dd bs=1M count=50 if=/dev/zero of=$temp_dir/FSImg
	exit_on_step_fail "ext4_image_creation_test" "${skip_list}"

	mkfs.ext4 -t ext4 -L ext4_part -F $temp_dir/FSImg
	lava_test_result "ext4_image_creation_test" "${skip_list}"
}

# Verify mounting of ext4 file system image
mount_check() {
	echo "Test mount ext4 image partition"
	skip_list="ext4_file_directory_creation_test ext4_symbolic_link_creation_test ext4_symbolic_link_deletion_test ext4_unmount_test"
	cd $temp_dir
	mkdir $temp_dir/fs_ext4_mnt_pt
	mount -o loop -t ext4 $temp_dir/FSImg $temp_dir/fs_ext4_mnt_pt
	exit_on_step_fail "ext4_mount_check_test" "${skip_list}"

	mount | grep $temp_dir/FSImg | grep fs_ext4_mnt_pt
	lava_test_result "ext4_mount_check_test" "${skip_list}"
}

# Verify creation of text file / dir at mount point
file_directory_creation() {
	echo "Test a directory and file creation under mounted path"
	skip_list="ext4_symbolic_link_creation_test ext4_symbolic_link_deletion_test"
	cd $temp_dir/fs_ext4_mnt_pt

	# ------------- Directory creation.
	mkdir -p ext4_folder1/ext4_folder2

	# ------------- Test file creation.
	echo "This is test message to file1" > ext4_file1.txt
	echo "This is test message to file2" > ext4_folder1/ext4_file2.txt
	ls -l  ext4_folder1/ext4_file2.txt
	lava_test_result "ext4_file_directory_creation_test" "${skip_list}"

	# ------------- Link creation.
	echo "Test symbolic link creation of a file under mounted path"
	ln -s ext4_folder1/ext4_file2.txt testlink
	ls -l testlink | grep ext4_file2.txt
	lava_test_result "ext4_symbolic_link_creation_test" "${skip_list}"

	# ------------- Remove link.
	echo "Test symbolic link remove under mounted path"
	cd $temp_dir/fs_ext4_mnt_pt
	rm testlink
	lava_test_result "ext4_symbolic_link_deletion_test" "${skip_list}"
}

# Verify unmounting of ext4 filesystem image
unmount_check() {
	echo "Test unmount of ext4 image"
	cd
	umount -f $temp_dir/fs_ext4_mnt_pt
	lava_test_result "ext4_unmount_test"
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




