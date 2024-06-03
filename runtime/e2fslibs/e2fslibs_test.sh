#!/bin/bash
###############################################################################
#
# DESCRIPTION :
# This test script verifies package check of e2fslibs on the target.
# Checking the creation of ext2 ,ext3 and ext4 filesystems on the 10MB images.
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

echo "About to run e2fslibs package test..."

# Importing LAVA libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Removing the directories
clean_up() {
	remove_tmp_dir
}

#Check the e2fslibs package check
e2fslibs_package_check() {
	skip_list="e2fslibs_ext2_filesystem_creation e2fslibs_ext3_filesystem_creation e2fslibs_ext4_filesystem_creation"
	echo "Check the package on the target"
	check_if_package_installed e2fslibs
	lava_test_result "e2fslibs_package_check" "${skip_list}"
}
#Check the ext2 filesystem creation
e2fslibs_ext2_filesystem_creation() {
	echo "create an image of size 10MB....."
	dd if=/dev/zero of=$QA_TMP_DIR/ext2_FSImg bs=1M count=10
	exit_on_step_fail "e2fslibs_ext2_filesystem_creation"

	echo "creating ext2 filesystem on ex2_FSImg"
	mkfs.ext2 -t ext2 -F $QA_TMP_DIR/ext2_FSImg
	lava_test_result "e2fslibs_ext2_filesystem_creation"
}

#Check the ext3 filesystem creation
e2fslibs_ext3_filesystem_creation() {
	echo "create an image of size 10MB....."
	dd if=/dev/zero of=$QA_TMP_DIR/ext3_FSImg bs=1M count=10
	exit_on_step_fail "e2fslibs_ext3_filesystem_creation"
	
	echo "creating ext3 filesystem on ext3_FSImg"
	mkfs.ext3 -t ext3 -F $QA_TMP_DIR/ext3_FSImg
	lava_test_result "e2fslibs_ext3_filesystem_creation"
}
#Check the ext4 filesystem creation()
e2fslibs_ext4_filesystem_creation() {
	echo "create an image of size 10MB....."
	dd if=/dev/zero of=$QA_TMP_DIR/ext4_FSImg bs=1M count=10
	exit_on_step_fail "e2fslibs_ext4_filesystem_creation"

	echo "creating ext4 filesystem on ext4_FSImg"
	mkfs.ext4 -t ext4 -F $QA_TMP_DIR/ext4_FSImg
	lava_test_result "e2fslibs_ext4_filesystem_creation"
}

#main
create_tmp_dir
e2fslibs_package_check
(e2fslibs_ext2_filesystem_creation)
(e2fslibs_ext3_filesystem_creation)
(e2fslibs_ext4_filesystem_creation)
clean_up
