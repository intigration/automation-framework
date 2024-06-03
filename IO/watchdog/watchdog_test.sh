#!/bin/sh
###############################################################################
# Author:  Muhammad Farhan#
#Description: Watchdog basic test
# Check watchdog driver detection in kernel
# Check watchdog device detection in /dev
# 
###############################################################################

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Importing LAVA libraries
. ../lib/sh-test-lib

echo "Executing basic watchdog test"

watchdog_test() {
    echo "Check watchdog module detection"
    lsmod | grep -i iTCO_wdt
    lava_test_result "watchdog_driver_detection_test"
    echo "Check watchdog device in /dev"
    ls -l /dev/watchdog
    lava_test_result "watchdog_device_detection_test"
}

# main
create_tmp_dir
watchdog_test
remove_tmp_dir
