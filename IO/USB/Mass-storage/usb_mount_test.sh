#!/bin/bash

## Author Muhammad Farhan

#Importing USB helper script
. USB/Mass-storage/usb_helper.sh

#Importing LAVA libraries
. ../lib/sh-test-lib

#Creat the directories
set_up() {
	mkdir $MNT_PATH
}

#Clean the created directories and unmounting the device
clean_up() {
	umount -d $MNT_PATH
	rm -rf $MNT_PATH
}

#Funtion for mounting the device in a defined path
mount_test() {
	#Shifting the array element to get the device port of the particular USB type
	DEV_PORT=${identifier_array_new[`expr $i - 2`]}
	#Storing the device partion to a variable
	FDISK_PART=`fdisk -l | grep -i $DEV_PORT[0-9] | awk 'FNR == 1 {print $1}'`
	clean_up
	set_up
	mount $FDISK_PART $MNT_PATH
	mount | grep -i $MNT_PATH
	clean_up
}

#mount the detected device ports
usb_mount_test() {
	#Calling USB identifier function from the helper script
	usb_identifier
	for (( i=1 ; i<=$count ; i=i+1))
	do
		#Comparing the even places of array element with the USB device type
		if [ `expr  $i % 2` -eq 0 ]; then
			if [ "${identifier_array_new[`expr $i - 1`]}" = "USB_3.0" ]; then
				echo "Calling the function for mounting the device in a defined path"
				mount_test
				lava_test_result "usb3.0_mount_test"
			elif [ "${identifier_array_new[`expr $i - 1`]}" = "USB_2.0" ]; then
				echo "Calling the function for mounting the device in a defined path"
				mount_test
				lava_test_result "usb2.0_mount_test"
			fi
		fi
	done
}

#Main
usb_mount_test


