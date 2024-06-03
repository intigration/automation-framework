#!/bin/bash

###############################################################################
#
# DESCRIPTION :
# This script tests the functionalities provided by openssh package.
#
 # Author:  Muhammad Farhan
#
###############################################################################

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#removing the created directoey and image
clean_up() {
	echo "Removing the directories"
	remove_builddeps openssh
	remove_tmp_dir
}

setup() {
	# Test run.
	cd $QA_TMP_DIR
	apt-get source openssh
	exit_on_step_fail "openssh_setup-source"
	install_builddeps openssh
	exit_on_step_fail "openssh_setup build-dep"
	VERSION=$(dpkg -l | grep openssh-client |awk '{print $3}'|cut -d- -f 1 | cut -d: -f2)
	cd openssh-"${VERSION}"
	./configure
	exit_on_step_fail "setup configure"
	make
	exit_on_step_fail "setup make"
	make tests  2>&1 | tee -a "$QA_TMP_DIR/result_log.txt"
	exit_on_step_fail "setup tests"
}
parse_output() {
	egrep "^failed|^ok" "$QA_TMP_DIR/result_log.txt"  2>&1 | tee -a "$QA_TMP_DIR/result_log.txt"
	sed -i -e 's/ok/pass/g' "$QA_TMP_DIR/result_log.txt"
	sed -i -e 's/failed/fail/g' "$QA_TMP_DIR/result_log.txt"
}

parse_result() {
	liney=$(grep -n -m 1 -e "^ok" -e "^fail" "$QA_TMP_DIR/test_log.txt" | cut -f1 -d:)
	last_line=$(grep -n -e "^ok" -e "^fail" "$QA_TMP_DIR/test_log.txt" | cut -f1 -d: | tail -1)
	if [ -f "$QA_TMP_DIR/result_log.txt" ]; then
		while read -r line; do
			if echo "${line}" | grep -E "pass|fail|skip"; then
				test="$(cut -f2- -d ' ' <<< "${line}")"
				result="$(echo "${line}" | awk '{print $1}')"
			if [ "$last_line" -ne "$liney" ];then
				linex=$(grep -n -m 1 -e "ok $test" -e "failed $test" "$QA_TMP_DIR/test_log.txt" | cut -f1 -d:)
				grep -n -m 1 -e "ok ${test}" -e "failed ${test}" "$QA_TMP_DIR/test_log.txt" > /dev/null
			if [ $? -eq 0 ];then
				awk "NR>=$liney && NR<=$linex" "$QA_TMP_DIR/test_log.txt"
				liney=$linex
			fi
			testname="$(echo ${test// /_})"
			if [ $result = "pass" ];then
				lava_test_result "openssh_$testname"
			else
				(lava_test_result "openssh_$testname")
			fi
			fi
			fi
		done <$QA_TMP_DIR/result_log.txt
	fi
}
#main
create_tmp_dir
setup
parse_output
parse_result
clean_up
