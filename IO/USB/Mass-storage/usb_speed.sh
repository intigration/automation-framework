#!/bin/bash

#######################################################################################
#
# Copyright (c) 2020-2021, Mentor, a Siemens business
#
# @file   : usb_speed.sh
#
# @brief  : This test script verifies USB speed tests on the target
#
# @Return : 0 for success and non zero for fail
#######################################################################################
#
# Revision History:
#
#  Author                               Modification Date      Description of Changes
# -------------------------             ----------------       ------------------------
# Sarath P T  <sarath_pt@mentor.com>    27-08-2021             Changed test-cases names
#
#######################################################################################

#Importing USB helper script
. USB/Mass-storage/usb_helper.sh

#Importing LAVA libraries
. ../lib/sh-test-lib

TEST_IMAGE=test_image
TEST_PATH=/tmp
TEST_DIR=/tmp/test_dir

#Clean up the created directories,files and unmount the device
clean_up() {
	umount -d $MNT_PATH
	rm -rf $MNT_PATH
	rm -rf $TEST_DIR
	rm -rf $TEST_PATH/$TEST_IMAGE
}

#Function for copying a test_image and check its speed
speed_test() {
	DEV_PORT=${identifier_array_new[`expr $i - 2`]}
	PARTITION=`ls /dev | grep -i $DEV_PORT[0-9]`
	echo $PARTITION
	clean_up
	exit_on_step_fail "clean_up"
	mkdir $MNT_PATH
	exit_on_step_fail "mount_point_created"
	echo "mount the device partition to defined path"
	mount /dev/$PARTITION $MNT_PATH
	exit_on_step_fail "device_mounted"

	echo "Create a test_image of size 50MB"
	dd if=/dev/zero of=$TEST_PATH/$TEST_IMAGE bs=1M count=50
	exit_on_step_fail "image_created"

	echo "copy the image to mounted directory"
	rsync --progress $TEST_PATH/$TEST_IMAGE $MNT_PATH
	exit_on_step_fail "speed_test_to_usb"

	echo "Copy image from USB to target root path"
	rsync --progress $MNT_PATH/$TEST_IMAGE $TEST_DIR
	exit_on_step_fail "speed_test_from_target_root_usb"

	clean_up
	exit_on_step_fail "clean_up"
}

#Function for copying a test_image to USB , vice versa and check its speed
usb_speed_test() {
	echo "Calling the function for formatting the USB device type"
	usb_make_fs
	for (( i=1 ; i<=$count ; i=i+1))
	do
		if [ `expr  $i % 2` -eq 0 ]; then
			if [ "${identifier_array_new[`expr $i - 1`]}" = "USB_3.0" ]; then
				echo "Call the speed test function"
				speed_test
				lava_test_result "usb3.0_speed_test"

			elif [ "${identifier_array_new[`expr $i - 1`]}" = "USB_2.0" ]; then
				echo "Call the speed test function"
				speed_test
				lava_test_result "usb2.0_speed_test"
			fi
		fi

	done
}

#Main
usb_speed_test


