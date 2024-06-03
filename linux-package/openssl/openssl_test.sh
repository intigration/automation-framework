#!/bin/sh
###############################################################################
#
# DESCRIPTION :
# Test scripts check if openssl is installed on target
# Check list of available OpenSSL ciphers
# Check benchmark system performance
# Check generate self signed certificate
# Extract information from a certificate
# create MD5 digest of a file
#
 # Author:  Muhammad Farhan
#
###############################################################################

#Importing Lava libraries 
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

echo "About to run openssl package test..."

# Defining files path
setup() {
	file="/tmp/mycert.pem"
	md5_file="/tmp/testfile.txt"
	touch "$md5_file"
	echo "OpenSSL Test File:####This is a test file####" > "$md5_file"
}	

# Delete previous certificate if any
cleanup() {
	rm -f "$file"
	rm -f "$md5_file"
	
}

# check if openssl is installed on target
openssl_package_check() {
	echo "checking if openssl is installed"
	skip_list="openssl_cipher_check_test openssl_speed_test openssl_certificate_generate openssl_extract_certificate_information openssl_md5_digest_check" 
	check_if_package_installed openssl
	lava_test_result "openssl_package_check_test" "${skip_list}"
}

# Check list of openssl ciphers
openssl_cipher_check() {
	echo "Checking list of openssl ciphers"
	skip_list="openssl_speed_test openssl_certificate_generate openssl_extract_certificate_information openssl_md5_digest_check"
	openssl ciphers -v
	lava_test_result "openssl_cipher_check_test" "${skip_list}"
}

# Check benchmark remote connections using openssl
openssl_speed_check() {
	echo "Checking openssl benchmark speed"
	skip_list="openssl_certificate_generate openssl_extract_certificate_information openssl_md5_digest_check"
	openssl speed & sleep 20; kill $!
	lava_test_result "openssl_speed_test" "${skip_list}"
}

# Check generate self signed certificate
openssl_certificate_generate() {
	echo "Generating a self signed cerificate using openssl"
	skip_list="openssl_extract_certificate_information openssl_md5_digest_check"
	/usr/bin/expect << EOF
	set timeout -1
	spawn openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.pem -out "$file"
        expect -re {Country Name \(2 letter code\) [^:]*:} {send "IN\n"}
	expect -re {State or Province Name \(full name\) [^:]*:} {send "TEST_STATE\n"}
	expect -re {Locality Name \(eg, city\) [^:]*:} {send "TEST_AREA\n"}
	expect -re {Organization Name \(eg, company\) [^:]*:} {send "Mentor Graphics\n"}
	expect -re {Organizational Unit Name \(eg, section\) [^:]*:} {send "EPS\n"}
	expect -re {Common Name \(e.g. server FQDN or YOUR name\) [^:]*:} {send "TEST_USER\n"}
	expect -re {Email Address [^:]*:} {send "xxx.yyy@abc.com\n"}
	expect eof
EOF
	lava_test_result "openssl_certificate_generate" "${skip_list}"
}
# Extract information from a certificate 
openssl_extract_certificate_info() {
	echo "Extracting generated self signed cerificate information"
	skip_list="openssl_md5_digest_check"
        if [ ! -f "$file" ]; then
		exit_on_step_fail "openssl_extract_certificate_information" "${skip_list}"
	fi
	
	openssl x509 -text -in "$file"
	lava_test_result "openssl_extract_certificate_information" "${skip_list}"
}

# create MD5 digest of a file
openssl_md5_digest_check() {
	echo "Creating md5 digest check of a file"
	if [ ! -f "$md5_file" ]; then
		exit_on_step_fail "openssl_md5_digest_check" "${skip_list}"
	fi
	
	openssl dgst -md5 "$md5_file"
	lava_test_result "openssl_md5_digest_check" "${skip_list}"
}

#Main functions
cleanup
setup
openssl_package_check
openssl_cipher_check
openssl_speed_check
openssl_certificate_generate
openssl_extract_certificate_info
openssl_md5_digest_check

