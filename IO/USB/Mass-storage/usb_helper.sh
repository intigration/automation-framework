#!/bin/sh

## Author Muhammad Farhan

#Importing LAVA libraries
. ../lib/sh-test-lib

#Test to identify which usb device is connected
DEV_ID=2.00
MNT_PATH=/tmp/mnt_pnt1
FILE_PATH=/tmp
clean_up() {
	umount -d $MNT_PATH
	rm -rf $MNT_PATH
}

#Function for identifying the USB types
usb_identifier() {
	#Listing the device ports detected in the target
	LIST_DEV_PORTS=`grep -Hv ^0$ /sys/block/*/removable | sed 's/removable:.*$/size/' | xargs grep -Hv '^0$' | cut -d / -f '4'`
	boot_media=`mount | sed -n '6p' | cut -d "/" -f3 | cut -d " " -f1 | sed 's/.$//'`
	COUNT=`grep -Hv ^0$ /sys/block/*/removable | sed 's/removable:.*$/size/' | xargs grep -Hv '^0$' | cut -d / -f '4' | wc -l`
	identifier_array=()
	if [ $COUNT -ne 0 ]; then
		for i in $LIST_DEV_PORTS
		do
			identifier_array+=($i)
			for del in $boot_media
			do
				array=("${identifier_array[@]/$del}")
				echo "${array[@]}"
			done
		done
	else
		echo "No USB device connected to the system"
	fi
	identifier_array_new=()
	for i in ${array[@]}
	do
		identifier_array_new+=($i)
		udevadm info -a -n $i | grep 'ATTRS{vendor}' | head -1 | cut -d '=' -f3 | tr -d ' '
		ret=$?
		if [ $ret -eq 0 ]; then
			echo "manufacurer name displayed successfully"
		else
			echo "Not able to display the manufacturer names"
		fi

		SYS_ID=`udevadm info -a -n $i | grep 'looking at parent device' | head -1 | cut -d '/' -f8 | cut -d ':' -f1`
		DEV_TYPE_ID=`cat /sys/bus/usb/devices/$SYS_ID/version | tr -d ' ' `
		if [ $DEV_TYPE_ID = $DEV_ID ]; then
			TYPE_ID=USB_2.0

		else
			TYPE_ID=USB_3.0
		fi
		identifier_array_new+=($TYPE_ID)
	done

	VAR=${identifier_array_new[@]}
	count=${#identifier_array_new[@]}
}

#Create a filesystem on the created partition
usb_make_fs() {
	#Call the identifier script to identify the USBs
	usb_identifier
	for (( i=1 ; i<=$count ; i=i+1))
	do
		if [ `expr  $i % 2` -eq 0 ]; then
			if [ "${identifier_array_new[`expr $i - 1`]}" = "USB_3.0" ]; then
				echo "USB fdisk operation is started"
				usb_fdisk
				echo "$PARTITION"
				echo "Create a file system on the created partition"
				mkfs.ext4 /dev/$PARTITION
				exit_on_step_fail "usb3.0_fs_creation"
			elif [ "${identifier_array_new[`expr $i - 1`]}" = "USB_2.0" ]; then
				echo "USB fdisk operation is started"
				usb_fdisk
				echo "$PARTITION"
				echo "Create a file system on the created partition"
				mkfs.ext4 /dev/$PARTITION
				exit_on_step_fail "usb2.0_fs_creation"
			fi
		fi
	done
}

#Function for formatting the device partition
usb_fdisk() {
	#Identifying the device port from the array
	DEV_PORT=${identifier_array_new[`expr $i - 2`]}
	PARTITION=`ls /dev | grep -i $DEV_PORT[0-9]`
	echo $PARTITION
	echo "Unmount the existing mounted directories"

	clean_up
	mkdir $MNT_PATH

	/usr/bin/expect << EOF
	set timeout 10
	spawn fdisk /dev/$DEV_PORT
	expect "(m for help):"
	send "d\r"
	expect "(m for help):"
	send "n\r"
	expect "(default p):"
	send "p\r"
	expect "(1-4, default 1):"
	send "1\r"
	expect "(2048-30463999, default 2048):"
	send "2048\r"
	expect "(2048-30463999, default 30463999):"
	send "2176000\r"
	expect ":"
	send "Y\r"
	expect "(m for help):"
	send "w\r"
	expect eof
EOF
	exit_on_step_fail "usb_fdsik_test"
}





