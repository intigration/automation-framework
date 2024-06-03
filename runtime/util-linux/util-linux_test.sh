#!/bin/bash

###############################################################################
#
# DESCRIPTION :
# Test script  verifies the availability of util-linux package.
# Verifies the open source tests available for the package.
#
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run util-linux package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

present_dir=`pwd`
flag=0

#Remove the unwanted files and directories, after execution
cleanup() {
	remove_tmp_dir
	if [ "$flag" == "1" ]; then
            apt-get purge -y bison
	fi
}

#Set up the build
setup() {
	cd $QA_TMP_DIR
	apt-get source util-linux
	exit_on_step_fail "util-linux_setup-source"
        check_if_package_installed bison
        if [ $? -eq 0 ]; then
            echo "bison package is the part of rootfs"
        else
            flag=1
            echo "Install bison package on the target"
            apt-get install -y bison
            exit_on_step_fail "util-linux_install_bison"
        fi
	cd util-linux-[0-9]*
	./autogen.sh
	exit_on_step_fail "util-linux_setup_autogen"
	./configure
	exit_on_step_fail "util-linux_setup_configure"
	make check
	exit_on_step_fail "util-linux_setup_make"
}

#package check
util_linux_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="util_linux_command_check"
	echo "Checking for util-linux package"
	check_if_package_installed util-linux
	lava_test_result "util-linux_package_check" "${skip_list}"
}

#Find the test scripts
function find_test_scripts() {
	local searchdir="$1"
	find "$searchdir" -type f -regex ".*/[^\.~]*" \
		\( -perm -u=x -o -perm -g=x -o -perm -o=x \)
}

#For parse the test result output
parse_utillinux_test_output() {
	cd $QA_TMP_DIR/util-linux-*/tests/ts
	./${1} 2>&1 | tee $QA_TMP_DIR/output.log
	if cat $QA_TMP_DIR/output.log | tail -1 | grep "OK" > /dev/null; then
		lava_test_result "util-linux_check_${1}"
	elif cat $QA_TMP_DIR/output.log | tail -1 | grep "SKIPPED" > /dev/null; then
		if [ "${lava_check}" = "true" ]; then
			lava-test-case util-linux_check_${1} --result skip
		else
			echo "util-linux_check_${1} skip"
		fi
	else
		lava_test_result "util-linux_check_${1}"
	fi
}

#Test case execution
util_linux_command_check() {
	cd $QA_TMP_DIR/util-linux-*
	comps=( $(find_test_scripts "tests/ts") )
	for ts in ${comps[@]}; do
		tsname=${ts##*ts/}
        #Do not run the testcases listed in the util_linux_skip_list.txt
        cat $QA_SUITES_ROOT/linux-package/util-linux/util_linux_skip_list.txt | grep -i "$tsname"
        if [ $? -eq 0 ]; then
            continue
        fi
        #call the function for parsing the test result with args
        parse_utillinux_test_output $tsname
	done
	cd $present_dir
}

#main
#function call
create_tmp_dir
setup
util_linux_package_check
util_linux_command_check
cleanup

