#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Check package update using apt tool
# Check package search using apt tool
# Check package installation using apt-tool
# Check package remove using apt-tool
# Update source from https repo using apt tool
# Update souce from ftp repo using apt tool
# Restore package state before test
#
# AUTHOR :
#      Muhammad Farhan
#
#
###############################################################################

#Importing Lava libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

echo "About to run apt package test..."

#Performing package update using apt tool
apt_update() {
	echo "Updating package using apt tool"
	apt-get -y update
	lava_test_result "apt_package_update_test"
}

# Checking package search using apt tool
apt_search() {
	echo "Checking package information"
	apt-cache search hello
	lava_test_result "apt_package_search_test"
}

# Checking package installation using apt tool
apt_package_check() {
    echo "Check if package installed by-default on system"
    check_if_package_installed hello
    is_installed=$?
    if [ $is_installed -eq 0 ]; then
        echo "Remove package if already installed on system"
        apt-get remove -y hello
    fi
    echo "Install package on system"
    apt-get install -y hello
    lava_test_result "apt_package_install_test"
}

# Removing package using apt tool
apt_remove() {
	echo "Removing package using apt"
	apt-get remove -y hello
	lava_test_result "apt_package_remove_test"
}

# To check custom file content and source update
source_update() {
    cat $apt_custom_file | grep -q ^deb
    is_exist=$? 
    if [ $is_exist -eq 0 ]; then
        echo "Run apt-get update from source URI"
        # To ignore everything in default sources.list.d and update source only from custom file
        apt-get update -o Dir::Etc::SourceList=$apt_custom_file -o Dir::Etc::SourceParts="-" -o APT::Get::List-Cleanup="0"
    fi   
}

# Update source from https repo using apt tool
apt_https() {
    echo "Adding https URL to custom list"
    apt_custom_file="$QA_TMP_DIR/custom.list"
    cat <<EOT >> $apt_custom_file
deb https://deb.debian.org/debian buster main contrib non-free
deb-src https://deb.debian.org/debian buster main contrib non-free
EOT
    echo "Update source from https repository using apt-get"
    source_update
    lava_test_result "apt_https_update_test"    
    # Remove apt custom file
    rm -f $apt_custom_file
}

# Update souce from ftp repo using apt tool
apt_ftp() {
    echo "Adding ftp URL to custom list"
    apt_custom_file="$QA_TMP_DIR/custom.list"
    cat <<EOT >> $apt_custom_file
deb http://ftp.de.debian.org/debian buster main contrib non-free
deb-src http://ftp.de.debian.org/debian buster main contrib non-free
EOT
    echo "Update source from ftp repository using apt-get"
    source_update
    lava_test_result "apt_ftp_update_test"
}
# Restore package state to system as it is before test
clean_up() {
    if [ $is_installed -eq 0 ]; then
        apt-get install -y hello
    fi
	#Remove temp folder
	remove_tmp_dir
}

#Main
create_tmp_dir
apt_update
apt_search
apt_package_check
apt_remove
apt_https
apt_ftp
clean_up
