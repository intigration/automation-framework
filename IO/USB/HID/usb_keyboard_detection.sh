#!/bin/sh

#######################################################################################
#
# Copyright (c) 2020-2021, Mentor, a Siemens business
#
# @file   : usb_keyboard_detection.sh
#
# @brief  : Check usb keyboard detection and event check on the target
#
# @Return : 0 for success and non zero for fail
#######################################################################################
#
# Revision History:
#
#  Author                               Modification Date      Description of Changes
# -------------------------             ----------------       ------------------------
# Sarath P T  <sarath_pt@mentor.com>    27-08-2021             Initial version
#
#######################################################################################

echo "About to run usb keyboard test..."
# Importing LAVA libraries
. ../lib/sh-test-lib

#check the keyboard connected to target using dmesg
usb_keyboard_detection() {
	echo "check the keyboard connected to target using dmesg"
	dmesg | grep -i "usb" | grep -i "keyboard"
	lava_test_result "usb_keyboard_detection"
}

#List out the events generated for keyboard
usb_keyboard_event_check() {
	echo "List out the events generated for keyboard"
	ls -l /dev/input | grep -i event
	lava_test_result "usb_keyboard_event_check"
}

#Main
usb_keyboard_detection
usb_keyboard_event_check
