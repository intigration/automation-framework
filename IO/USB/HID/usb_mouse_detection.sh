#!/bin/sh

#######################################################################################
#
# Author:  Muhammad Farhan
#
# @file   : usb_mouse_detection.sh
#
# @brief  : Check usb mouse detection and event check on target 
#
# @Return : 0 for success and non zero for fail
#######################################################################################
#
# Revision History:
#
#  Author                               Modification Date      Description of Changes
# -------------------------             ----------------       ------------------------
# # Author:  Muhammad Farhan   27-08-2021             changed test-case name
#
#######################################################################################

echo "About to run usb mouse test..."
# Importing LAVA libraries
. ../lib/sh-test-lib

#check the mouse connected to target using dmesg
usb_mouse_detetcion_check() {
	echo "check the mouse connected to target using dmesg"
	dmesg | grep -i "usb" | grep -i "mouse"
	lava_test_result "usb_mouse_detection_check"
}

#List out the events for mouse
usb_mouse_event_check() {
	echo "List out the events for mouse"
	ls -l /dev/input | grep -i mouse
	lava_test_result "usb_mouse_event_check"
}

#Main
usb_mouse_detetcion_check
usb_mouse_event_check

