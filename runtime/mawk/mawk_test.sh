#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#mawk is an interpreter for the AWK Programming Language. 
#The AWK language is useful for manipulation of data files, text retrieval
#and processing, and for prototyping and experimenting with algorithms.
#
# Check the mawk package is available on target or not.
# Prints all lines of data from the specified file using mawk
# Prints a pattern of data from the specified file using mawk
#
 # Author:  Muhammad Farhan
###############################################################################

echo "About to run mawk package test..."

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#Defining file
setup() {
	test_file="/tmp/test.txt"
	touch "$test_file"
	echo "Hello \nWorld \nMorning\n" >> "$test_file"
}
	
# Remove any config file
cleanup() {
	rm -f "$test_file"
}	

# Check the mawk package is available on target or not.
package_check() {
	echo "Checking mawk package is available on target or not"
	skip_list="mawk_print_line_test mawk_print_pattern_test"
	check_if_package_installed mawk
	lava_test_result "mawk_package_check_test" "${skip_list}"
}

# Prints all lines of data from the specified file using mawk
print_line() {
        echo "prints all lines of data from the specified file using mawk"
        mawk '{print}' "$test_file" 
        lava_test_result "mawk_print_line_test"
}

# Prints a pattern of data from the specified file using mawk
print_pattern() {
        echo "prints a pattern of data from the specified file using mawk"
        mawk '{print}' "$test_file" | grep -i "hello" 
        lava_test_result "mawk_print_pattern_test"
}

#main
setup
package_check
(print_line)
(print_pattern)
cleanup
