#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# The ncurses library routines are a terminal-independent method of updating character screens with reasonable optimization.
# This package contains the programs used for manipulating the terminfo database and individual terminfo entries, as well as some programs for resetting terminals and such. 
#
# Check the ncurses-bin package is available on target or not.
# Check the list of installed ncurses-bin package
# Print out x11 terminal emulator descriptions
#
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run ncurses-bin package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib
	
# Check the ncurses-bin package is available on target or not.
package_check() {
	echo "Checking ncurses-bin package is available on target or not"
	skip_list="ncurses-bin_package_list_test ncurses-bin_xterm_terminal_info"
	check_if_package_installed ncurses-bin
	lava_test_result "ncurses-bin_package_check_test" "${skip_list}"
}

# Check the list of binary available in ncurses-bin package
package_list() {
	echo "Checking the list of installed ncurses-bin package"
	dpkg -l ncurses-bin
	lava_test_result "ncurses-bin_package_list_test"
}

# Print out terminfo descriptions of debian x11 terminal emulator
terminal_info() {
	echo "printing terminal emulator descriptions of Debian x11"
	infocmp xterm
	lava_test_result "ncurses-bin_xterm_terminal_info"
}

#main
package_check
(package_list)
(terminal_info)
