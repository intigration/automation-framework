#!/bin/bash
###############################################################################
#
# DESCRIPTION :
# This test script verifies
# Creating a user in debain environment  
# Checking the login package on target 
# Checking the login of new user  
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

echo "About to run login package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Declaring the variables
PASSWORD="password"
USERNAME="username"

#Adding an user to the system with password
set_up_user_creation() {
	echo "Adding a new user to the system"
	skip_list="login_package_check login_to_new_user "	
	echo "Enter the username: $USERNAME"	
	egrep "^$USERNAME" /etc/passwd >/dev/null
		if [ $? -eq 0 ]; then
			echo "$username exists!"
		else
			yes $PASSWORD | adduser $USERNAME
		fi
	cut -d: -f1 /etc/passwd | grep -i $USERNAME
	lava_test_result "set_up_user_creation" "${skip_list}"
}	
#Check whether the login package is installed or not
login_package_check() {
 	echo "Check for the login package" 
	skip_list="login_to_new_user"
	check_if_package_installed login
	lava_test_result "login_package_check" "${skip_list}"
}
#login to the new system
login_to_new_user() {
	echo "Login to the new user"
	/usr/bin/expect << EOF
        set timeout 10
	spawn login $USERNAME
	expect "password:"
	send "$PASSWORD\r"
	expect ":~$"
	exit
	expect eof
EOF
	lava_test_result "login_to_new_user"
}
#Deleting the newly created user
clean_up() {
	echo "Delete the user from system"
	userdel $USERNAME 
}
#Main 
#calling all functions here
clean_up
set_up_user_creation
login_package_check
(login_to_new_user)



