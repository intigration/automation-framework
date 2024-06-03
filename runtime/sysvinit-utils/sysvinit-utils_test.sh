#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# This test case verifies if sysvinit-utils package is available on target or not.
# Check for killall5 and pidof command on target side.
#
## Author:  Muhammad Farhan
#
###############################################################################

echo "About to run sysvinit-utils package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Check the sysvinit-utils package is available on target or not.
sysvinit_utils_package_check() {
	echo "Checking sysvinit-utils package is available on target or not"
	skip_list="sysvinit_utils_check_for_killall5 sysvinit_utils_check_for_pidof sysvinit_utils_init_daemon_check sysvinit_utils_init_folder_check"
        check_if_package_installed sysvinit-utils
	lava_test_result "sysvinit_utils_package_check_test" "${skip_list}"
}

# Check the killall5 command on target side.
sysvinit_utils_check_for_killall5() {
	echo "Checking the killall5 command on target side"
	which killall5
	lava_test_result "sysvinit_utils_check_for_killall5_test"
			
}

# Check the pidof command on target side.
sysvinit_utils_check_for_pidof() {
	echo "Checking the pidof command on target side"
	which pidof
	lava_test_result "sysvinit_utils_check_for_pidof_test"
			
}

# Check the init daemon on the target side
sysvinit_utils_init_daemon_check() {
	echo "Checking the init daemon running on the target side"
	ps -aef | grep -i init 
	lava_test_result "sysvinit_utils_check_for_init_daemon"

}

# Check the presence of init.d folder 
sysvinit_utils_init_folder_check() {
	echo "Checking the presence of init.d folder on the target side"
	ls -l /etc/init.d/ 
	lava_test_result "sysvinit_utils_check_presence_of_init.d"

}

#main
sysvinit_utils_package_check
(sysvinit_utils_check_for_killall5)
(sysvinit_utils_check_for_pidof)
(sysvinit_utils_init_daemon_check)
(sysvinit_utils_init_folder_check)

