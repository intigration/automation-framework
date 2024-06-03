#!/bin/bash
## Author Muhammad Farhan

#Import USB helper script
. USB/Mass-storage/usb_helper.sh

#Import LAVA libraries
. ../lib/sh-test-lib

FILE_PATH=/tmp
TEST_FILE=test_file
TEST_DIR=/tmp/test_dir

#Clean the directories created and unmount the USB device
clean_up() {
	umount -d $MNT_PATH
	rm -rf $MNT_PATH
	rm -rf $FILE_PATH/$TEST_FILE
	rm -rf $TEST_DIR
}

#Create a directories
set_up() {
	mkdir $MNT_PATH
	mkdir $TEST_DIR
}

#Function for copying a file from
test_file_copy() {
	DEV_PORT=${identifier_array_new[`expr $i - 2`]}
	PARTITION=`ls /dev | grep -i $DEV_PORT[0-9]`

	echo "clean up function is executing"
	clean_up

	echo "directory  is creating "
	set_up
	echo "mount the device partition to defined path"
	mount /dev/$PARTITION $MNT_PATH
	exit_on_step_fail "usb_mount_check_usb"

	echo "Create a test file of size 100MB"
	dd if=/dev/zero of=$FILE_PATH/$TEST_FILE bs=1M count=100
	exit_on_step_fail "test_file_creation_usb"

	echo "Copy test file to mounted directory"
	cp $FILE_PATH/$TEST_FILE $MNT_PATH
	ls -l $MNT_PATH/$TEST_FILE
	exit_on_step_fail "usb_copy_testlfile_to_usb"

	echo "Copy test file from USB to SSD"
	cp $MNT_PATH/$TEST_FILE $TEST_DIR
	ls -l $TEST_DIR/$TEST_FILE
	exit_on_step_fail "usb_copy_testfile_to_ssd_usb"

	echo "Unmount the directory"
	clean_up
}

#Function for copying the file
usb_test_file_copy() {
	echo "Calling the function for formatting the USB devices"
	usb_make_fs
	for (( i=1 ; i<=$count ; i=i+1))
	do
		if [ `expr  $i % 2` -eq 0 ]; then
			if [ "${identifier_array_new[`expr $i - 1`]}" = "USB_3.0" ]; then
				echo "Calling the function for copying file test-case"
				test_file_copy
				lava_test_result "usb3.0_copy_testfile"

			elif [ "${identifier_array_new[`expr $i - 1`]}" = "USB_2.0" ]; then
				echo "Calling the function for copying file test-case"
				test_file_copy
				lava_test_result "usb2.0_copy_testfile"
			fi
		fi
	done
}

#Main
usb_test_file_copy






