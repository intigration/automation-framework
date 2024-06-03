#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Verify for Iozone support of ext2 filesystem
#
 Author: Muhammad Farhan
#
###############################################################################

#Importing Lava libraries
. ../lib/sh-test-lib

echo "About to run ext2 filesystem Iozone test..."

temp_dir="/tmp/ext2_iozone"

setup() {
	# Check iozone binary availability on target
	which iozone
	ret=$?
	if [ $ret -eq 0 ]; then
		echo "Iozone binary is available on target"
	else
		echo "Iozone binary is missing on target"
		exit 1
	fi
	mkdir -p $temp_dir
}

cleanup() {
	cd /
	mount | grep $temp_dir/FSImg | grep fs_ext2_mnt_pt
	ret=$?
	if [ $ret -eq 0 ]; then
		umount -f $temp_dir/fs_ext2_mnt_pt
	fi
	rm -rf $temp_dir
}

#Description: Creates an ext2 image.
create_image() {
	skip_list="ext2_iozone_mount_image ext2_iozone_stress"
	dd bs=10M count=50 if=/dev/zero of=$temp_dir/FSImg
	exit_on_step_fail "ext2_iozone_image_creation" "${skip_list}"

	mkfs.ext2 -t ext2 -L ext2_part -F $temp_dir/FSImg
	lava_test_result "ext2_iozone_image_creation" "${skip_list}"
}

#Description: Mounts ext2 image partition.
mount_check() {
	skip_list="ext2_iozone_stress"
	mkdir $temp_dir/fs_ext2_mnt_pt
	mount -o loop -t ext2 $temp_dir/FSImg $temp_dir/fs_ext2_mnt_pt
	exit_on_step_fail "ext2_iozone_mount_image" "${skip_list}"

	mount | grep $temp_dir/FSImg | grep fs_ext2_mnt_pt
	lava_test_result "ext2_iozone_mount_image" "${skip_list}"
}

# Stress test on ext2 file system partition using iozone
iozone_test() {
	echo " Execute Stress test on ext2 file system partition using iozone"
	cd $temp_dir/fs_ext2_mnt_pt
	iozone -s256m -r128 -i 0 -i 1 -t 1
	lava_test_result "ext2_iozone_stress" "${skip_list}"
}

# Main
setup
create_image
mount_check
iozone_test
cleanup
