#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# This test case verifies if snmpd package is available on target or not.
# Also check the service status of snmpd along with the snmpd-daemon 
# process status.
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run snmpd package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Check the snmpd package is available on target or not.
snmpd_package_check() {
	echo "Checking snmpd package is available on target or not"
	skip_list="snmpd_service_status_check_test snmpd_daemon_process_status_check_test"
	check_if_package_installed snmpd
	lava_test_result "snmpd_package_check_test"
}

#snmpd service status Check
snmpd_service_status_check() {
	skip_list="snmpd_daemon_process_status_check"
	echo "Testing snmpd service status..."
	systemctl status snmpd.service | grep -i "running"
	lava_test_result "snmpd_service_status_check_test" "${skip_list}"
	
}

#snmpd-daemon process status Check
snmpd_daemon_process_status_check() {
	echo "Testing snmpd-daemon process status..."
	ps -aef | grep -i "snmpd-daemon"	 
	lava_test_result "snmpd_daemon_process_status_check_test"                   
}

#main
snmpd_package_check
(snmpd_service_status_check)
snmpd_daemon_process_status_check
