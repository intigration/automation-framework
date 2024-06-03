#!/bin/bash
###############################################################################
#
# DESCRIPTION :
# Verify tmpfs filesystem support in kernel
# Verify tmpfs mount by-default
# Verify tmpfs resize
# Verify speed check in /home and /tmpfs
# Verify file copy check in /home and /tmpfs
#
# Note: time is a special builtin for bash,but not for dash. For that reason,
#       this script is writen in bash shell rather than posix sh
#
 Author: Muhammad Farhan
#
###############################################################################

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing kernel config API
. ../lib/sh-debian-lib

echo "About to run tmpfs filesystem test..."

temp_dir="/tmp/tmpfs_test"

setup() {
	mkdir -p $temp_dir
}

cleanup() {
	cd
	mount | grep $temp_dir
	ret=$?
	if [ $ret -eq 0 ]; then
		umount -f $temp_dir
	fi
	rm -rf $temp_dir
}

# Verify tmpfs filesystem support in kernel
kernel_config() {
	echo "Test tmp FS support in Kernel"
	check_kernel_config CONFIG_TMPFS
	lava_test_result "tmpfs_kernel_support"
}

# Verify tmpfs mount by-default
mount_check() {
	echo "Checking tmpfs mount "
	mount | grep tmpfs
	lava_test_result "tmpfs_default_mount_check"
}

# Verify tmpfs resize
resize_check() {
	echo "Test tmpfs rezize usecase"
	echo "mount tmpfs with size 20M"
	mount -t tmpfs -o size=20m tmpfs $temp_dir
	exit_on_step_fail "tmpfs_mount_pt_size_check"

	df -h | grep -i "$temp_dir" | grep -i '20M'
	lava_test_result "tmpfs_mount_pt_size_check"

	echo "Resize tmpfs size to 40M"
	mount -o remount,size=40M tmpfs $temp_dir
	exit_on_step_fail "tmpfs_resize_check"

	df -h | grep -i "$temp_dir" | grep -i '40M'
	lava_test_result "tmpfs_resize_check"
}

# Verify speed check in /home and /tmpfs
speed_check() {
	echo "Speed check test of /tmp and /home"
	echo "Calculate speed of file creation in /home/root"
	cd ~
	tHome="$(time ( dd if=/dev/zero of=tmpfs.img bs=1M count=50 &>/dev/null ) 2>&1 1>/dev/null )"
	t1="$(echo $tHome | awk '{print $2}')"

	rm tmpfs.img

	echo "Calculate speed of file creation in tmpfs"
	cd $temp_dir
	tTmp="$(time  ( dd if=/dev/zero of=tmpfs.img bs=1M count=50 &>/dev/null ) 2>&1 1>/dev/null )"
	t2="$(echo $tTmp | awk '{print $2}')"

	rm tmpfs.img

	echo "Time taken at home dir is $t1"
	echo "Time taken at temp dir is $t2"

	if [[ $t2 < $t1 ]]; then
		lava_test_result "tmpfs_speed_check"
	fi
}

# Verify file copy check in /home and /tmpfs
copy_check() {
	echo "Copy check test in /tmp/ and /home"
	cd ~
	dd if=/dev/zero of=tmpfs.img bs=1M count=50
	ret=$?
	if [ $ret -ne 0 ]; then
		echo  "Unable to create image"
		exit
	fi

	echo "Calculate speed of file creation in /home"
	tHome="$(time ( cp tmpfs.img tmpfs.img2 &>/dev/null ) 2>&1 1>/dev/null )"
	t1="$(echo $tHome | awk '{print $2}')"

	echo "Calculate speed of file creation in tmpfs"
	cd $temp_dir
	tTmp="$(time ( cp ~/tmpfs.img tmpfs.img2 &>/dev/null) 2>&1 1>/dev/null )"
	t2="$( echo $tTmp | awk '{print $2}')"

	echo "Time taken at home dir is $t1"
	echo "Time taken at temp dir is $t2"

	if [[ $t2 < $t1 ]]; then
		lava_test_result "tmpfs_copy_speed_check"
	fi

	rm tmpfs.img tmpfs.img2
	cd ~
	rm tmpfs.img tmpfs.img2
}

# Main
setup
(kernel_config)
(mount_check)
(resize_check)
(speed_check)
(copy_check)
cleanup
