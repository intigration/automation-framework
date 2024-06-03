#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script verifies the availability of coreutils package.
# Verifies the open source tests available for the package.
#
# AUTHOR :
#      Richa Bharti <Richa_Bharti@mentor.com>
#
# Modified to skiplist:
#      Sarath P T <Sarath_PT@mentor.com
#
# Modified By :
#      Srinuvasan Arjunan <srinuvasan_a@mentor.com>
#
###############################################################################

echo "About to run core-util package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Remove unwanted files and directories
cleanup() {
	remove_builddeps coreutils
	remove_tmp_dir
}

#Set up the build
setup() {
	currentDir=`pwd`
	cd $QA_TMP_DIR
	#Fetch coreutils source package
	apt-get source coreutils
	#exit if the above step fails
	exit_on_step_fail "coreutils_setup-source"
	#Install all dependencies for coreutils
	install_builddeps coreutils
	exit_on_step_fail "coreutils_install_build-deps"
	cd coreutils-*
	#compile the package
	autoreconf
	exit_on_step_fail "coreutils_setup_autoreconf"
	export FORCE_UNSAFE_CONFIGURE=1
	./configure
	exit_on_step_fail "coreutils setup configure"
	#save the output of make check to a file
	make check > $QA_TMP_DIR/output.log
}

#Package check
coreutils_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="coreutils_functions_check"
	echo "Checking for coreutils package"
	check_if_package_installed coreutils
	lava_test_result "coreutils_package_check" "${skip_list}"
}

#For parse the test result output
parse_coreutil_test_output() {
	if [ "$test_result" = "PASS" ]; then
		lava_test_result "core_utils_check_${1}"
	elif [ "$test_result" = "FAIL" ]; then
		#grep info for failure if available
		cat $input | grep -A 50 "FAIL: tests/${1}" | grep "info:"
		#set error code as 1
		false
		lava_test_result "core_utils_check_${1}"
	elif [ "$test_result" = "SKIP" ]; then
		test=`echo $line | grep -oP "tests/\w+/\K\w+-*\w*-*\w*"`
		#grep info for skipping of test
		cat $input | grep -wx -m1 "^$test.*" | grep "skipped"
		skip_test "core_utils_check_${1}"
	fi
}

#Test-case execution
coreutils_functions_check() {
	while read line
	do
		#read the line until "/tests/test-suite.log" is found
		echo $line | grep "/tests/test-suite.log"
		if [ $? -eq 1 ]; then
			#grep test name from input file
			testname=`echo $line | egrep "PASS|FAIL" | grep -oP "tests/\K.+/\w+-*\w*-*\w*"`
			if [ $? -ne 0 ]; then
				testname=`echo $line | egrep "PASS|FAIL" | grep -oP "test-\K.+" | cut -d"." -f1`
			fi
		cat  $QA_SUITES_ROOT/linux-package/coreutils/coreutils_skiplist.txt  | grep -i "$testname" > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			continue
		fi
		#get test result from input file
		test_result=`echo $line | cut -d":" -f1`
		#compare the status of test result and get lava result as per it
		(
		if [ "$test_result" = "PASS" ]; then
			lava_test_result "core_utils_check_${testname}"
		elif [ "$test_result" = "FAIL" ]; then
			#grep info for failure if available
			cat $QA_TMP_DIR/output.log | grep -A 50 "FAIL: tests/$testname" | grep "info:"
			#set error code as 1
			false
			lava_test_result "core_utils_check_${testname}"
		elif [ "$test_result" = "SKIP" ]; then
			test=`echo $line | grep -oP "tests/\w+/\K\w+-*\w*-*\w*"`
			#grep info for skipping of test
			cat $QA_TMP_DIR/output.log | grep -wx -m1 "^$test.*" | grep "skipped"
			skip_test "core_utils_check_${testname}"
		fi
		)
		else
			break
			test_result=`echo $line | cut -d":" -f1`
			parse_coreutil_test_output $testname
		fi
	done < "$QA_TMP_DIR/output.log"
	cd $currentDir
}

#Main
create_tmp_dir
setup
coreutils_package_check
coreutils_functions_check
cleanup
