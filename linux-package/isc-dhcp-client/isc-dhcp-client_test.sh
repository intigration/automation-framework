#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Check the availability of isc-dhcp-client package
# Check the dhcp process is running on the target  
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

echo "About to run isc-dhcp-client package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#check the availability of isc-dhcp-client package
isc_dhcp_client_package_check() {
	echo "Check the isc-shcp-client package on target"
	skip_list="isc_dhcp_client_daemon_check isc_dhcp_client_active_internet_check isc_dhcp_client_identifier_check"
	check_if_package_installed isc-dhcp-client
	lava_test_result "isc_dhcp_client_package_check" "${skip_list}"
}
#Check the dhcp process is running on the target  
isc_dhcp_client_daemon_check() {
	skip_list="isc_dhcp_client_active_internet_check"
	echo "Check the dhcp daemon is running on the target" 
	ps -aef | grep -i "dhcp"
	lava_test_result "isc_dhcp_client_daemon_check"
}
#Check the dhcp process is running on the target  
isc_dhcp_client_active_internet_check() {
	echo "Check the dhcp active internet connection on the target"
	netstat -anputa | grep -i "dhclient" 	
	lava_test_result "isc_dhcp_client_active_internet_check"
}
#Check the client-identifier and lease-time of dhclient
isc_dhcp_client_identifier_check() {
	echo "Check the client-identifier and lease-time of dhclient"
	cat /etc/dhcp/dhclient.conf | grep -i "dhcp"
	lava_test_result "isc_dhcp_client_identifier_check"
	
}
#Main
isc_dhcp_client_package_check
(isc_dhcp_client_daemon_check)
(isc_dhcp_client_active_internet_check)
(isc_dhcp_client_identifier_check)
