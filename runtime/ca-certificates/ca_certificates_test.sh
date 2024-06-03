#!/bin/bash
###############################################################################
#
# DESCRIPTION :
#
# This test-script generate crt file and get updated the certificate file
# using ca-certificates package.
#
# Author:  Muhammad Farhan
#
###############################################################################
echo "About to run ca-certificates package test..."

#Importing LAVA libraries
. ../lib/sh-test-lib

#Importing debian wrapper libraries
. ../lib/sh-debian-lib

#set up the directory
set_up() {
    CRT_DIR=/usr/local/share/ca-certificates/extra
    mkdir -p $CRT_DIR
}

#Cleanup the generated keys
clean_up() {
	rm -rf server.*
	rm -rf $CRT_DIR
}

#Generate secure key
generate_secure_key() {
    skip_list="ca_certificate_generate_insecure_key ca_certificate_generate_csr_file ca_certificate_generate_crt_file ca_certificate_update_ca_certificate"
    /usr/bin/expect << EOF
    set timeout 10
    spawn  openssl genrsa -des3 -out server.key 2048
    expect "server.key:"
    send "root\r"
    expect "server.key:"
    send "root\r"
    expect eof
EOF
    lava_test_result "ca_certificate_generate_secure_key" "${skip_list}"
}

#Generate insecure key for the server
generate_insecure_key() {
    skip_list="ca_certificate_generate_csr_file ca_certificate_generate_crt_file ca_certificate_update_ca_certificate"
    /usr/bin/expect << EOF
    set timeout 10
    spawn openssl rsa -in server.key -out server.key.insecure
    expect "server.key:"
    send "root\r"
    expect eof
EOF
#rename the existing keys
    mv server.key server.key.secure
    mv server.key.insecure server.key
    lava_test_result "ca_certificate_generate_insecure_key" "${skip_list}"
}

#Generate csr file
generate_csr_file() {
    skip_list="ca_certificate_generate_crt_file ca_certificate_update_ca_certificate"
    /usr/bin/expect << EOF
    set timeout 10
    spawn  openssl req -new -key server.key -out server.csr
    expect ":"
    send "in\n"
    expect ":"
    send "karnataka\r"
    expect ":"
    send "bangalore\r"
    expect ":"
    send "mentor\r"
    expect ":"
    send "eps\r"
    expect ":"
    send "user\r"
    expect ":"
    send "user@mentor.com\r"
    expect ":"
    send "root\r"
    expect ":"
    send "root\r"
    expect eof
EOF
    lava_test_result "ca_certificate_generate_csr_file"	"${skip_list}"
}

#Generate a crt file
generate_crt_file() {
    skip_list="ca_certificate_update_ca_certificate"
    openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
    lava_test_result "ca_certificate_generate_crt_file"	"${skip_list}"
}

#Update generated ca-certificate
update_ca_certificate() {
    cp server.key $CRT_DIR
    update-ca-certificates
    lava_test_result "ca_certificate_update_ca_certificate"
}

#Main
set_up
generate_secure_key
generate_insecure_key
generate_csr_file
generate_crt_file
update_ca_certificate
clean_up
