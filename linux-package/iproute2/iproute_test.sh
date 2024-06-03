#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Test scripts check if iproute2 package is installed on target
# Check Interface configuration using iproute on target
# Check route to an IP Address
# Check Neighbours of ip address using iproute

Author: Muhammad Farhan
#
###############################################################################

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

echo "About to run iproute package test..."

# Defining certificate file path
setup() {
	iproute_ip=$(ip route get 8.8.8.8 |  cut -f7 -d" ")
	ipaddres=$(ip addr | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sed -n 2p)
}	

# check if iproute is installed on target
iproute_package_check() {
	echo "checking if iproute is installed"
	skip_list="iproute_interface_configuration_check_test iproute_ipaddress_check_test iproute_neighbours_ipaddress_check_test" 
	check_if_package_installed iproute2
	lava_test_result "iproute_package_check_test" "${skip_list}"
}

# Check Interface configuration using iproute on target
iproute_interface_config() {
	echo "Checking Interface configuration of network"
	skip_list="iproute_ipaddress_check_test iproute_neighbours_ipaddress_check_test"
	ip route
	lava_test_result "iproute_interface_configuration_check_test" "${skip_list}"
}

# Check route to an IP Address
iproute_ipaddress_check() {
	echo "Checking ip address using iproute"
	skip_list="iproute_neighbours_ipaddress_check_test"
	if [ "$iproute_ip" != "$ipaddres" ]; then
	 	exit_on_step_fail "iproute_ipaddress_check_test" "${skip_list}"
	fi
	ip route get 8.8.8.8
	lava_test_result "iproute_ipaddress_check_test" "${skip_list}"
}

# Check Neighbours of ip address using iproute
iproute_neighbours_ipaddress() {
	echo "Checking Neighbours ip address using iproute"
	ip neigh show	
	lava_test_result "iproute_neighbours_ipaddress_check_test" 
}

#main
#calling all functions here
setup
iproute_package_check
iproute_interface_config
iproute_ipaddress_check
iproute_neighbours_ipaddress

