#!/bin/bash
###############################################################################
#
# DESCRIPTION :
#
# Verify packet transmission from target to host
# Verify packet transmission from host to target
# Verify ipv6 self ping test
# Verify ipv4 functional test
#
 # # Author:  Muhammad Farhan
#
###############################################################################
#Importing LAVA libraries
. ../lib/sh-test-lib

#Import helper scripts for ethernet
. ethernet/eth_helper.sh

#Packet transmission from target to host and vice versa
ethernet_packet_transmission() {

#Check the packet transmission from target to host
index=0

for current_ip in ${targetIP[@]}
do
	local tn1=$(getNpackets)
	ping -c 100 $rhostIP | grep "packet loss"
	local tn2=$(getNpackets)

	if [ `expr $tn2 - $tn1` -ge 100 ]; then
		lava_test_result "ethernet_packet_transmission_from_target_to_host"
	else
		lava_test_result "ethernet_packet_transmission_from_target_to_host"
	fi

	#Check the packet transmission from host to target.
	tn1=$(getNpackets)
	tRemoteCmd="ping -c 100 $current_ip"
	ssh $rhostUSER@$rhostIP $tRemoteCmd | grep "packet loss"

	tn2=$(getNpackets)
	if [ `expr $tn2 - $tn1` -ge 100 ]; then
		lava_test_result "ethernet_packet_transmission_from_host_to_target"
	else
		lava_test_result "ethernet_packet_transmission_from_host_to_target"
	fi

	index=$((index+1))
done
}

#Check the IPV4 functionality in target
ethernet_ipv4_test() {
	#TEST1
	for current_ip in ${targetIP[@]}
	do
		ssh $rhostUSER@$rhostIP df -h
		lava_test_result "ethernet_ipv4"
	done
}

#Check iperf performance test
ethernet_iperf_test() {

#--------------------- TCP performance measurement.
	index=0
	for current_ip in ${targetIP[@]}
	do

		#TEST1
		#Running in the HOST.
		local tRemoteCmd="iperf -s -f m -l 256K -w 256K > temp.log & echo \$!"
		local tPID=$(ssh $rhostUSER@$rhostIP $tRemoteCmd)

		#Running in the TARGET.
		local tOutput=$(iperf -c $rhostIP -f m -t 20 -l 256K -w 256K)
		local tbw_tcp1=$(getBandwidth "$tOutput")
		echo "TCP: Client bandwidth(scenario#1) = $tbw_tcp1"

		#Cleanup in the HOST and find the bandwidth.
		sleep 1
		tRemoteCmd="kill $tPID; cat temp.log; rm temp.log"
		tOutput=$(ssh $rhostUSER@$rhostIP $tRemoteCmd)

		local tBandwidth=$(getBandwidth "$tOutput")
		echo "TCP: Server bandwidth(scenario#1) = $tBandwidth"

		#TEST2
		#Running in the target.
		iperf -s -f m -l 256K -w 256K > temp.log &
		tPID=$!

		#Running in the host.
		tRemoteCmd="iperf -c $current_ip -f m -t 20 -l 256K -w 256K"
		tOutput=$(ssh $rhostUSER@$rhostIP $tRemoteCmd)

		tBandwidth=$(getBandwidth "$tOutput")
		echo "TCP: Server bandwidth(scenario#2) = $tBandwidth"

		#Cleanup in the TARGET and find the bandwidth.
		sleep 1
		kill $tPID
		tOutput=$(cat temp.log)
		local tbw_tcp2=$(getBandwidth "$tOutput")
		echo "TCP: Client bandwidth(scenario#2) = $tbw_tcp2"
		rm temp.log

#--------------------- UDP performance measurement.

		#TEST3
		#Running in the HOST.
		tRemoteCmd="iperf -u -s -f m > temp.log & echo \$!"
		tPID=$(ssh $rhostUSER@$rhostIP $tRemoteCmd)

		#Running in the TARGET.

		tOutput=$( iperf -u -c $rhostIP -b 1M -f m)
		local tbw_upd1=$(getBandwidth "$tOutput")
		echo "UDP: Client bandwidth(scenario#1) = $tbw_upd1"

		#Cleanup in the HOST and find the bandwidth.
		sleep 1
		tRemoteCmd="kill $tPID; cat temp.log; rm temp.log"
		tOutput=$(ssh $rhostUSER@$rhostIP $tRemoteCmd)

		tBandwidth=$(getBandwidth "$tOutput")
		echo "UDP: Server bandwidth(scenario#1) = $tBandwidth"

		#TEST4
		#Running in the target.
		iperf -u -s -f m > temp.log &
		tPID=$!

		#Running in the host.
		tRemoteCmd="iperf -u -c $current_ip -b 1M -f m"
		tOutput=$(ssh $rhostUSER@$rhostIP $tRemoteCmd)

		tBandwidth=$(getBandwidth "$tOutput")
		echo "UDP: Server bandwidth(scenario#2) = $tBandwidth"

		#Cleanup in the TARGET and find the bandwidth.
		sleep 1
		kill $tPID
		tOutput=$(cat temp.log)
		local tbw_upd2=$(getBandwidth "$tOutput")
		echo "UDP: Client bandwidth(scenario#2) = $tbw_upd2"
		rm temp.log

		echo "tbw_upd1=$tbw_upd1, tbw_tcp1=$tbw_tcp1, tbw_upd2=$tbw_upd2, tbw_tcp2=$tbw_tcp2"

		local tu1=$(f2i $tbw_udp1)
		local tt1=$(f2i $tbw_tcp1)
		local tu2=$(f2i $tbw_upd2)
		local tt2=$(f2i $tbw_tcp2)

		echo "udp1=$tu1 tcp1=$tt1 udp2=$tu2 tcp2=$tt1"

		#TCP performance should be better than upd performance.
		if [ `expr $tt1 - $tu1` -ge 0 ] && [ `expr $tt2 - $tu2` -ge 0 ]; then
			lava_test_result "ethernet_iperf_test"
		else
			lava_test_result "ethernet_iperf_test"
		fi

		index=$((index+1))
	done
}

# Ping different websites multiple times
ethernet_ping_website() {
	# Ping to google
	ping -c 10 google.com | grep "0% packet loss"
	exit_on_step_fail "ethernet_ping_google"
	# Ping to gmail
	ping -c 10 gmail.com | grep "0% packet loss"
	lava_test_result "ethernet_ping_website"
}

# Ping different subnet multiple times
ethernet_ping_different_subnet() {
	ping -c 10 $SUBNET_IP1 | grep "0% packet loss"
	exit_on_step_fail "ethernet_ping_different_subnet"
	ping -c 10 $SUBNET_IP2 | grep "0% packet loss"
	exit_on_step_fail "ethernet_ping_different_subnet"
	ping -c 10 $SUBNET_IP3 | grep "0% packet loss"
	lava_test_result "ethernet_ping_different_subnet"
}

# Check transmitted and received packet count with IPV6 address
ethernet_ipv6_packet_transmission() {
	OUTPUT=$(ping -c 100 -I $current_iface $rhostIPv6 | grep "packets")
	PACKETS_TRANSMITTED=$(echo $OUTPUT | awk '{print $1}')
	PACKETS_RECEIVED=$(echo $OUTPUT | awk '{print $4}')
	if [ $PACKETS_TRANSMITTED -eq 100 ] && [ $PACKETS_RECEIVED -eq 100 ]; then
		lava_test_result "ethernet_ipv6_packet_transmission_from_target_to_host"
	else
		lava_test_result "ethernet_ipv6_packet_transmission_from_target_to_host"
	fi
	OUTPUT2=$(ssh -o StrictHostKeyChecking=no -6  $rhostUSER@$rhostIPv6%$current_iface ping6 -c 100 $targetIPv6 | grep "packets")
	PACKETS_TRANSMITTED=$(echo $OUTPUT2 | awk '{print $1}')
	PACKETS_RECEIVED=$(echo $OUTPUT2 | awk '{print $4}')
	if [ $PACKETS_TRANSMITTED -eq 100 ] && [ $PACKETS_RECEIVED -eq 100 ]; then
		lava_test_result "ethernet_ipv6_packet_transmission_from_host_to_target"
	else
		lava_test_result "ethernet_ipv6_packet_transmission_from_host_to_target"
	fi
}

# IPv6 support (link local address)
ethernet_ipv6_link_local_address() {
	ifconfig lo add $targetIPv6
	exit_on_step_fail "ethernet_ipv6_address_add_to_lo"
	ipv6_lo=`ip addr show dev lo | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d' | grep fe`
	if [ "$ipv6_lo" = "$targetIPv6" ]; then
		lava_test_result "ethernet_ipv6_address_check_in_lo"
	else
		lava_test_result "ethernet_ipv6_address_check_in_lo"
	fi
	ping6 localhost -c 15 | grep "0% packet loss"
	lava_test_result "ethernet_ipv6_link_local_address"

	# cleanup
	ifconfig lo del $targetIPv6
}

# Remote access of target by ssh with IPV6 address
ethernet_ipv6_ssh_test() {
	ssh -o StrictHostKeyChecking=no -t $rhostUSER@$rhostIP ssh -o StrictHostKeyChecking=no -6 root@$targetIPv6%$rhostIFace df -h
	lava_test_result "ethernet_ipv6_ssh_test"
}

#Main
ethernet_packet_transmission
ethernet_ipv4_test
ethernet_ping_website
ethernet_ping_different_subnet
ethernet_ipv6_packet_transmission
ethernet_ipv6_link_local_address
ethernet_ipv6_ssh_test
ethernet_iperf_test
