#!/bin/bash
###############################################################################
#
# DESCRIPTION :
#
# This is a wrapper script replaces the result format of TAP-13 protocol
# used by the kselftest default with a format which is giving better
# understanding to the user for analysing the result.
#
# Author: Muhammad Farhan
#
###############################################################################

TOTAL_PASS=0
TOTAL_SKIP=0
TOTAL_FAIL=0
KSELFTEST_SUITE_PATH="/usr/libexec/kselftest"
KSELFTEST_LOG_FILE=kselftest_log.txt

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Importing LAVA libraries
. ../lib/sh-test-lib

#Function for cleanup the files
clean_up() {
	remove_tmp_dir
}

#Function for feeding into a file
feed_to_a_file() {
	cd $KSELFTEST_SUITE_PATH
	./run_kselftest.sh > $QA_TMP_DIR/$KSELFTEST_LOG_FILE
}

#Function for processing the log to get the better result
kselftest_parse_output() {
	#Find the test directory and iterate to get the individual test result
	for find_test in $(ls $KSELFTEST_SUITE_PATH)
	do
	PASS_COUNT=0
	FAIL_COUNT=0
	SKIP_COUNT=0

	if [ ! -d $find_test ] || [ $find_test = "kselftest" ]; then
		continue
	fi
	#Separate count of pass,fail and skip test-cases
	while read line
	do
		RESULT_CHECK=$(echo $line | grep -i "ok" | cut -d" " -f1 | cut -d"#" -f1)
		if [ "$RESULT_CHECK" =  "ok" ]; then
			TEST_CASE=$(echo $line | awk 'FNR == 1 {print $5}' | cut -d ":" -f1 | cut -d "." -f1)
			if [ "$TEST_CASE" = "" ]; then
				TEST_CASE=$(echo $line | awk 'FNR == 1 {print $3}' | cut -d ":" -f1 | cut -d "." -f1)
			fi
			lava_test_result "kselftest_$TEST_CASE"
			PASS_COUNT=$((PASS_COUNT + 1))
			TOTAL_PASS=$((TOTAL_PASS + 1))
		elif [ "$RESULT_CHECK" = "not" ]; then
			SKIP_CHECK=$(echo $line | grep -i "SKIP")
			if [ $? -eq 0 ]; then
				TEST_CASE=$(echo $line | awk 'FNR == 1 {print $5}' | cut -d ":" -f1 | cut -d "." -f1)
				if [ "$TEST_CASE" = "" ]; then
					TEST_CASE=$(echo $line | awk 'FNR == 1 {print $3}' | cut -d ":" -f1 | cut -d "." -f1)
				fi
				skip_test "kselftest_$TEST_CASE"
				SKIP_COUNT=$((SKIP_COUNT + 1))
				TOTAL_SKIP=$((TOTAL_SKIP + 1))
			else
				TEST_CASE=$(echo $line | awk 'FNR == 1 {print $5}' | cut -d ":" -f1 | cut -d "." -f1)
				if [ "$TEST_CASE" = "" ]; then
					TEST_CASE=$(echo $line | awk 'FNR == 1 {print $3}' | cut -d ":" -f1 | cut -d "." -f1)
				fi
				(
				false
				lava_test_result "kselftest_$TEST_CASE"
				)
				FAIL_COUNT=$((FAIL_COUNT + 1))
				TOTAL_FAIL=$((TOTAL_FAIL + 1))
			fi
		fi
	done <<< $(cat $QA_TMP_DIR/$KSELFTEST_LOG_FILE | grep -i $find_test)
	echo "
	Test_suite            : $find_test
	No of test pass       : $PASS_COUNT
	No of test skip       : $SKIP_COUNT
	No of test fail       : $FAIL_COUNT "
	if [ $FAIL_COUNT -eq 0 ] && [ $PASS_COUNT -eq 0 ]; then
		echo "$find_test is SKIPEED"
	elif [ "$FAIL_COUNT" = "0" ]; then
		echo "$find_test is PASSED"
	else
		echo "$find_test is FAILED"
	fi
	done
	TOTAL_TESTS=$(($TOTAL_PASS + $TOTAL_SKIP + $TOTAL_FAIL))
	echo "SUMMARY:
	No of TOTAL TESTS: $TOTAL_TESTS
	No of TOTAL PASS : $TOTAL_PASS
	No of TOTAL SKIP : $TOTAL_SKIP
	NO of TOTAL FAIL : $TOTAL_FAIL"
}

#Main
create_tmp_dir
feed_to_a_file
kselftest_parse_output
clean_up
