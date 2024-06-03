#!/bin/bash
###############################################################################
#
# DESCRIPTION :
# This test script verifies creating a user in debian environment, adding a user to the existing group
# Adding a system user to the debian environment and deleting the created user and group .
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################


echo "About to run tar package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Clean up the created directories and files
clean_up() {
	cd
	rm -rf "${TAR_PATH}" "${FILE_PATH}"
}

#Declaring required variables 
set_up() {
	TAR_PATH=/tmp/tarfile
	FILE_PATH=/tmp/testfile
	TARFILE_NAME=temp.tar.bz2
}

#check the availability of tar package
tar_package_check() {
	skip_list="tar_file_creation tar_untar_file"
	check_if_package_installed tar
	lava_test_result "tar_package_check" "${skip_list}"
}

#creating a tar.bz2 file
tar_file_creation() {
	skip_list="tar_untar_file"
	mkdir -p "${FILE_PATH}"
	ret=$?
	if [ $ret -ne 0 ]; then
		exit_on_step_fail "tar_file_creation" "${skip_list}"
	fi
	mkdir -p "${TAR_PATH}"
	ret=$?
	if [ $ret -ne 0 ]; then
		exit_on_step_fail "tar_file_creation" "${skip_list}"
	fi
	cd "${FILE_PATH}"
	touch test1.txt  test2.txt  test3.txt  test4.txt
	ret=$?
	if [ $ret -ne 0 ]; then
		exit_on_step_fail "tar_file_creation" "${skip_list}"
	fi
	cd "${TAR_PATH}" 
	tar -czvf $TARFILE_NAME "${FILE_PATH}"
	lava_test_result "tar_file_creation" "${skip_list}"
}

#untar the tar.bz2 file
tar_untar_file()
{
	tar -xvf "${TAR_PATH}"/*.bz2
	lava_test_result "tar_untar_file"
}

#main functions calling
set_up
tar_package_check
tar_file_creation
(tar_untar_file)
clean_up
