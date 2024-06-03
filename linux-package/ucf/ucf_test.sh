#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# This utility provides a means of new file is the configuration file as provided by the package (either shipped with the package,or generat-
# ed by the maintainer scripts on the fly), and Destination is the location (usually under /etc) where the real configuration file lives, and
# is potentially modified by the end user. As far as possible, ucf attempts to preserve the ownership and permission of the New file as it is 
# copied to the new location.
#
# Check the ucf package is available on target or not.
# Check the generation of a new config file.
# Check the removal of config file.
#
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run ucf package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Remove any config file
cleanup() {
	rm -f /tmp/foo.conf
}	

# Check the ucf package is available on target or not.
ucf_package_check() {
	echo "Checking ucf package is available on target or not"
	skip_list="ucf_generate_config_file_test ucf_purge_config_file_test"
	check_if_package_installed ucf
	lava_test_result "ucf_package_check_test" "${skip_list}"
}

# Generating a new version maintainers copy of the configuration file of a package
ucf_generate_config_file() {
	echo "Generating a new version maintainers copy of the configuration file of a package"
	skip_list="ucf_purge_config_file_test"
	ucf /usr/share/debconf/debconf.conf /tmp/foo.conf
	step_ret=$?
	if [ $step_ret -ne 0 ]; then
		exit_on_step_fail "ucf_generate_config_file_test" "${skip_list}"
	fi
	echo "Checking hashfile entry of new configuration file"
	cat /var/lib/ucf/hashfile | grep -i "foo"
	lava_test_result "ucf_generate_config_file_test" "${skip_list}"
}

# Removing the configuration file
ucf_purge_config_file() {
	echo "Removing the configuration file"
	ucf --purge /tmp/foo.conf
	lava_test_result "ucf_purge_config_file_test"
}

#main
cleanup
ucf_package_check
ucf_generate_config_file
(ucf_purge_config_file)

