#!/bin/bash

#######################################################################################
# 
# Copyright (c) 2020-2021, Mentor, a Siemens business
#
# @file   : usb_detection.sh
#
# @brief  : Check usb mass storage detection on the target
#
# @Return : 0 for success and non zero for fail
#######################################################################################
#
# Revision History:
#
#  Author                               Modification Date      Description of Changes
# -------------------------             ----------------       ------------------------
# Sarath P T  <sarath_pt@mentor.com>    27-08-2021             changed test-case names
#
#######################################################################################

#Imporing USB helper script
. USB/Mass-storage/usb_helper.sh

#Importing LAVA libraries
. ../lib/sh-test-lib

#Function for usb detection on the target
usb_detection() {
	#Calling the function for identifying the device types
	usb_identifier
	for (( i=1 ; i<=$count ; i=i+1))
	do
		#Comparing the even places of array to the USB device type
		if [ `expr  $i % 2` -eq 0 ]; then
			if [ "${identifier_array_new[`expr $i - 1`]}" = "USB_3.0" ]; then
				#Storing the adjacent left element to a variable
				DEV_PORT=${identifier_array_new[`expr $i - 2`]}
				echo "device port detected for USB_3.0"
				fdisk -l | grep -i $DEV_PORT[0-9]
				lava_test_result "usb3.0_detection"
			elif [ "${identifier_array_new[`expr $i - 1`]}" = "USB_2.0" ]; then
				#Storing the adjacent left element to a variable
				DEV_PORT=${identifier_array_new[`expr $i - 2`]}
				echo "device port detected for USB_2.0"
				fdisk -l | grep -i $DEV_PORT[0-9]
				lava_test_result "usb2.0_detection"
			fi
		fi

	done
}

#Main
usb_detection

