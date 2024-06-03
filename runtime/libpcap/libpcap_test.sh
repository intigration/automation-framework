#!/bin/sh

############################################################################
#
# DESCRIPTION :
#
# Verify package existance in target
# Verify the functionalities of packet looping
# Verify the functionalities of packet sniffing
# # Author:  Muhammad Farhan
#
############################################################################

echo "About to run libpcap package"

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

IFACE=`ip link show | grep "UP,LOWER_UP" | grep -v lo | cut -d: -f2 | head -n 2`

#Libpcap Package check
libpcap_package_check() {
	echo "Check the package on the target"
	skip_list="libpcap_loop_function_check libpcap_sniff_check"
	check_if_package_installed libpcap
	lava_test_result "libpcap_package_check"
}

#check the functioalities of packet looping
libpcap_loop_check() {
	echo "Run the packet loop application"
	gcc libpcap/libpcap_loop.c -lpcap -o libpcap_loop
	./libpcap_loop 7
	lava_test_result "libpcap_loop_function_check"
}
#Check the functionalities of packet sniffing
libpcap_sniff_check() {
	echo "Run packet sniff application"
	gcc libpcap/libpcap_sniff.c -lpcap -o libpcap_sniff
	yes $IFACE | ./libpcap_sniff tcp 5
	lava_test_result "libpcap_sniff_check"
}
#Main
libpcap_package_check
(libpcap_loop_check)
(libpcap_sniff_check)
