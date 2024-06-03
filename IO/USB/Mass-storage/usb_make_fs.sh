#!/bin/bash

#######################################################################################
#
# Copyright (c) 2020-2021, Mentor, a Siemens business
#
# @file   : usb_make_fs.sh
#
# @brief  : This test script verifies to create filesystem on the particular USB type
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

#Importing the USB helper script
. USB/Mass-storage/usb_helper.sh

#Importing the LAVA libraries
. ../lib/sh-test-lib

#Create filesystem on the created partition"
echo "Formatting partition on identified USB devices"
#Create a filesystem on the created partition
usb_fs_creation() {
#Call the identifier script to identify the USBs
    usb_identifier
    for (( i=1 ; i<=$count ; i=i+1 ))
    do
        if [ `expr  $i % 2` -eq 0 ]; then
            if [ "${identifier_array_new[`expr $i - 1`]}" = "USB_3.0" ]; then
                echo "USB3.0 fdisk operation is started"
                usb_fdisk
                echo "$PARTITION"
                echo "Create a file system on the created partition"
                mkfs.ext4 /dev/$PARTITION
                lava_test_result "usb3.0_fs_creation"
            elif [ "${identifier_array_new[`expr $i - 1`]}" = "USB_2.0" ]; then
                echo "USB2.0 fdisk operation is started"
                usb_fdisk
                echo "$PARTITION"
                echo "Create a file system on the created partition"
                mkfs.ext4 /dev/$PARTITION
                lava_test_result "usb2.0_fs_creation"
            fi
        fi
    done
}
#Main
usb_fs_creation
