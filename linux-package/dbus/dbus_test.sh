#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# D-Bus is a message bus, used for sending messages between applications.
# Test script verifies the availability of Dbus package, checks the status of dbus-service.
# Verifies the process status of dbus-daemon. Checks the working of dbus-send and dbus-monitor.
#
# Author:  Muhammad Farhan
#
###############################################################################

echo "About to run dbus package test..."
# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#dbus Package Check
dbus_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="dbus_service_status_check dbus_daemon_process_status_check dbus_send_methods_check dbus_monitor_check"
	echo "Checking for dbus Package"
	check_if_package_installed dbus
	lava_test_result "dbus_package_check" "${skip_list}"
}

#dbus service status Check
dbus_service_status_check() {
	skip_list="dbus_daemon_process_status_check dbus_send_methods_check dbus_monitor_check"
	echo "Testing dbus service status..."
	systemctl |  grep -i "dbus.service " | grep -i "running"
	lava_test_result "dbus_service_status_check" "${skip_list}"

}

#dbus-daemon process status Check
dbus_daemon_process_status_check() {
	echo "Testing dbus-daemon process status..."
	ps -aef | grep -i "[d]bus-daemon"
	lava_test_result "dbus_daemon_process_status_check" ""
}

#dbus send command check
dbus_send_check() {
	echo "Checking list of all methods available behind a dbus service"
	dbus-send --system --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames
	lava_test_result "dbus_send_methods_check" ""
}

#dbus monitor command check
dbus_monitor_check() {
	echo "Testing dbus-monitor command..."
	dbus-monitor --system & sleep 5; kill $!
	lava_test_result "dbus_monitor_check" ""
}

#main
dbus_package_check
dbus_service_status_check
(dbus_daemon_process_status_check)
(dbus_send_check)
dbus_monitor_check
