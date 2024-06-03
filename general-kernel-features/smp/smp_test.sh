#!/bin/sh

###############################################################################
#
# DESCRIPTION :
#
# Verify smp kernel support
# Verify cpus usage using top command
# Verify smp performance test
# Verify the affinity mask check using taskset
# Verify the affinity mask test for interrupts
#
 Author: Muhammad Farhan
#
###############################################################################


#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing kernel config API
. ../lib/sh-debian-lib

#Check the smp support on kernel
smp_supprt_on_kernel() {
	echo "Check the smp support on kernel"
	skip_list="smp_cpu_usage_test smp_performance_test smp_retrieve_cpu_affinity_test smp_interrupts_affinity_test smp_interrupts_change_affinity_mask_test"
	check_kernel_config CONFIG_SMP
	lava_test_result "smp_support_on_kernel_test" "${skip_list}"

	nCpus=$(cat /proc/cpuinfo | grep processor | wc -l)
	if [ $nCpus -lt 2 ]; then
		echo "Check the smp support for target having less than 2 processors"
		check_kernel_config CONFIG_SMP_ON_UP
	lava_test_result "smp_support_on_kernel_test"
	fi
}

#Delete the log files created
clean_up() {
	remove_tmp_dir
}

#Check top command output
top_command_output() {
	export TERM=xterm-256color
	/usr/bin/expect << EOF
	set timeout 10
	spawn top
	expect "systemd"
	send "1"
	send "q"
	expect eof
EOF
}

#Check the presence of CPU in the top command log
smp_cpus_usage_check() {
	echo "Check the CPU usage from top command output"
	top_command_output > $QA_TMP_DIR/test_top.log
	cat $QA_TMP_DIR/test_top.log | grep -i "%Cpu[0-9]"
	lava_test_result "smp_cpu_usage_test"
}

#Run the SMP performance test
smp_performance_test() {
	echo "Run the SMP performance test"
	gcc  -o no_affinity smp/no_affinity.c -lpthread -lm
	gcc  -o set_affinity smp/set_affinity.c -lpthread -lm
	./smp/run_smp_test.sh | grep 'Test Result: PASS'
	lava_test_result "smp_performance_test"
}

#Check the affinity mask check of udev
smp_affinity_mask_check_taskset() {
	echo "Check the affinity mask of udev process using taskset"
	PID=`ps -aef | grep -i udev |  awk 'FNR == 1 {print $2}'`
	taskset -p $PID
	echo "pin the process to particular cpu"
	taskset -cp 1 $PID
	lava_test_result "smp_retrieve_cpu_affinity_test"
}

#check the affinity mask test of interrupts
smp_set_irq_affinity() {
	#Check the PID of the eth/mmc interrupts
	echo "Check for the pid of ethernet/mmc interrupts"
	PID=`cat /proc/interrupts | grep 'eth\|mmc\|enp\|virtio'| awk '{print $1}' | sed 's/://' | awk  " FNR == 1 {print $1}"`

	#Check the affinity of ethernet/mmc interrupts
	echo "Check the affinity of ethernet/mmc interrupts"
	cat /proc/irq/$PID/smp_affinity
	lava_test_result "smp_irq_affinity_check_test"

	#Change the current affinty mask into some other value
	echo 2 > /proc/irq/$PID/smp_affinity
	Affinity_Mask=`cat /proc/irq/$PID/smp_affinity`
	if [ $Affinity_Mask -eq 2 ]; then
		lava_test_result "smp_set_irq_affinity_test"
	else
		lava_test_result "smp_set_irq_affinity_test"
	fi
}

#Main
create_tmp_dir
smp_supprt_on_kernel
(smp_cpus_usage_check)
(smp_performance_test)
(smp_affinity_mask_check_taskset)
(smp_set_irq_affinity)
clean_up
