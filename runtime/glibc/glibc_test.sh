#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# The GNU C Library, commonly known as glibc,
# It's GNU Project's implementation of the C standard library.
# Despite its name, it now also directly supports C++
#
# Check the libc package is available on target or not.
# Check glibc installed version using ldd
# Use ldd to verify the program was linked with glibc
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run glibc package test..."

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

cleanup() {
    remove_tmp_dir
}

# Check the libc package is available on target or not.
package_check() {
    echo "Checking libc package is available on target or not"
    check_if_package_installed libc
    lava_test_result "glibc_package_check_test"
}

# Check glibc installed version using ldd
version_check() {
    echo "Check glibc installed version using ldd"
    ldd --version | grep -i "GLIBC"
    lava_test_result "glibc_version_check"
}

# Use ldd to verify the program was linked with glibc
program_test() {
    echo "Use ldd to verify the program was linked with glibc"
    gcc glibc/glibc.c -o $QA_TMP_DIR/glibc
    ldd $QA_TMP_DIR/glibc
    echo "Run the program to checks it's cross-compiled successfully"
    $QA_TMP_DIR/glibc | grep -i "hello world!"
    lava_test_result "glibc_program_linked_test"
}

#main
create_tmp_dir
package_check
version_check
program_test
cleanup
