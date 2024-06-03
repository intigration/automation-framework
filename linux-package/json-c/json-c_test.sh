#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script  verifies the availability of json-c package.
# Verifies the open source tests available for the json-c package.
#
 # Author:  Muhammad Farhan
###############################################################################

echo "About to run json-c package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

cleanup() {
	remove_builddep json-c
	remove_tmp_dir
}

setup() {
	currentDir=`pwd`
	cd $QA_TMP_DIR
	echo "source json-c on target"
	apt-get source json-c
	exit_on_step_fail "json-c_setup_source"

	install_builddeps json-c
	exit_on_step_fail "json-c_install_build_deps"

	cd json-c-*
	echo "check the autogen execution"
	sh autogen.sh
	exit_on_step_fail "json-c_setup_autogen"

	./configure
	exit_on_step_fail "json-c_setup_configure"

	echo "Run the make command"
	make
	exit_on_step_fail "json-c_setup_make"

	make check > $QA_TMP_DIR/json-c_log.txt
	cat $QA_TMP_DIR/json-c_log.txt | egrep "PASS|FAIL|SKIP" | sed /#/d > $QA_TMP_DIR/json_test_log.txt
}
#Check the package availability on target
json_c_package_check() {
	echo "Check the json-c package on target"
	skip_list="json_c_functions_check"
	check_if_package_installed json-c3
	lava_test_result "json_c_package_check" "skip_list"
}
#Check the functionalities of json_c
json_c_functions_check() {
	while read line
	do
		#to get the test_name
		test_name=`echo "$line" | egrep "PASS|FAIL|SKIP" | cut -d" " -f2`
		#to get the test result
		test_result=`echo "$line" | egrep "PASS|FAIL|SKIP" | cut -d":" -f1`
		if [ "$test_result" = "PASS" ]; then
			lava_test_result "json_c_${test_name}"
		elif [ "$test_result" = FAIL ]; then
			cat $QA_TMP_DIR/json_test_log.txt | grep -A 50 "FAIL: $testname"
			lava_test_result "json_c_${test_name}"
		elif [ "$test_result" = "SKIP" ]; then
			#grep info for skipping of test
			cat $QA_TMP_DIR/json_test_log.txt | grep "skipped"
			skip_test "json_c_${testname}"
	        fi
	done < "$QA_TMP_DIR/json_test_log.txt"
	cd $currentDir

}
#Main
create_tmp_dir
setup
json_c_package_check
json_c_functions_check
cleanup
