#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script  verifies the availability of openldap  package.
# Verifies the open source tests available for the openldap package.
#
 Author: Muhammad Farhan
###############################################################################

echo "About to run openldap package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Remove the text files created
cleanup() {
	remove_tmp_dir
}

setup() {
	currentDir=`pwd`
	cd $QA_TMP_DIR

	echo "Download source of openldap on target"
	wget https://github.com/openldap/openldap/archive/OPENLDAP_REL_ENG_2_4_47.tar.gz
	exit_on_step_fail "openldap_source_download"

	tar -xvf OPENLDAP_REL_ENG_2_4_47.tar.gz

	cd openldap*

	./configure
	exit_on_step_fail "openldap_setup_configure"

	echo "Run the make command"
	make all
	exit_on_step_fail "openldap_setup_make"

	make check >$QA_TMP_DIR/openldap_log.txt
	cat $QA_TMP_DIR/openldap_log.txt | grep -i "test[0-9]" | sed /Starting/d > $QA_TMP_DIR/openldap_test.txt
}

#Check the package availability on target
openldap_server_package_check() {
	echo "Check the openldap server package on target"
	skip_list="openldap_functions_check"
	check_if_package_installed slapd
	lava_test_result "openldap_server_package_check" "skip_list"
}

#Check the functionalities of openldap
openldap_functions_check() {
	while read line
	do
		#to get the test_name
		test_name=`echo "$line" | cut -d" " -f2`
		#to get the test result
		test_result=`echo "$line" | grep -o "OK\|failed" `
		if [ "$test_result" = "OK" ]; then
			lava_test_result "openldap_${test_name}"
		elif [ "$test_result" = "failed" ]; then
			false
			lava_test_result "openldap_${test_name}"
		elif [ "$test_result" = "skip" ]; then
			skip_test "openldap_${testname}"
		fi
	done < "$QA_TMP_DIR/openldap_test.txt"
	cd $currentDir
}

#Main
create_tmp_dir
setup
openldap_server_package_check
openldap_functions_check
cleanup
