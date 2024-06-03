#!/bin/bash
###############################################################################
#
# DESCRIPTION :
# This test script verifies zlib1g package checking  .
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################


echo "About to zlib1g udev package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#zlib package check
clean_up() {
	rm -rf $ZIP_PATH

}
#declaring the variables 
set_up() {
	skip_list="zlib1g_package_check zlib1g_gzip_compression zlib1g_gzip_decompression"
	TEST_FILE=testfile.txt
	ZIP_PATH=/tmp/testfile
	mkdir $ZIP_PATH
	dd if=/dev/zero of=$ZIP_PATH/$TEST_FILE count=20 bs=1M
	ret=$?
	if [ $ret -ne 0 ]; then
		exit_on_step_fail "set_up_for_zlib1g" "${skip_list}" 
	fi 
}

#zlib1g package checking 
zlib1g_package_check() {
	skip_list="gzip_package_checking "
	check_if_package_installed zlib1g
	lava_test_result "zlib1g_package_check" "${skip_list}"
}

#gzip package check
zlib1g_gzip_package_check() {
	skip_list="zlib1g_gzip_compression zlib1g_gzip_decompression"
	check_if_package_installed gzip
	lava_test_result "zlib1g_gzip_package_check" "${skip_list}"
}

#compress the testfile
zlib1g_gzip_compression() {
	echo "compress the testfile created"
	skip_list="zlib1g_gzip_decompression"
	gzip $ZIP_PATH/$TEST_FILE
	lava_test_result "zlib1g_gzip_compression" "${skip_list}"
}

#decompress the test file
zlib1g_gzip_decompression() {
	echo "decompress the testfile.gz created"
	gzip -d $ZIP_PATH/*.gz
	lava_test_result "zlib1g_gzip_decompression"
}

#Main Functions
set_up
zlib1g_package_check
zlib1g_gzip_package_check
zlib1g_gzip_compression
zlib1g_gzip_decompression
clean_up
