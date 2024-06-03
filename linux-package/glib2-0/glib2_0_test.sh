#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# This test-script verifies glib2_0 package check on target
# Verifies the execution of a test program using glib2.0
# Verifies the version of glib2.0
#
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run glib2_0 package test..."

#Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

cleanup() {
	remove_tmp_dir
}

glib2_0_package_check() {
	echo "check the glib2.0 package on target"
	skip_list="glib2_0_test_program glib2_0_version_check"
	check_if_package_installed glib2.0
	lava_test_result "glib2_0__package_check" "${skip_list}"
}

glib2_0_verion_check() {
	echo "verify the version of glib2.0"
	gcc glib2-0/glib2_0_version.c `pkg-config --cflags --libs glib-2.0` -o $QA_TMP_DIR/glib2_0_version
	$QA_TMP_DIR/glib2_0_version
	lava_test_result "glib2_0_version_check"
}

glib2_0_test_program() {
	echo "verify the test program for glib2.0"
	gcc glib2-0/glib2_0_test_program.c `pkg-config --cflags --libs glib-2.0` -o $QA_TMP_DIR/glib2_0_test_program
	$QA_TMP_DIR/glib2_0_test_program
	lava_test_result "glib2_0_test_program"
}

#Main
create_tmp_dir
glib2_0_package_check
glib2_0_verion_check
glib2_0_test_program
cleanup
