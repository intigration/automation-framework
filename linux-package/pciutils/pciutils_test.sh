#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Test scripts check if pciutils is installed on target
# Check hardware devices information connected to PCIe bus
# Check physical PCI buses hierarchy as a tree
# Check Kernel Drivers information of PCI buses
#
Author: Muhammad Farhan
#
###############################################################################

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

echo "About to run pciutils package test..."

# check if pciutils is installed on target
pciutils_package_check() {
	echo "checking if pciutils is installed on target" 
	skip_list="pciutils_pci_buses_info_test pciutils_pci_device_tree_test pciutils_pci_device_kernel_driver_test"
	check_if_package_installed pciutils
	lava_test_result "pciutils_package_check_test" 
}

# Check hardware devices information connected to PCIe bus
pci_device_info() {
	echo "Checking hardware devices information connected to PCIe bus"
	lspci
	lava_test_result "pciutils_pci_buses_info_test"
}

# Check physical PCI buses hierarchy as a tree
pci_device_tree() {
	echo "Checking physical PCI buses hierarchy as a tree"
	lspci -t
	lava_test_result "pciutils_pci_device_tree_test" 
}

# Check Kernel Drivers information of PCI buses
pci_kernel_driver() {
	echo "Checking Kernel Drivers information of PCI buses"
	lspci -k
	lava_test_result "pciutils_pci_device_kernel_driver_test" 
}

# Main
pciutils_package_check
(pci_device_info)
(pci_device_tree)
pci_kernel_driver

