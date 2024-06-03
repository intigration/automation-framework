#!/bin/bash
###############################################################################
#
# DESCRIPTION :
# This test script verifies creating a user in debian environment, adding a user to the existing group
# Adding a system user to the debian environment and deleting the created user and group.
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

echo "About to run adduser package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Declaring the variables
set_up() {
	PASSWORD="password"
	USERNAME="username"
	GRP_NAME="group"	
}

#Check whether the adduser package is installed or not
adduser_package_check() {
 	echo "Check for the adduser package" 
	skip_list="adduser_user_creation adduser_to_group adduser_user_deletion"
	check_if_package_installed adduser
	lava_test_result "adduser_package_check" "${skip_list}"
}

#Adding an user to the system with password
adduser_user_creation() {
	echo "Adding a new user to the system"
	skip_list="adduser_to_group adduser_user_deletion"	
	echo "Enter the username: $USERNAME"	
	#check the created user is existing in the list of user
	egrep "^$USERNAME" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
	else
		yes $PASSWORD | adduser $USERNAME
	fi
	cut -d: -f1 /etc/passwd | grep -i $USERNAME
	lava_test_result "adduser_user_creation" "${skip_list}"
}

#adding an user to an existing group
adduser_to_group() {
	echo "Adding a new user to the existing group"
	skip_list="adduser_user_deletion"	
	addgroup $GRP_NAME
	adduser $USERNAME $GRP_NAME
	lava_test_result "adduser_to_group" "${skip_list}"
}

#deleting user and group
clean_up() {
	echo "Delete the user from system"
	userdel $USERNAME && groupdel $GRP_NAME
	lava_test_result "adduser_user_deletion"
}

#main 
#calling all functions here
set_up
adduser_package_check
adduser_user_creation
adduser_to_group
clean_up
