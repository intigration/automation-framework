#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# gpgv is an OpenPGP signature verification tool. 
# It is somewhat smaller than the fully-blown gpg and uses a different (and simpler) way to check that the public keys used to make the signature are valid.
#
# Check the gpgv package is available on target or not.
# Check the gpgv package version.
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run gpgv package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Check the gpgv package is available on target or not.
gpgv_package_check() {
	echo "Checking gpgv package is available on target or not"
	skip_list="gpgv_version_check_test"
	check_if_package_installed gpgv
	lava_test_result "gpgv_package_check_test"
}

gpgv_version_check() {
	echo "Checking gpgv package version"
	gpgv --version
	lava_test_result "gpgv_version_check_test"
}

#main
gpgv_package_check
(gpgv_version_check)
