#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script  verifies psmisc package availablity,
# Verifies the functionality provided by the package.
#
Author: Muhammad Farhan
# 
###############################################################################

echo "About to run psmisc package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

setup() {
	#start a background process
	sleep 1000 &
	pid=`echo $!`
	echo $pid
}

#Psmisc Package Check
psmisc_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="psmisc_fuser_functionality_check psmisc_prtstat_functionality_check psmisc_pstree_functionality_check psmisc_killall_functionality_check"
	echo "Checking for Psmisc Package"
	check_if_package_installed psmisc
	lava_test_result "psmisc_package_check" "${skip_list}"
}
#Fuser Functionality Check
fuser_functionality_check() {
	ls /bin | grep "fuser"
	if [ $? -eq 0 ]; then
		fuser -v .| grep $pid
		lava_test_result "psmisc_fuser_functionality_check"
	fi
}
#Prtstat Functionality Check
prtstat_functionality_check() {
	ls /usr/bin | grep "prtstat"
	if [ $? -eq 0 ]; then
		prtstat $pid | grep 'State'
		lava_test_result "psmisc_prtstat_functionality_check"
	fi
}

#Killall Functionality check
killall_functionality_check() {
	ls /usr/bin | grep "killall" 
	if [ $? -eq 0 ]; then
 		killall sleep
		lava_test_result "psmisc_killall_functionality_check"
	fi
}

#Pstree Functionality Check
pstree_functionality_check() {
	ls /usr/bin | grep -w "pstree"
	if [ $? -eq 0 ]; then
		pstree root
		lava_test_result "psmisc_pstree_functionality_check"
	fi
}

#Main
setup
psmisc_package_check
(fuser_functionality_check)
(prtstat_functionality_check)
(killall_functionality_check)
pstree_functionality_check
