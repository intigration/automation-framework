#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# GNU cpio performs three primary functions.  Copying files to an archive, Extracting files from an archive,
# and passing files to another directory tree.
# Test script  verifies if package is installed and all three primary functions.
#
# AUTHOR :
#      Muhammad Farhan
#
# 
###############################################################################

echo "About to run cpio package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

cpiodir="/tmp/cpioTest"
subdir="/tmp/cpioTest/subdir"
cleanup() {
    if [ -d $cpiodir ]; then
        rm -rf $cpiodir
    fi
}

setup() {
    mkdir $cpiodir && cd $cpiodir
    touch textFile1 textFile2
    mkdir $subdir && cd $subdir
    touch textFile3 textFile4
    cd $cpiodir
}

#cpio Package Check
cpio_package_check() {
    skip_list="cpio_copyout_check cpio_copyin_check cpio_copypass_check"          # Add your testcases in skip_list if you want to skip
    echo "Checking for Cpio Package"
    check_if_package_installed cpio
    lava_test_result "cpio_package_check" "${skip_list}"
}

#cpio copy files to an archive Check
cpio_copyout_check() {
    skip_list="cpio_copyin_check cpio_copypass_check"
    echo "Copying file to archive using cpio check"
    find . -depth -print | cpio -ov > tree.cpio
    if [ $? -eq 0 ]; then
        ls | grep "tree.cpio"
        lava_test_result "cpio_copyout_check" "${skip_list}"
    else
        lava_test_result "cpio_copyout_check" "${skip_list}"
    fi
}

#cpio extracting files from an archive Check
cpio_copyin_check() {
    echo "extracting files from an archive using cpio"
    mkdir test_dir
    mv tree.cpio test_dir && cd test_dir
    cpio -idv < tree.cpio
    if [ $? -eq 0 ]; then
        ls | grep -E "textFile1|subdir" && cd $subdir && ls | grep "textFile4"
        lava_test_result "cpio_copyin_check"
    else
        lava_test_result "cpio_copyin_check"
    fi
}

#cpio passing files to another directory tree check
cpio_copypass_check() {
    cd $cpiodir
    echo "passing files to another directory using cpio check"
    find . -depth -print0 | cpio --null -pvd new-dir
    if [ $? -eq 0 ]; then
        ls | grep "new-dir" && cd new-dir && ls | grep -E "textFile1|subdir"
        lava_test_result "cpio_copypass_check"
    else
        lava_test_result "cpio_copypass_check"
    fi
}

#Main
setup
cpio_package_check
cpio_copyout_check
(cpio_copyin_check)
(cpio_copypass_check)
cleanup
