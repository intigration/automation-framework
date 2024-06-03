#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Lsof is a Unix-specific diagnostic tool. Its name stands for LiSt Open Files, and it does just that.
# It lists information about any files that are open, by processes currently running on the system. 
#
# Test scripts check if lsof package is installed on target or not
# Check list of open files running on the system
# Check List Open Files of TCP Port ranges 1-1024
# Check List Only IPv4 & IPv6 Open Files
# Check list of open files using Search by PID
#
Author: Muhammad Farhan
#
###############################################################################

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

echo "About to run lsof package test..."

# check if lsof package is installed on target or not
lsof_package_check() {
	echo "checking if lsof package is installed or not"
	skip_list="lsof_open_files_check lsof_open_files_TCP_port_check lsof_open_files_ipv4_ipv6_check lsof_open_files_pid_check" 
	check_if_package_installed lsof
	lava_test_result "lsof_package_check_test" "${skip_list}"
}

# Check list of open files running on the system
lsof_open_files() {
	echo "Checking list of open files running on the system"
	lsof | head -n 50
	lava_test_result "lsof_open_files_check"
}

# Check List Open Files of TCP Port ranges 1-1024
lsof_tcp_port() {
	echo "Checking List Open Files of TCP Port ranges 1-1024"
	lsof -i TCP:1-1024
	lava_test_result "lsof_open_files_TCP_port_check" 
}

# Check  List Only IPv4 & IPv6 Open Files
lsof_ipv4_ipv6() {
	echo "Checking list of open files of IPv4 & IPv6"
	lsof -i 4;lsof -i 6
	lava_test_result "lsof_open_files_ipv4_ipv6_check"
}

# Check list of open files by PID 
lsof_pid() {
	echo "Checking list of open files whose PID is 1"
	lsof -p 1
	lava_test_result "lsof_open_files_pid_check"
}

# Main
lsof_package_check
(lsof_open_files)
(lsof_tcp_port)
(lsof_ipv4_ipv6)
lsof_pid


