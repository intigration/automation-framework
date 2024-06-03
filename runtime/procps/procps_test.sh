#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# Test scripts check if procps is installed on system or not
# Check every process running on the system
# Check top command on target
# Check kill command on target
# Check system uptime
# Check virtual memory statistics of system
#
Author: Muhammad Farhan
#
###############################################################################

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

echo "About to run procps package test..."

# check if procps is installed on target or not
procps_package_check() {
	echo "checking if procps is installed or not"
	skip_list="procps_process_check_test procps_top_command_test procps_kill_command_test procps_uptime_command_test procps_vmstat_command_test" 
	check_if_package_installed procps
	lava_test_result "procps_package_check_test" "${skip_list}"
}

# Check every process running on the system
procps_ps_command() {
	echo "Checking every process running on the system"
	ps -ax
	lava_test_result "procps_process_check_test"
}

# Check top command on target
procps_top_command() {
	echo "Checking top command availbility on system"
	which top
	lava_test_result "procps_top_command_test"
}

# Check kill command on target
procps_kill_command() {
	echo "Checking killing a process using kill command"
	which kill && openssl speed & sleep 10; kill $!
	lava_test_result "procps_kill_command_test" 
}

# Check system uptime
procps_uptime_command() {
	echo "Checking system uptime"
	uptime
	lava_test_result "procps_uptime_command_test"
}

# Check virtual memory statistics of system
procps_vmstat_command() {
	echo "Checking system virtual memory statistics"
	vmstat
	lava_test_result "procps_vmstat_command_test"
}

# Main
procps_package_check
(procps_ps_command)
(procps_top_command)
(procps_kill_command)
(procps_uptime_command)
procps_vmstat_command

