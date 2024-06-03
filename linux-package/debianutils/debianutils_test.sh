#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script verifies the availability of debianutils package.
# Varifies the working of commands provided by the package which includes
# add and remove shell, temfile, ischroot, which, runparts and installkernal
# 
Author: Muhammad Farhan
# 
###############################################################################

echo "About to run debian-utils package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#variable declaration
newShell="/etc/test-shell"
logFile="/tmp/test.log"
savedLog="/tmp/test.log.0"
tempFile=""
runTestDir="/tmp/runtest"
RunTestFile1="/tmp/runtest/pass"
RunTestFile2="/tmp/runtest/test"

cleanup() {
	if [ -f "$logFile" ]; then
		rm -f $logFile

	fi
	if [ -f "$savedLog" ]; then
		rm -f $savedLog

	fi
	if [ -f "$tempFile" ]; then
		rm -f $tempFile
	fi
	if [ -d "$runTestDir" ]; then
		rm -rf $runTestDir
	fi
		
}

setup() {
	touch $logFile
}

#debianutils Package Check
debianutils_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="debianutils_add-shell_check debianutils_remove-shell_check"
	echo "Checking for Debianutils Package"
	check_if_package_installed debianutils
	lava_test_result "debianutils_package_check" "${skip_list}"
}
#debianutils add-shell command Check
debianutils_addshell_check() {
	echo "Testing add-shell command..."
	skip_list="debianutils_remove-shell_check"
	echo "adding shell to valid login list" 
	/usr/sbin/add-shell $newShell
	if [ $? -eq 0 ]; then
		echo " added new tesing-shell to valid login list:`grep -w test-shell /etc/shells`"
		cat /etc/shells
		grep -w test-shell /etc/shells > /dev/null
        	lava_test_result "debianutils_add-shell_check" "${skip_list}"
	else
		lava_test_result "debianutils_add-shell_check" "${skip_list}"
	fi
}
#debianutils remove-shell command Check
debianutils_removeshell_check() {
	echo "Testing remove-shell command..."
	echo "removing shell from valid login list"
	/usr/sbin/remove-shell $newShell
	grep -i test-shell /etc/shells > /dev/null
	if [ $? -ne 0 ]; then
		cat /etc/shells
		echo "removed newShell"	
	        lava_test_result "debianutils_remove-shell_check" ""   
	else
	   	lava_test_result "debianutils_remove-shell_check" ""	            
	fi	         
}

#debianutils savelog command check
debianutils_savelog_check() {
	echo "Testing savelog command..."
	echo "testing savelog package" > $logFile
	savelog -q -u root -m 640 -c 12 $logFile
	if [ $? -eq 0 ]; then
		ls $savedLog > /dev/null
		lava_test_result "debianutils_savelog_check" ""
	else
		lava_test_result "debianutils_savelog_check" "" 
	fi
}

#debianutils tempfile command check
debianutils_tempfile_check() {
	echo "Teshing tempfile command..."
	echo "Creating temp file using TEMPFILE"
	tempFile=`tempfile`
	if [ $? -eq 0 ]; then
		ls $tempFile
		lava_test_result "debianutils_tempfile_check" ""
	else
		lava_test_result "debianutils_tempfile_check" ""
	fi
}

#debianutils which command check
debianutils_which_check() {
	echo "Testing which command..."
	which -a which
	lava_test_result "debianutils_which_check" ""
}

#debianutils_ischroot_check
debianutils_ischroot_check() {
	echo "Testing ischroot command..."
	ischroot
	if [ $? -eq 0 ] || [ $? -eq 1 ]; then
		lava_test_result "debianutils_ischroot_check" ""
	else
		lava_test_result "debianutils_ischroot_check" ""
	fi
}

#debianutils runParts command check
debianutils_runParts_check() {
	mkdir $runTestDir
	touch $RunTestFile1 $RunTestFile2
	var=`run-parts --list --regex '^p.*' $runTestDir`
	if [ $? -eq 0 ] && [ $var = '/tmp/runtest/pass' ]; then
		lava_test_result "debianutils_runParts_check" ""
	else
		lava_test_result "debianutils_runParts_check" ""
	fi
}

#debuanutils installkernel command check
debianutils_installkernel_check() {
	which installkernel
	lava_test_result "debianutils_installkernel_check" ""
}

#Main functions
cleanup
setup
debianutils_package_check
debianutils_addshell_check
(debianutils_removeshell_check)
(debianutils_savelog_check)
(debianutils_tempfile_check)
(debianutils_which_check)
(debianutils_ischroot_check)
(debianutils_runParts_check)
(debianutils_installkernel_check)
cleanup
