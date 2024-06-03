#!/bin/bash
###############################################################################
#
# DESCRIPTION :
#
# helper script for getting remoteip,hostname,bandwidth and targetip etc..
### Author Muhammad Farhan#
###############################################################################

#Get ipv4 address associated with network interface ($1 - 1st argument)
getmyip() {
	ip addr | grep -i $current_iface | grep -i inet | awk '{print $2}' | cut -d '/' -f 1 | head -n 1
}

#Get ipv6 address associated with network interface ($1 - 1st argument)
getmyipv6() {
	ip -o -6 addr show dev $current_iface | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d'
}

#Remote ip is available in network_details
getremoteip() {
	cat ethernet/network_details | grep -v ^# | grep '\<RHOST\>' | awk '{print $2}'
}

#Remote USER is available in network_details
getremoteuser() {
	cat ethernet/network_details | grep -v ^# | grep '\<RUSER\>' | awk '{print $2}'
}

getremoteipv6() {
#Remote ip is available in network_details
	cat ethernet/network_details | grep -v ^# | grep 'RHOSTv6' | awk '{print $2}'
}

#Get the network interface associated with ip address(1st argument)
getnetiface() {
	ip link show | grep "UP,LOWER_UP" | grep -v lo | cut -d: -f2 | head -n 2
}

#Get numner of packets
getNpackets() {
	cat /proc/net/dev | sed 's/[|:]/ /g' | grep "face\|$iFace" | awk '{for(i=1;i<=NF;i++) if($i == "packets") {value=i} print $value}' | grep -v packets
}

#Get Bandwidth
getBandwidth() {
	echo "$1" | grep 'Mbits/sec' | tail -n 1 | awk '{for(i=1;i<=NF;i++){if($i == "Mbits/sec") print $(i-1)}}'
}

#Get remote host interface
getremoteiface() {
	local tRemoteCmd="netstat -ie | grep -B1 "$rhostIP""
	ssh -o StrictHostKeyChecking=no $rhostUSER@$rhostIP $tRemoteCmd | awk '{print $1}' | head -n 1
}

#Get different subnet IPS
getsubnet_IP() {
	export SUBNET_IP1=$(cat ethernet/network_details | grep -i "SUBNET" | cut -d "=" -f2 | awk 'FNR ==1 {print $1}')
	export SUBNET_IP2=$(cat ethernet/network_details | grep -i "SUBNET" | cut -d "=" -f2 | awk 'FNR ==2 {print $1}')
	export SUBNET_IP3=$(cat ethernet/network_details | grep -i "SUBNET" | cut -d "=" -f2 | awk 'FNR ==3 {print $1}')
}

#To check if eth_parameters has been set
check_eth_param() {
	index=0
	for i in $targetIP
	do
		if [ "$rhostIPv6" == "" ] || [ "$rhostIP" == "" ] || [ "${iFace[$index]}" == "" ] || [ "${targetIPv6[$index]}" == "" ] || [ "$rhostIFace" == "" ]; then
			echo "Empty values for Ethernet variables. Can't execute Ethernet tests."
			echo "Please check you ethernet settings."
			exit -1
		fi
		index=$((index+1))
	done
}

#Function to convert float to int.
f2i() {
	#    echo "$1" | awk -F "." '{print $1}'
	local temp="$1"
	if [ ! -z $temp ] && [ $temp != " " ]; then
		echo "$temp" | awk -F "." '{print $1}'
	else
		echo 0
	fi
}

setup() {
	export iFace_initial="$(getnetiface)"
	index=0
	for current_iface in $iFace_initial
	do
		export $current_iface
		iFace[$index]=$current_iface
		targetIP[$index]="$(getmyip)"
		index=$((index+1))
	done

	if [ "$targetIP" = "" ]; then
		echo "No target ip assigned, can't move forward with ethernet tests."
		exit -1
	fi

	index=0
	for i in ${targetIP[@]}
	do
		export current_ip=$i
		export current_iface=${iFace[$index]}

		targetIPv6[$index]="$(getmyipv6)"

		echo "Target ip $current_ip and interface is $current_iface"
		echo "Target ipv6 ${targetIPv6[$index]} and interface is $current_iface"
		index=$((index+1))
	done

	if [ $index -gt 1 ]; then
		echo  "Multiple ethernet interface detected. Test will be executed on all interfaces."
	fi

	Check_ferret_host=$(mount | grep ferret | head -n 1 | awk '{print $1}' | cut -d '/' -f3)
	export rhostIP="$(getremoteip)"
	export rhostUSER="$(getremoteuser)"
	export rhostIPv6="$(getremoteipv6)"
	export rhostIFace="$(getremoteiface)"

	echo "Remote Host ip $rhostIP and interface is $rhostIFace"
	echo "Remote Host ipv6 $rhostIPv6 and interface is $rhostIFace"

	check_eth_param
	#Function call for getting different subnet IPs
	getsubnet_IP
}

setup;
