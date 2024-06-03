#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#The ncurses library routines are a terminal-independent method of updating character screens with reasonable optimization.
#This package contains terminfo data files to support the most common types of terminal, 
#including ansi, dumb, linux, rxvt, screen, sun, vt100, vt102, vt220, vt52, and xterm
#
# Check the ncurses-base package is available on target or not.
# Check the terminal capability data base 
#
Author: Muhammad Farhan
#
###############################################################################

echo "About to run ncurses-base package test..."

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib
	
# Check the ncurses-base package is available on target or not.
package_check() {
	echo "Checking ncurses-base package is available on target or not"
	skip_list="ncurses-base_terminal_capability_database_check"
	check_if_package_installed ncurses-base
	lava_test_result "ncurses-base_package_check_test" "${skip_list}"
}

# Check the terminal capability data base 
terminfo_check() {
	echo "Checking the terminal capability data base"
	ls -l /lib/terminfo/*/*
	lava_test_result "ncurses-base_terminal_capability_database_check"
}

#main
package_check
terminfo_check
