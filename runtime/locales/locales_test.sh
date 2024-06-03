#!/bin/bash
###############################################################################
#
# DESCRIPTION :
# Adding locales package ,default locales check , new locale setting and 
# revert back to the default locale .   
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

echo "About to run locales package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Declaring a variable to get the default locale 
DEFAULT_LOCALE=`localectl | grep -i "en" | awk '{print $3}'`

#Checking for the locales package 
locales_package_check() {
	skip_list="locales_default_check locales_setup_new_locale"
	echo "Checking the locales package availability"
	check_if_package_installed locales
	lava_test_result "locales_package_check" "${skip_list}"
}
#list the locales present by default
locales_list_check() {
	echo "List the locales present by default" 
	locale
	echo "checking the default locale to english"
	localectl | grep -i "en"
	lava_test_result "locales_default_check"
}
#Set a new locale to the system
locales_new_locale_setting() {
	NEW_LOCALE="LANG=en_IN.UTF-8"
	echo "setting a new locale to en_IN.UTF-8 "
	localectl set-locale $NEW_LOCALE
	exit_on_step_fail "locales_setup_new_locale"

	localectl | grep -i "$NEW_LOCALE"
	lava_test_result "locales_setup_new_locale"
}
#Revert back the default locale setting to the system
clean_up() {
 	echo "setting up the default locale"
	localectl set-locale $DEFAULT_LOCALE
	ret=$?
	if [ $ret -eq 0 ] ; then
		echo "Default locale setting is successfull"
	else
		echo "Default locale setting is not succesfull"
	fi
}
#main
locales_package_check
(locales_list_check)
(locales_new_locale_setting)
clean_up
