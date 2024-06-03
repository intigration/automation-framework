#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Test scripts check if systemd is installed on target
# Check systemd version installed on target
# Check list of systemd units and their respective time to finish initialization at boot
# Check systemd-analyze is executed without any errors and display boot time
# Check if systemd mount units like umount.target are installed
# Check the systemd journal for systemd-journal related logs
# Check if standard systemd service is loaded
#
# # Author:  Muhammad Farhan
#
###############################################################################

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

echo "About to run systemd package test..."

# Defining file path
setup() {
	file="/tmp/blame.txt"
}	

# Delete previous files if any
cleanup() {
	rm -f "$file"
	
}

# check if systemd is installed on target
systemd_package_check() {
	echo "checking if systemd is installed"
	skip_list="systemd_version_check_test systemd_units_during_boot_test systemd_analyze_boot_time_test systemd_units_installed_test systemd_journal_logs_test systemd_service_loaded_test" 
	check_if_package_installed systemd
	lava_test_result "systemd_package_check_test" "${skip_list}"
}

# Check systemd version installed on target
systemd_version_check() {
	echo "Checking systemd version installed on target"
	/lib/systemd/systemd --version
	lava_test_result "systemd_version_check_test"
}

# Check list of systemd units and their respective time to finish initialization at boot
systemd_units_check() {
	echo "Checking list of systemd units and their respective time to finish initialization at boot"
	systemd-analyze blame > $file; cat $file
	lava_test_result "systemd_units_during_boot_test"
}

# Check systemd-analyze is executed without any errors and display boot time
systemd_analyze_boot_time() {
	echo "Checking systemd-analyze is executed without any errors and display boot time"
	systemd-analyze time
	lava_test_result "systemd_analyze_boot_time_test"
}

# Check if systemd mount units like umount.target are installed
systemd_units_install() {
	echo "Checking if systemd mount units like umount.target are installed"
	systemctl list-unit-files | grep umount
	lava_test_result "systemd_units_installed_test"
}

# Check the systemd journal for systemd-journal related logs
systemd_journal_logs() {
	echo "Checking the systemd journal for systemd-journal related logs"
	journalctl | grep systemd-journal
	lava_test_result "systemd_journal_logs_test"
}

# Check if standard systemd service is loaded
systemd_service_load() {
	echo "Checking if standard systemd service is loaded"
	systemctl status systemd-logind.service | grep -i "loaded"
	lava_test_result "systemd_service_loaded_test" 
}

# Main
cleanup
setup
systemd_package_check
(systemd_version_check)
(systemd_units_check)
(systemd_analyze_boot_time)
(systemd_units_install)
(systemd_journal_logs)
systemd_service_load
