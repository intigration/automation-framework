#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# kmod is a multi-call binary which implements the programs used to control Linux Kernel
# modules. Most users will only run it using its other names.
#
# Check the kmod package is available on target or not.
# Check kernel module info of a specific module.
# Check loading a kernel module to system.
# Check specfic kernel module loaded successfully on system
# Check deletion of any kernel module on system
#
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run kmod package test..."

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

MODULE_PATH="/lib/modules/$(uname -r)/extra"
# Check the kmod package is available on target or not.
kmod_package_check() {
	echo "Checking kmod package is available on target or not"
	skip_list="kmod_module_info_test kmod_module_insert_test kmod_module_load_test kmod_module_remove_test"
	check_if_package_installed kmod
	lava_test_result "kmod_package_check_test" "${skip_list}"
}

# Check the module existance and load if it is not there on system
kmod_module_check_and_load() {
	echo "Check the module existance and load if it is not there on system"
	lsmod | grep -i example_module
	ret=$?
	if [ $ret -eq 0 ]; then
	    echo "Remove specific module"
	    rmmod example_module
	    lava_test_result "kmod_module_remove_test"

	    echo "Insert a  specific module"
	    cd $MODULE_PATH
	    insmod example-module.ko
	    lava_test_result "kmod_module_insert_test"
	fi
}

# Check specfic kernel module loaded successfully on system
kmod_module_check() {
	echo "Checking specific kernel module loaded successfully on system or not"
	lsmod | grep -i "example_module"
	lava_test_result "kmod_module_load_test"
}

# Check kernel module info of a specific module
kmod_module_info() {
	echo "Checking kernel module information of a specific module"
	modinfo example_module
	lava_test_result "kmod_module_info_test"
}

# main
kmod_package_check
(kmod_module_check_and_load)
(kmod_module_check)
(kmod_module_info)

