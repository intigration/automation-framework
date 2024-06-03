#!/bin/sh

###############################################################################
#
# DESCRIPTION :
#
# Verify cgroup kernel support
# Check the list of cgroups available
# Check the containers availability in the
# Setting up and managing cgroups
# Check the transient cgroup creation
#
 # Author: Muhammad Farhan
#
###############################################################################

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing kernel config API
. ../lib/sh-debian-lib

#Check the cgroup support on kernel
cgroup_support_on_kernel() {
	echo "Check the cgroup support on kernel"
	skip_list="cgroup_listed cgroup mounted cgroup_cpuset_check cgroup_creation cgroup_task_assigning cgroup_task_removal cgroup_create_transient"
	check_kernel_config CONFIG_CGROUPS
	lava_test_result "cgroup_support_on_kernel"
}

#Check the list of cgroups and mount point of cgroups
cgroup_list_and_mount_check() {
	echo "List all cgroups supported by kernel"
	local temp=0
	temp=$(cat /proc/cgroups | grep -v ^# | wc -l)
	if [ $temp -gt 0 ]; then
		lava_test_result "cgroup_listed"
	else
		lava_test_result "cgroup_listed"
	fi

	echo "Check the mounting of cgroup"
	mount | grep cgroup
	lava_test_result "cgroup mounted"
}

#Check the cpuset and systemd containers availability in the cgroup
cgroup_containers_availability_check() {
	echo "Check the cpuset and systemd containers availability in the cgroup"
	skip_list="cgroup_creation cgroup_task_assigning cgroup_task_removal cgroup_create_transient"
	list_cgroup=$(ls /sys/fs/cgroup/ | grep cpuset)
	ret=$?
	if [ $ret -eq 0 ]; then
		lava_test_result "cgroup_cpuset_check" "${skip_list}"
	else
		list_cgroup=$(ls /sys/fs/cgroup/ | grep cpu)
		ret=$?
		if [ $ret -eq 0 ]; then
			lava_test_result "cgroup_cpu_check"
		else
			list_cgroup=$(ls /sys/fs/cgroup/ | grep systemd)
			ret=$?
			if [ $ret -eq 0 ]; then
				lava_test_result "cgroup_cpu_check" "${skip_list}"
			else
				lava_test_result "cgroup_cpu_check" "${skip_list}"
			fi
		fi
	fi
}
#Setting and managing cgroup
cgroup_setting_and_managing() {
	echo "Entering to the available cgroup directories"
	cd /sys/fs/cgroup/$list_cgroup

	echo "Create a cgroup under the specified directory"
	rm -rf  mentor_cgroup > /dev/null 2>&1
	mkdir mentor_cgrp
	lava_test_result "cgroup_creation"

	cd mentor_cgrp
	if [ "$list_cgroup" = 'cpuset' ]; then
		echo 0 > $list_cgroup.mems
		echo 0 > $list_cgroup.cpus
	else
		echo $list_cgroup
	fi


	sleep 3000 &
	local tPid=$!

	#attach task to newly created cgroup
	echo "Task pid is $tPid.. Moving this to newly created group"
	echo $tPid > tasks

	#Now check if task's cgroup shows newly created group.
	echo "Check the tasks of newly created group"
	cat /proc/$tPid/cgroup | grep $list_cgroup | grep mentor_cgrp
	lava_test_result "cgroup_task_assigning"

	kill $tPid
	cat /sys/fs/cgroup/$list_cgroup/mentor_cgrp/tasks | grep $tPid
	ret=$?
	if [ $ret -ne 0 ]; then
		lava_test_result "cgroup_task_removal"
	fi
	cd /sys/fs/cgroup/$list_cgroup
	rmdir mentor_cgrp
}

#Checking the transient cgroup creation using systemd-run
cgroup_create_transient() {
	echo "Checking the transient cgroup creation using systemd-run"
	systemd-run --unit=name --scope --slice=slice_name ls -l
	lava_test_result "cgroup_create_transient"
}

#main
cgroup_support_on_kernel
(cgroup_list_and_mount_check)
cgroup_containers_availability_check
cgroup_setting_and_managing
(cgroup_create_transient)
