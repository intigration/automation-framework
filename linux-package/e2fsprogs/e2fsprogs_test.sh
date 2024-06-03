#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script  verifies the availability of e2fsprogs package.
# Verifies the open source tests available for the package.
#
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run e2fsprogs package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

cleanup() {
	echo "Removing directory e2fsprogs source"
	remove_builddeps e2fsprogs
	remove_tmp_dir
}

e2fsprogs_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="e2fsprogs_source_setup e2fsprogs_make_check_result"
	echo "#Checking for e2fsprogs package"
	check_if_package_installed e2fsprogs
	lava_test_result "e2fsprogs_package_check" "${skip_list}"
}

e2fsprogs_source_setup() {
	echo "#Fetching and building e2fsprogs source package..."
	skip_list="e2fsprogs_make_check_result"
	cd $QA_TMP_DIR
	apt-get source e2fsprogs
	exit_on_step_fail "apt-get source e2fsprogs" "${skip_list}"
	install_builddeps e2fsprogs
	exit_on_step_fail "e2fsprogs install build_deps" "${skip_list}"
	cd e2fsprogs-*
	echo "# `pwd`"
	echo "# configure..."
	mkdir build && cd build
	../configure
	exit_on_step_fail "e2fsprogs configure"
	echo "# Make check..."
	make
	make check > $QA_TMP_DIR/e2fsprogs-make-check-log
	exit_on_step_fail "e2fsprogs make check" "${skip_list}"
}

e2fsprogs_make_check_result() {
	echo "#e2fsprogs make check test results display..."
	cd $QA_TMP_DIR/e2fsprogs-*
	while read each_line
	do
		# get test case name 
		test_name=`echo $each_line | grep -oP ".*:.*:.*" | egrep "ok|skipped|failed" | cut -d":" -f1`
		# get test case discription
		test_discript=`echo $each_line | grep -oP ".*:.*:.*" | egrep "ok|skipped|failed" | cut -d":" -f2`
		# get test case result
		test_result=`echo $each_line | grep -oP ".*:.*:.*" | egrep "ok|skipped|failed" |  cut -d":" -f3`
		(
		if [ "$test_result" = "ok" ]; then
			echo $test_discript
			lava_test_result "e2fsprogs_check_$test_name"
		elif [ "$test_result" = "failed" ]; then
			echo $test_discript
			false
			lava_test_result "e2fsprogs_check_$test_name"
		elif [ "$test_result" = "skipped" ]; then
			skip_test "e2fsprogs_check_${testname}"
		fi
		)

	done < $QA_TMP_DIR/e2fsprogs-make-check-log

}

#main
create_tmp_dir
e2fsprogs_package_check
e2fsprogs_source_setup
e2fsprogs_make_check_result
cleanup
