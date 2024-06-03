#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# x86:
#
# Verify the oomkiller functionality under cgroup
# Verify oomkiller cgroup kernel config enable
# Verify oomkiller enabled or not in the target
# Check the oomkiller invoked or not for the high badness number process
# Verify oomkiller disabling
# Verify oomkiller reenabling
#
# arm :
#
# check the status of the vm.overcommit_memory
# Verify the presence of oom_adj and oom_score files for few more running processes under /proc/<PID>/ directory
# Check the oomkiller is invoked by a process with high badness number
#
### Author Muhammad Farhan#
###############################################################################

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing kernel config API
. ../lib/sh-debian-lib

mount_point="/sys/fs/cgroup/memory"

#Cleanup cgroup
cleanup_x86() {
	cd $mount_point
	rmdir test_cgroup > /dev/null 2>&1
	remove_tmp_dir
}

#Masking all process to their previous oom_adj and state
cleanup_arm() {
	echo "Masking all process to their previous oom_adj state"
	for i in `ls /proc/*/oom_adj`;
	do
	{
		echo "0" > $i ;
	}&> /dev/null
	done
	remove_tmp_dir
}

#Check the oomkiller functionalities on x86 board
oomkiller_test_x86() {
	echo "checking CONFIG_MEMCG config enabled in kernel"
	check_kernel_config CONFIG_MEMCG
	lava_test_result "oomkiller_cgroup_kernel_config_enable"

	echo "creating a cgroup in memory subsystem"
	mkdir -p $mount_point/test_cgroup
	exit_on_step_fail "oomkiller_memory_subsystem_cgroup_creation"

	cd $mount_point/test_cgroup
	echo "Set up a memory limit to 100MB in the test_cgroup"
	echo 104857600 > memory.limit_in_bytes

	echo "checking OOM killer is enabled in memory.oom_control"
	cat memory.oom_control | grep -i 0
	lava_test_result "oom_killer_enable"

	echo "Moving current shell process into the tasks file of the created cgroup"
	echo $$ > tasks
	lava_test_result "oomkiller_move_shell_to_task"

	echo "Starting a test program that attempts to allocate a large amount of memory"
	gcc -o $QA_TMP_DIR/oom_cgroup $QA_SUITES_ROOT/general-kernel-features/oomkiller/oom_cgroup.c
	$QA_TMP_DIR/oom_cgroup ; dmesg  | grep -i killed
	lava_test_result "oom_killer_invoke"

	echo "Disabling OOM killer in memory.oom_control"
	cd $mount_point/test_cgroup
	echo 1 > memory.oom_control

	cat memory.oom_control | grep -i 1
	lava_test_result "oom_killer_disable"

	echo "rerunning the test program and the test program remains paused waiting for additional memory to be freed"
	($QA_TMP_DIR/oom_cgroup) & pid=$!
	(sleep 10 && kill -9 $pid)
	lava_test_result "oom_killer_process_kill"

	echo "Reenabling the OOM killer immediately kills the test program"
	echo 0 > memory.oom_control
	cat memory.oom_control | grep -i 0
	lava_test_result "oom_killer_reenable"
}

#Check the oom killer functionality outside cgroup for arm
oomkiller_arm() {
	echo "check the status of the vm.overcommit_memory"
	sysctl vm.overcommit_memory
	lava_test_result "oomkiller_vm.overcommit_memory"

	echo "Verify the presence of oom_score and oom_adj files"
	ls /proc/1 | grep -e "oom_score" -e "oom_adj"
	lava_test_result "oomkiller_existance_of_oomfiles"

	echo "Verify the presence of oom_adj and oom_score files for few more running processes under /proc/<PID>/ directory"
	ls "/proc/""$(ps | head -n 5 | tail -n 1 | awk '{print $1}')""/" | grep -e "oom_adj" -e "oom_score"
	lava_test_result "oomkiler_oomfiles_for_running_process"

	echo "Masking the currently running processes"
	for i in `ls /proc/*/oom_adj` ;
	do
	{
		echo "-17" > $i
	}&> /dev/null
	done

	echo "Check the oomkiller is invoked by a process with high badness number"
	gcc $QA_SUITES_ROOT/general-kernel-features/oomkiller/run_process.c -o $QA_TMP_DIR/run_process
	$QA_TMP_DIR/run_process &
	local tPid=$!

	sleep 20
	echo "Check oomkiller is invoked on target"
	dmesg | grep -i "kill"
	lava_test_result "oomkiller_invoked"
}

# Call temp directory API
create_tmp_dir

#Check the architecture and run the appropriate oomkiller tests
	if [ "$(uname -m)" = "x86_64" ]; then
		oomkiller_test_x86
		cleanup_x86
	else
		oomkiller_arm
		cleanup_arm
	fi
