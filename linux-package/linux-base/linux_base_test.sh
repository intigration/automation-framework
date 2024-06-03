#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script  verifies the availability of linux-base package.
# Verifies the commands provides by the package.
# 
Author: Muhammad Farhan
#
###############################################################################

echo "About to run linux-base package test..."

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Remove the created text file
clean_up() {
        remove_tmp_dir
}

#Verifying if linux-base package is present or not
linux_base_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="linux_base_update_symlinks_command_check linux_base_check_removal_command_check linux_base_version_command_check linux_base_perf_command_check"
	echo "Checking for linux-base package"
	check_if_package_installed linux-base
	lava_test_result "linux_base_package_check" "${skip_list}"
}
#Checking for linux-version command of linux-base package
linux_base_version_command_check() {
	echo "Checking linux-version command for linux-base"
	linux-version list
	exit_on_step_fail "linux_base_version_command_check"
	version1=`linux-version list`
	version2=`uname -r`
	if [ $version1 = $version2 ]; then
		lava_test_result "linux_base_version_command_check"
	else
		lava_test_result "linux_base_version_command_check"
	fi
}
#Checking for perf command of the package
linux_base_perf_command_check() {
	echo "Checking perf command of linux-base"
	perf stat -r 5 sleep 1
	exit_on_step_fail "linux_base_perf_command_check"
	(perf stat -r 5 sleep 1) > $QA_TMP_DIR/perf_results.log 2>&1
	cat $QA_TMP_DIR/perf_results.log | grep "Performance counter stats for 'sleep 1' (5 runs)"
	lava_test_result "linux_base_perf_command_check"
}
#Checking for linux-update-symlinks command of the package
linux_base_update_symlinks_command_check() {
	echo "Checking linux-update-sysmlinks command of linux-base"
	(linux-update-symlinks) > $QA_TMP_DIR/symlinks_results.log 2>&1
	cat $QA_TMP_DIR/symlinks_results.log | grep "Usage: /usr/bin/linux-update-symlinks {install|upgrade|remove} VERSION IMAGE-PATH"
	lava_test_result "linux_base_update_symlinks_command_check"
}
#Checking for linux-check-removal command of the package
linux_base_check_removal_command_check() {
	echo "Checking linux-check-removal command of linux-base"
	(linux-check-removal) > $QA_TMP_DIR/removal_results.log 2>&1
	cat $QA_TMP_DIR/removal_results.log | grep "Usage: /usr/bin/linux-check-removal VERSION"
	lava_test_result "linux_base_check_removal_command_check"
}

#main
#function call
create_tmp_dir
linux_base_package_check
(linux_base_version_command_check)
(linux_base_perf_command_check)
(linux_base_update_symlinks_command_check)
(linux_base_check_removal_command_check)
clean_up
