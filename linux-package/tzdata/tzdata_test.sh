#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# The Time Zone Database (often called tz or zoneinfo) contains code and data that represent the history of local time 
# for many representative locations around the globe. It is updated periodically to reflect changes made by political 
# bodies to time zone boundaries, UTC offsets, and daylight-saving rules. 
#
# Check the tzdata package is available on target or not.
# Check all the timezones on target.  
# Check daylight-saving rules on target.
# Check for setting the timezone on target.
# Check for setting the default timezone on target.
#
# # Author:  Muhammad Farhan
#
###############################################################################

echo "About to run tzdata package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

timezone="America/Los_Angeles"
default_timezone="UTC"
test_file="/tmp/test.txt"

# Deleting the text file if exist.
clean_up() {
	rm -f ${test_file}
}

# Check the tzdata package is available on target or not.
tzdata_package_check() {
	echo "Checking tzdata package is available on target or not"
	skip_list="tzdata_list_timezone_test tzdata_dst_timezone_test tzdata_set_timezone_test tzdata_default_timezone_test"
	check_if_package_installed tzdata
	lava_test_result "tzdata_package_check_test" "${skip_list}"
}

# Check all the timezones on target.
tzdata_list_timezone() {
	echo "Checking for all the timezones on target."
	skip_list="tzdata_dst_timezone_test tzdata_set_timezone_test tzdata_default_timezone_test"
	timedatectl list-timezones >> ${test_file}
	cat ${test_file}
	lava_test_result "tzdata_list_timezone_test" "${skip_list}"
}

# Check daylight-saving rules on target.
tzdata_dst_timezone() {
	echo "Checking for daylight-saving rules on target..."
	zdump -v /usr/share/zoneinfo/${timezone} | grep 2019
	lava_test_result "tzdata_dst_timezone_test"
}

# Check for setting the timezone on target.
tzdata_set_timezone() {
	echo "Checking for setting time zone on target."
	skip_list="tzdata_default_timezone_test"
	timedatectl set-timezone ${timezone}
	ret=$?
	if [ $ret -ne 0 ]; then
		exit_on_step_fail "tzdata_set_timezone_test" "${skip_list}"
	fi
	timedatectl | grep ${timezone}
	lava_test_result "tzdata_set_timezone_test"
}

# Check for setting the default timezone on target.
tzdata_default_timezone() {
	echo "Checking for setting default time zone on target..."
	timedatectl set-timezone ${default_timezone}
	ret=$?
	if [ $ret -ne 0 ]; then
		exit_on_step_fail "tzdata_default_timezone_test"
	fi
	timedatectl | grep ${default_timezone}
	lava_test_result "tzdata_default_timezone_test"
}

#main
clean_up
tzdata_package_check
tzdata_list_timezone
(tzdata_dst_timezone)
tzdata_set_timezone
(tzdata_default_timezone)
