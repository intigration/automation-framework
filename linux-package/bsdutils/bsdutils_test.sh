#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script  verifies the availability of bsdutils package.
# This package contains the bare minimum of BSD utilities needed for a Debian system: logger, renice, script, scriptreplay, and wall. 
# The remaining standard BSD utilities are provided by bsdmainutils.
# 
# bsdutils package is part of util-linux and hence further tests are provided in util-linux open source package tests.
#
#
# AUTHOR :
#      Anantha K R <anantha_kr@mentor.com>
#
# Modified By :
#      Srinuvasan Arjunan <srinuvasan_a@mentor.com>
#
###############################################################################

echo "About to run bsdutils package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

bsdutils_package_check() {
	# Add your testcases in skip_list if you want to skip
	echo "Checking for bsdutils package availability"
	check_if_package_installed bsdutils
	lava_test_result "bsdutils_package_check"
}

#main
bsdutils_package_check
