#!/bin/bash

###############################################################################
#
# DESCRIPTION :
# Test script  verifies the passwd package availability,
# Verifies if passwd change is working by creating a test user,Verifies if password delete function is working,
# Verifies if it is able to change shell and finger information of the test user.
#
Author: Muhammad Farhan
# 
###############################################################################

echo "About to run passwd package test..."

# Assigning value to variables
USERNAME="testuser"
PASSWORD="xYnHKL"

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Deleting log file
cleanup()  {

	userdel $USERNAME
}
#Check if the user already exist if not then create
setup() {
	echo "Adding a new user to the system"
	echo "Enter the username: $USERNAME"	
	egrep "^$USERNAME" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "user exists"
	else
		yes $PASSWORD | adduser $USERNAME
	fi
}

#Passwd Package Test
passwd_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="passwd_remove_check passwd_change_check passwd_change_user_shell_check passwd_change_finger_info_check"
	echo "Checking for Passwd Package..."
	check_if_package_installed passwd
	lava_test_result "passwd_package_check" "${skip_list}"
}
#Changing the password by creating a user
passwd_change_check() {
	skip_list="passwd_remove_check"	
	cat /etc/passwd | grep -i "^$USERNAME"
	if [ $? -eq 0 ]; then
		echo "Changing password for $USERNAME"
		#add new password
 		echo -e "User@123\nUser@123\nUser@123" | passwd $USERNAME
		lava_test_result "passwd_change_check" "${skip_list}"
	fi
}

#Deleting the passwd for test user
passwd_remove_check() {
	echo "Deleting the password for $USERNAME"
	passwd -d $USERNAME
	passwd -S $USERNAME | grep "NP"	
	lava_test_result "passwd_remove_check" 
}

#changing the shell
passwd_change_user_shell_check() {
	echo "Changing shell for $USERNAME"
	chsh -s /bin/dash $USERNAME
	if [ $? -eq 0 ]; then
		cat /etc/passwd | grep -w "^$USERNAME" | grep 'dash' 
		lava_test_result "passwd_change_user_shell_check" 
	fi
}

#changing finger information of user
passwd_change_finger_info_check() {
	echo "Changing finger information of $USERNAME"
	chfn -f TestUser -w 8887779999 $USERNAME
	if [ $? -eq 0 ]; then
		cat /etc/passwd | grep -w testuser | egrep 'TestUser|8887779999'
		lava_test_result "passwd_change_finger_info_check"
	fi	
}

#Main functions
setup
passwd_package_check
(passwd_change_check && passwd_remove_check)
(passwd_change_user_shell_check)
(passwd_change_finger_info_check)
cleanup
