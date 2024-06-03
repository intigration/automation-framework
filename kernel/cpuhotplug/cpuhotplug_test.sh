#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# Verify cpu hotplug support on kernel
# Verify cpu hotplugging support
# Dynamically add and remove cpu
#
# Author: Muhammad Farhan
#
###############################################################################

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing kernel config API
. ../lib/sh-debian-lib

CPU_HOTPLUG_PATH=/sys/devices/system/cpu
nCpus=$(cat /proc/cpuinfo | grep processor | wc -l)

#Check the cpuhotplug support in kernel
cpu_hotplug_support_on_kernel() {
	echo "Check the cpu_hotplug support on kernel"
	skip_list="cpu_hotplugging_support_test cpu_hotplug_add_and_remove_dynamically"
	check_kernel_config CONFIG_HOTPLUG_CPU
	lava_test_result "cpu_hotplug_support_on_kernel_test" "${skip_list}"
}

#Check the number of processors are online
cpu_hotplugging_support() {
	echo "Check the mounting of sysfs"
	mount | grep sysfs
	lava_test_result "cpu_hotplug_sysfs_mount_test"

	echo "Check the online status of cpu"
	cd $CPU_HOTPLUG_PATH

	tCpus=0;
	tCpus=$(find cpu[0-9] -name online | wc -l)

	if [ $tCpus -gt 0 ]; then
		lava_test_result "cpu_hotplugging_support_test"
	else
		lava_test_result "cpu_hotplugging_support_test"
	fi
}

#Make the CPUs online/offline dynamically
cpu_hotplug_add_remove_dynamically() {
	echo "Check that each CPU core can be added and removed dynamically"
	cd $CPU_HOTPLUG_PATH
	nFail=0
	i=1
	while [ $i -lt $nCpus ]
	do
		echo 0 > cpu$i/online
		local OFFLINE_CPU=`cat offline`

		if [ "$OFFLINE_CPU" != "$i" ]; then
			nFail=`expr $nFail + 1`
		fi

		sleep 5

		echo 1 > cpu$i/online
		local ONLINE_CPU=`cat offline`
		if [ -n "$ONLINE_CPU" ]; then
			nFail=`expr $nFail + 1`
		fi
		i=$((i+1))
	done
	if [ $nFail -eq 0 ]; then
		lava_test_result "cpu_hotplug_add/remove_dynamically"
	else
		lava_test_result "cpu_hotplug_add/remove_dynamically"
	fi
}

#main
cpu_hotplug_support_on_kernel
cpu_hotplugging_support
cpu_hotplug_add_remove_dynamically
