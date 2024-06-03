#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# This script verifies perl package check and perl interpreter check .      
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################
echo "About to run perl package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Checking the perl package
perl_package_check() {
	skip_list="perl-base_interpreter_check"
	echo "checking the perl package availability"
	check_if_package_installed perl-base
	lava_test_result "perl-base_package_check" "${skip_list}"
}

#checking the interpreter functionality
perl_interpreter_check() {
	echo "Checking the perl interpreter"
	echo "Presently on current shell"
	i=12
	echo $i
	echo "Checking perl interpreter from current shell"
	perl <<__HERE__
	print "This is in perl\n";
	my \$i = $i;
	print ++\$i . "\n";
__HERE__
lava_test_result "perl-base__interpreter_check"
}

#main
perl_package_check
perl_interpreter_check
