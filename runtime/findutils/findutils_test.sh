#!/bin/bash

###############################################################################
#
# DESCRIPTION :
# Test script  verifies the availability of findutils package.
# Varifies the working of commands provided by the package which includes
# find, xargs and locate
#
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run findutils package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

cleanup() {
    remove_tmp_dir
}

setup() {
    touch $QA_TMP_DIR/findTest.txt
}

#findutils Package Check
findutils_package_check() {
    # Add your testcases in skip_list if you want to skip
    skip_list="findutils_find_check findutils_xargs_check"
    echo "Checking for Findutils Package"
    check_if_package_installed findutils
    lava_test_result "findutils_package_check" "${skip_list}"
}
#findutils find command Check
findutils_find_check() {
    echo "Testing find command..."
    #use find command to find the created text file in root directory
    findResult=`find $QA_TMP_DIR -name "findTest.txt"`
    if [ $? -eq 0 ]; then
        echo "$findResult" | grep -w "$QA_TMP_DIR/findTest.txt" > /dev/null
        lava_test_result "findutils_find_check" ""
    fi
}
#findutils xargs command Check
findutils_xargs_check() {
    echo "Testing xargs command..."
	# use xargs to print only two values in a line
    echo {0..9} | xargs -n 2 | grep "1 2"
    if [ $? -eq 1 ]; then
        lava_test_result "findutils_xargs_check" ""
    fi
}
#Main
create_tmp_dir
setup
findutils_package_check
(findutils_find_check)
(findutils_xargs_check)
cleanup
