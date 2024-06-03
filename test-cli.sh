#!/usr/bin/env bash

#########################################################################
#
# The test-cli is an application intended to runs all the tests in non-lava environment
# Input: It takes input from a text file which contains testcases of respectives suites
# Output: Prints all the executed test steps results to console and records into local files.
# Author: Muhammad Farhan <engr.farhan@icloud.com>
#
# Usage: ./test-cli.sh [ComponentUnderTest]
#
#
#########################################################################


#### GET TARGET  INFO  ###########

function hwinfo () {
clear
TIME=1
echo " "
echo $0
echo " "
echo "Choose an option below!

    1 - Verify desktop processor
	2 - Verify system kernel
	3 - Verify installed softwares
	4 - Operation system version
    5 - Verify desktop memory
	6 - Verify serial number
	7 - Verify system IP	 
	0 - Exit"
echo " "
echo -n "Chosen option: "
read opcao
case $opcao in
	1)
		function processador () {
			CPU_INFO=`cat /proc/cpuinfo | grep -i "^model name" | cut -d ":" -f2 | sed -n '1p'`
			echo "CPU model: $CPU_INFO"
			sleep $TIME
		}	
		processador
		read -n 1 -p "<Enter> for main menu"
		hwinfo
		;;

	2)
		function kernel () {
			#RED HAT: cat /etc/redhat-release
			KERNEL_VERSION_UBUNTU=`uname -r`
			KERNEL_VERSION_CENTOS=`uname -r`
			if [ -f /etc/lsb-release ]
			then
				echo "kernel version: $KERNEL_VERSION_UBUNTU"
			else
				echo "kernel version: $KERNEL_VERSION_CENTOS"
			fi
		}
		kernel
		read -n 1 -p "<Enter> for main menu"
		hwinfo
		;;

	3)
		function softwares () {
			#while true; do
			TIME=3
			echo " "
			echo "Choose an option below for program's list!
			
			1 - List Ubuntu programs
			2 - List Fedora programs
			3 - Install programs
			4 - Back to menu"
			echo " "
			echo -n "Chosen option: "
			read alternative
			case $alternative in
				1)
					echo "Listing all programs Ubuntu's systems..."
					sleep $TIME
					dpkg -l > /tmp/programs.txt
					echo Programs listed and available at /tmp
					sleep $TIME
					echo " "
                                        echo "Back to menu!" | tr [a-z] [A-Z]
					sleep $TIME
					;;
				2)
					echo "Listing all programs Fedora's systems..."
					sleep $TIME
					yum list installed > /tmp/programs.txt
					echo Programs listed and available at /tmp
					sleep $TIME
					;;
				3)
					echo Installing programss...
					LIST_OF_APPS="pinta brasero gimp vlc inkscape blender filezilla"
					#use aptitude command for programs loop.
					apt install aptitude -y
					aptitude install -y $LIST_OF_APPS
					;;
				4)
					echo Back to main menu...
					sleep $TIME
					;;	
			esac
		#done
		}		
		softwares
		hwinfo
		;;
	
	4)
		function sistema () {
			VERSION=`cat /etc/os-release | grep -i ^PRETTY`
			if [ -f /etc/os-release ]
			then
				echo "The system version: $VERSION"
			else
				echo "System not supported"
			fi
		}
		sistema
		read -n 1 -p "<Enter> for main menu"
		hwinfo
		;;


	5)
		function memory () {
			MEMORY_FREE=`free -m  | grep ^Mem | tr -s ' ' | cut -d ' ' -f 4`
			#MEMORY_TOTAL=
			#MEMORY_USED=
			echo Verifying system memory...
			echo "Memory free is: $MEMORY_FREE"	
		}
		memory
		read -n 1 -p "<Enter> for main menu"
		hwinfo
		;;

	6)
		function serial () {
			SERIAL_NUMBER=`dmidecode -t 1 | grep -i serial`
			echo $SERIAL_NUMBER
		}
		serial
		read -n 1 -p "<Enter> for main menu"
		hwinfo
		;;

	7)
		function ip () {
			IP_SISTEMA=`hostname -I`
			echo IP is: $IP_SISTEMA
		}
		ip
		read -n 1 -p "<Enter> for main menu"
		hwinfo
		;;

	0) 
	       echo Exiting the system...
       	       sleep $TIME
	       exit 0
	       ;;

	*)
		echo Invalid option, try again!
		;;
esac
}
 #############3 return the current path ###############

LEVEL=$1
for ((i = 0; i < LEVEL; i++)); do
	echo $i
	# CDIR=../$CDIR
done
# cd $CDIR
echo "You are in: "$PWD
sh=$(which $SHELL)
# exec $sh

#############
SERVER HEALTH
#################
function heath () {


date
echo "uptime:"
uptime
echo "Currently connected:"
w
echo "--------------------"
echo "Last logins:"
last -a | head -3
echo "--------------------"
echo "Disk and memory usage:"
df -h | xargs | awk '{print "Free/total disk: " $11 " / " $9}'
free -m | xargs | awk '{print "Free/total memory: " $17 " / " $8 " MB"}'
echo "--------------------"
start_log=$(head -1 /var/log/messages | cut -c 1-12)
oom=$(grep -ci kill /var/log/messages)
echo -n "OOM errors since $start_log :" $oom
echo ""
echo "--------------------"
echo "Utilization and most expensive processes:"
top -b | head -3
echo
top -b | head -10 | tail -4
echo "--------------------"
echo "Open TCP ports:"
nmap -p -T4 127.0.0.1
echo "--------------------"
echo "Current connections:"
ss -s
echo "--------------------"
echo "processes:"
ps auxf --width=200
echo "--------------------"
echo "vmstat:"
vmstat 1 5

}
# Set test results file path
TEST_RESULTS=/tmp/$1.log
echo "Test CLI has been started to execute the script: $1"
for c in  31  32   35  36 ; do
	echo -en "\r \e[${c}m Automated Test CLI Controller v1.2 is Ready \e[0m "
    echo $date
	sleep 1
done
usage()
{
    # hwinfo
    echo "\n\n\n****Name of Component Under the test is missing.*******\n\n\nTHIS IS HOW YOU PROVIDE COMPONENT TO CLI: $0 COMPONENT_NAME "
    echo -e "\n\n\nPLEASE SPECIFY THE COMPONENT_NAME - Incase of help contact engr.farhan@icloud.com"
    exit 1
}

case  "$1" in
    linux-package)
        echo "verifying all the debian packages installed on system"
	    echo "*****************************\n"
	    Total_test=`wc -l linux-package/debian_package_input_file | cut -d " " -f1`
	    cd "$1"
	    for i in `cat debian_package_input_file`; do ./$i | tee -a $TEST_RESULTS  ; done    
        
	    ;;

    filesystem)
	    echo "Executing all filesystem testcases on system"
	    echo "*****************************\n"    
	    Total_test=`wc -l filesystem/filesystem_tests_input_file | cut -d " " -f1`
	    cd "$1"
        for i in `cat filesystem_tests_input_file`; do ./$i | tee -a $TEST_RESULTS  ; done

        ;;

    general-kernel-features)
	    echo "Executing all Kernel testcases on system"
        echo "*****************************\n"
        Total_test=`wc -l general-kernel-features/general_kernel_features_test_input | cut -d " " -f1`
        cd "$1"
        for i in `cat general_kernel_features_test_input`; do ./$i | tee -a $TEST_RESULTS  ; done

	    ;;

    IO)
        echo "Executing Board IO testcases on system"
        echo "*****************************\n"
        Total_test=`wc -l IO/IO_tests_input_file | cut -d " " -f1`
        cd "$1"
        for i in `cat IO_tests_input_file`; do ./$i | tee -a $TEST_RESULTS  ; done

	    ;;

    ""|--help)
        usage

	    ;;

    *)
        echo "Invalid suite name: $1"
	    exit 1

	    ;;
esac

# API to get test counts and results

get_ok_results()
{
    (cat $TEST_RESULTS | grep -i "test passed$" || cat $TEST_RESULTS | grep -i "RESULT=pass") | wc -l
}  

# To get no. of failed test counts
get_failed_results()
{
    (cat $TEST_RESULTS | grep -i "test failed$" || cat $TEST_RESULTS | grep -i "RESULT=fail") | wc -l
}

# To get no. of skipped test counts
get_count_skip()
{
    (cat $TEST_RESULTS | grep -iw "skip$" || cat $TEST_RESULTS | grep -i "RESULT=skip") | wc -l
}

# To get list of passed testcases
get_testcases_pass()
{
    cat $TEST_RESULTS | grep -i "test passed$" || cat $TEST_RESULTS | grep -i "RESULT=pass" | awk '{print $2,$3}' | cut -d ">" -f1
}

# To get list of failed testcases
get_testcase_fail()
{
    cat $TEST_RESULTS | grep -i "test failed$" || cat $TEST_RESULTS | grep -i "RESULT=fail" | awk '{print $2,$3}' | cut -d ">" -f1
}

# To get list of skipped testcases
get_testcase_skip()
{
    cat $TEST_RESULTS | grep -iw "skip$" || cat $TEST_RESULTS | grep -iw "RESULT=skip" | awk '{print $2,$3}' | cut -d ">" -f1
}    

echo "\n Test Summary Report:"
echo  "*****************************\n"

echo "Total number of Linux debian packages those are tested: $Total_test\n"
echo "Total number of Linux debian packages those are Passed: $(get_ok_results)"
echo "Total number of Linux debian packages those are Failed: $(get_failed_results)"
echo "Total number of Linux debian packages those are Skipped: $(get_count_skip)"

echo "*****************************\n"
echo "=============Detail Lists==================\n"
echo "List of testcases passed:\n"
get_testcases_pass

echo "List of testcases failed:\n"
get_testcase_fail

echo "List of testcases skipped:\n"
get_testcase_skip

echo "====================finished============"

# Remove log file
rm -rf $TEST_RESULTS
