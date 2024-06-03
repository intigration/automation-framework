#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#This package contains helper tools that are necessary for switching between the various init systems that Debian contains (e. g. sysvinit or systemd).
#It also includes the "service", "invoke-rc.d", and "update-rc.d" scripts which provide an abstraction for enabling, disabling, starting, and stopping services
#
# Check the init-system-helpers package is available on target or not.
# Check the list of binary provided by init-system-helpers package 
# Checking init program running on target
# Checking list of system service status using service tool
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run init-system-helpers package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib
	
# Check the init-system-helpers package is available on target or not.
package_check() {
	echo "Checking init-system-helpers package is available on target or not"
	skip_list="init-system-helpers_binary_check init-system-helpers_init_pid_check init-system-helpers_service_status_check"
	dpkg -l | grep -i "init-system-helpers"
	lava_test_result "init-system-helpers_package_check" "${skip_list}"
}

# Check the list of binary provided in init-system-helpers package
binary_check() {
	echo "Checking the list of binary provided by init-system-helpers package"
	which deb-systemd-helper deb-systemd-invoke invoke-rc.d service update-rc.d
	lava_test_result "init-system-helpers_binary_check"
}

# Checking init program pid on target
init_check() {
	echo "Checking init program pid on target"
	if [ `pidof init` = "1" ]; then
	
		lava_test_result "init-system-helpers_init_pid_check"
	fi
}

# Checking list of system service status using service tool
service_check() {
	echo "Checking list of system service running on target using service tool"
	service --status-all
	lava_test_result "init-system-helpers_service_status_check"
}


#main
package_check
(binary_check)
(init_check)
service_check
