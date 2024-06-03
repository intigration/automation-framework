#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Check the availability of libcal1 package
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

echo "About to run libacl1 package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Remove the created text file
clean_up() {
	remove_tmp_dir
}

#Creating directory
set_up() {
	echo "Creating text file"
	touch $QA_TMP_DIR/test_file.txt
}

#check the availability of isc-dhcp-client package
libacl1_package_check() {
	echo "Check the libacl1 package on target"
	skip_list="libacl1_dynamic_library_check libacl1_setfacl_function_check libacl1_getfacl_check libacl1_getfacl_large_file_support"
	check_if_package_installed libacl1
	lava_test_result "libacl1_package_check" "${skip_list}"
}

#Check the dynamic library availability
libacl1_dynamic_library_check() {
	echo "Checking the dynamic library of libacl"
	find /lib -name "libacl.so.1"
	lava_test_result "libacl1_dynamic_library_check"
}

#Check the function of setfacl
libacl1_setfacl_function_check() {
	echo "checking the version of setfacl"
	setfacl -v
	exit_on_step_fail "libacl1_setfacl_function_check"
	echo "Checking the functions of setfacl command"
	setfacl -m u:bin:rwx $QA_TMP_DIR/test_file.txt
	echo "Check the changed access controll list"
	ls -l $QA_TMP_DIR/test_file.txt | awk -- '{ print $1 }'
	lava_test_result "libacl1_setfacl_function_check"
}

#Check the access controll list of a text file
libacl1_getfacl_check() {
	echo "Checking the access controll list of a text file"
	getfacl $QA_TMP_DIR/test_file.txt
	lava_test_result "libacl1_getfacl_check"
}

#Check the large file support of getfacl
libacl1_getfacl_large_file_support() {
	echo "Checking getfacl largefile support"
	dd bs=65536 seek=32768 if=/dev/null of=$QA_TMP_DIR/large_file 2>/dev/null ||:
	exit_on_step_fail "libacl1_getfacl_large_file_support"
	sh -c 'if test -f $QA_TMP_DIR/large_file; then getfacl $QA_TMP_DIR/large_file >/dev/null; fi'
	lava_test_result "libacl1_getfacl_large_file_support"
}

#Main
create_tmp_dir
set_up
libacl1_package_check
(libacl1_dynamic_library_check)
(libacl1_setfacl_function_check)
(libacl1_getfacl_check)
(libacl1_getfacl_large_file_support)
clean_up
