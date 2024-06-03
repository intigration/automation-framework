#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script  verifies the availability of hostname package,
# Verifies if hostname command gives same output as saved,Verifies if its able to set and delete hostname
#
Author: Muhammad Farhan
# 
###############################################################################

echo "About to run hostname package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

cleanup() {
	hostnamectl set-hostname "" --transient
}

#Hostname Package Check
hostname_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="hostname_user_check hostname_sethostname_check hostname_deletehost_check"
	echo "Checking for Hostname Package"
	check_if_package_installed hostname
	lava_test_result "hostname_package_check" "${skip_list}"
}
#Hostname User Check
hostname_user_check() {
	skip_list="hostname_sethostname_check hostname_deletehost_check"
	echo "Checking default Hostname of system"
	host=`hostname`
	grep $host /etc/hostname
        lava_test_result "hostname_user_check" "${skip_list}"
}
#Hostname Set New Host Check
hostname_sethostname_check() {
	
	echo "Setting a new host..."
	#new hostname is creation 
 	hostname newhost
	if [ $(hostname) = "newhost" ]; then
            echo "hostname changes to newhost"
            lava_test_result "hostname_set_newhost_check" ""
	fi	         
}
#Hostname Delete New Host Created During Set Host Check
hostname_deletehost_check()
{
	echo "Deleting the newly created hostname..."
	sleep 40 && hostnamectl set-hostname "" --transient
	lava_test_result "hostname_deletehost_check"
	echo "Deleted: newhost"
        echo "hostname: `hostname`"
}
cleanup
hostname_package_check
hostname_user_check
(hostname_sethostname_check)
hostname_deletehost_check
