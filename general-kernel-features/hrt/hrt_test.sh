#!/bin/sh

###############################################################################
#
# DESCRIPTION :
#
# Verify hrt support on kernel
# Check the resolution of the timer
# Check the event_handler of the timer
# Check the hres_active value of the timer
# Verify the gettimeofday functionality of the timer
#
 # Author: Muhammad Farhan
###############################################################################
#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing kernel config API
. ../lib/sh-debian-lib

cleanup() {
	remove_tmp_dir
}

#Check the hrt support on kernel
hrt_support_on_kernel() {
	echo "Check the hrt support on kernel"
	skip_list="hrt_resolution hrt_eventhandler_test hrt_hres_active_value_check hrt_gettimeofday"
	check_kernel_config CONFIG_HIGH_RES_TIMERS
	lava_test_result "hrt_support_on_kernel" "${skip_list}"
}

#List the configured clock and timers
hrt_configured_clock_and_timers() {
	echo "Check the resolution of configured timer"
	RESOLUTION=$(cat /proc/timer_list  | grep -i  .resolution | awk 'FNR == 1 {print $2}')
	if [ $RESOLUTION -eq 1 ]; then
		lava_test_result "hrt_resolution"
	else
		lava_test_result "hrt_resolution"
	fi

	echo "Check the event handler of configured timer"
	EVENT_HANDLER=$(cat /proc/timer_list  | grep -i "event_handler" | awk 'FNR == 2 {print $2}')
	if [ $EVENT_HANDLER = "hrtimer_interrupt" ]; then
		lava_test_result "hrt_eventhandler_test"
	else
		lava_test_result "hrt_eventhandler_test"
	fi

	echo "Check the hres active value of the configured timer"
	HRES_ACTIVE=$(cat /proc/timer_list  | grep -i "hres_active" | awk 'FNR == 1 {print $3}')
	if [ $HRES_ACTIVE -eq 1 ]; then
		lava_test_result "hrt_hres_active_value_check"
	else
		lava_test_result "hrt_hres_active_value_check"
	fi
}

#Check the gettimeofday functionality
hrt_gettimeofday() {
	echo "Check gettimeofday test"
	gcc -o $QA_TMP_DIR/tu-hrt $QA_SUITES_ROOT/general-kernel-features/hrt/tu-hrt.c
	$QA_TMP_DIR/tu-hrt 60
	lava_test_result "hrt_gettimeofday"
}

#main
create_tmp_dir
hrt_support_on_kernel
(hrt_configured_clock_and_timers)
(hrt_gettimeofday)
cleanup
