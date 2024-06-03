#!/bin/sh
###############################################################################
 # Author:  Muhammad Farhan
#
#Description: Verify Open-posix Conformance test
# setup-environment is cleaning make and generating makefile
# setup-environment is creating t0 in bin file if not available
# Build Open-posix conformance test
# Run Open-posix conformance test
###############################################################################

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Importing LAVA libraries
. ../lib/sh-test-lib

# Importing setup-environment
. open-posix/setup-environment

echo "Executing open-posix testcases"

# Run Open-posix conformance test
conformance_test() {   
    cd $suite_path
    echo "Run Open-posix conformance test"
    make conformance-test
    lava_test_result "open-posix_conformance_test"
}

# Run Open-posix Functional test
functional_test() {
    cd $suite_path
    echo "Run Open-posix functional test"
    make functional-test
    lava_test_result "open-posix_functional_test"
}

# Run Open-posix stress test
stress_test() {
    cd $suite_path
    echo "Run Open-posix stress tests"
    make stress-test
    lava_test_result "open-posix_stress_test"
}

# Run Open-posix Message Queue tests
messagequeue_test() {
    cd $suite_path/bin
    echo "Run Message Queue test"
    ./run-posix-option-group-test.sh MSG
    lava_test_result "open-posix_message_queue_test"
}

# Run Open-posix Semaphore tests
semaphore_test() {
    cd $suite_path/bin
    echo "Run semaphore test"
    ./run-posix-option-group-test.sh SEM
    lava_test_result "open-posix_semaphore_test"
}

#main function
create_tmp_dir
setup
suite_path_check
clean_make
generate_makefile
conformance_test
functional_test
stress_test
messagequeue_test
semaphore_test
remove_tmp_dir
