#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Verify for proc filesystem support in kernel
# Verify default support of proc in mount
# Verify  /proc entries
# Verify Modify system parameters using /proc/sys entries
# Verify  /proc entries for a newly created process
# Verify if ps lists the status of processes correctly
# Verify if the /proc/interrupts file lists
# Verify if a user can modify interrupt affinity value for a particular IRQ
# Verify if /proc/net shows IPv6 support and traffic routed
# Verify if all/specific memory segments of a PID can be dumped using coredump_filter
#
### Author Muhammad Farhan#
###############################################################################

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing kernel config API
. ../lib/sh-debian-lib

echo "About to run proc filesystem test..."

# Verify proc filesystem support in kernel
kernel_config() {
	echo "Test proc FS support in Kernel"
	check_kernel_config CONFIG_PROC_FS
	lava_test_result "procfs_kernel_support"
}

# Verify default proc fs mount
proc_mount() {
	echo "Test default proc fs mount"
	mount | grep '/proc'
	lava_test_result "procfs_mount_test"
}

# Verify  /proc entries
proc_entry() {
	echo "Test proc entries"
	echo "Checking cpuinfo using proc fs"
	cat /proc/cpuinfo
	lava_test_result "procfs_cpuinfo_check"

	echo "Checking linux version using proc fs"
	cat /proc/version
	lava_test_result "procfs_linux_version_check"

	echo "Checking memory usage using proc fs"
	cat /proc/meminfo
	lava_test_result "procfs_meminfo_check"
}

# Modify system parameters using /proc/sys entries
modify_param() {
	echo "Modify system parameters using /proc/sys entries"
	cat /proc/sys/kernel/hostname
	prev_hostname=$(hostname)
	mytemp_hostname="NEW_HOST_NAME_TESTING"
	echo $mytemp_hostname > /proc/sys/kernel/hostname
	new_hostname=$(hostname)
	if [ "$new_hostname" = "$mytemp_hostname" ]; then
		exit_on_step_fail "procfs_modify_system_parameters_test"
	fi

	#Revert old hostname back.
	echo $prev_hostname > /proc/sys/kernel/hostname
	echo "Hostname is changed back to $(hostname)"
	if [ "$prev_hostname" = `hostname` ]; then
		lava_test_result "procfs_modify_system_parameters_test"
	fi
}

# Check /proc entries for a newly created process
process_entry() {
	echo "Checking proc entries for a newly created process"
	sleep 180 &
	tmp_pid=$!

	cat /proc/$tmp_pid/status
	lava_test_result "procfs_process_status_check"

	cat /proc/$tmp_pid/stack
	lava_test_result "procfs_process_stack_check"

	cat /proc/$tmp_pid/status | grep State | grep sleeping
	lava_test_result "procfs_process_state_check"

	cat /proc/$tmp_pid/status | grep VmSize
	lava_test_result "procfs_process_VmSize_check"

	kill -9 $tmp_pid
}

# Check if ps lists the status of processes correctly
process_check() {
	echo "Check if ps lists the status of processes correctly"
	dd if=/dev/zero of=/dev/null &
	tRunPid=$!
	pState=$(cat /proc/$tRunPid/status | grep -i State)
	echo $pState | grep -i running
	lava_test_result "procfs_running_process_state_check"

	sleep 180 &
	tmp_pid=$!
	sleep 5
	pState1=$(cat /proc/$tmp_pid/status | grep -i State)
	echo $pState1 | grep -i sleeping
	lava_test_result "procfs_sleeping_process_state_check"

	cat /proc/$tmp_pid/status | grep VmSize
	lava_test_result "procfs_process_VmSize_check"

	kill -9 $tRunPid
	kill -9 $tmp_pid
}

# Verify if the /proc/interrupts file list
interrupts_check() {
	echo "Check interrupts"
	cat /proc/interrupts
	lava_test_result "procfs_interrupt_list"
}

# Verify if a user can modify interrupt affinity value for a particular IRQ
modify_interrupt() {
	echo "Test a user can modify interrupt affinity value for a particular IRQ"
	tInterruptId=$(cat /proc/interrupts | grep 'eth\|mmc\|enp\|virtio'| awk '{print $1}' | sed 's/://' | awk  " FNR == 1 {print $1}")
	tAffinity_Org=$(cat /proc/irq/$tInterruptId/smp_affinity)

	echo "Original Affinity value is $tInterruptId"

	echo 1 > cat /proc/irq/$tInterruptId/smp_affinity

	tAffinity_Mod=$(cat /proc/irq/$tInterruptId/smp_affinity)

	echo "Modified Affinity value is $tInterruptId"

	if [ "$tAffinity_Org" = "$tAffinity_Mod" ]; then
		lava_test_result "procfs_modify_interrupt_test"
	fi

	echo "Changing affinity to original value"
	echo $tAffinity_Org > cat /proc/irq/$tInterruptId/smp_affinity

	cat /proc/irq/$tInterruptId/smp_affinity
}

# Verify if /proc/net shows IPv6 support and traffic routed
proc_net() {
	echo "Check files in /proc/net"
	cd /proc/net
	ls udp6 tcp6 raw6 igmp6 if_inet6 ipv6_route rt6_stats sockstat6 snmp6
	lava_test_result "procfs_IPv6_support"

	echo "Check values of the traffic of IPv6"
	cat /proc/net/dev
	lava_test_result "procfs_IPv6_net_traffic"
}

# Verify if all/specific memory segments of a PID can be dumped using coredump_filter
memory_segment() {
	echo "Check memory segments of a PID can be dumped using coredump_filter"
	cat /boot/config-$(uname -r) | grep ^CONFIG_ELF_CORE=y
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "CONFIG_ELF_CORE is enabled in Kernel"
		exit -1
	fi

	echo "Checking core-dump-filter"
	sleep 180&
	tPID=$!

	tFilter_Org=$(cat /proc/$tPID/coredump_filter)
	echo "Original core-dump-filter mask value $tPID"

	echo 0x5f > /proc/$tPID/coredump_filter
	cat /proc/$tPID/coredump_filter | grep 5f
	lava_test_result "procfs_memory_segment_core-dump-filter_check"
	kill -9 $tPID
}

# Main
kernel_config
(proc_mount)
(proc_entry)
(modify_param)
(process_entry)
(process_check)
(interrupts_check)
(modify_interrupt)
(proc_net)
(memory_segment)
