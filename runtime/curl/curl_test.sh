#!/bin/sh
###############################################################################
#
# DESCRIPTION :
#
# Verify curl package on target
# Verify curl functionalities on target
#
 Author: Muhammad Farhan
#
###############################################################################

#import lava_library
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

#check the curl package on target
curl_package_check() {
	echo "check the curl package on target"
	skip_list="curl_version_check curl_file_download curl_multiple_file_download curl_xargs_functionality_check curl_query_http_headers curl_post_request_with_parameters curl_sending_website_cookies curl_store_website_cookies curl_limit_download_rate"
	check_if_package_installed curl
	lava_test_result "curl_package_check" "${skip_list}"
}

#Clean up the created files
cleanup() {
	cd ${PWD}/curl
	rm -f cnncookies.txt index.html > /dev/null 2>&1
}

#Check the curl functionalities on the target
curl_functions_check() {
	echo "check version of curl on target"
	curl --version
	lava_test_result "curl_version_check"

	echo "check download of a file"
	curl -O http://xmlsoft.org/index.html
	lava_test_result "curl_file_download"

	echo "check the download of multiple files"
	curl -O http://xmlsoft.org/examples/index.html -O http://xmlsoft.org/index.html
	lava_test_result "curl_multiple_file_download"

	echo "check the xargs functionality of curl"
	xargs -n 1 curl -O < curl/curl_test.txt
	lava_test_result "curl_xargs_functionality_check"

	echo "Check the query http headers using curl"
	curl -I www.tecmint.com
	lava_test_result "curl_query_http_headers"

	echo "Check the post request with parameters using curl"
	curl --data "firstName=Mentor&lastName=graphics" http://xmlsoft.org/ChangeLog.html
	lava_test_result "curl_post_request_with_parameters"

	echo "Check the sending of website cookies"
	update-ca-certificates --fresh  #SSL certificate problem will occur without fresh updates of ca-certificates
	curl -I https://www.cnn.com --user-agent "I am a new web browser"
	lava_test_result "curl_sending_website_cookies"

	echo "check the storing of website cookies"
	curl --cookie-jar cnncookies.txt https://www.cnn.com/index.html -O
	lava_test_result "curl_store_website_cookies"

	echo "Check the limiting download rate"
	curl --limit-rate 100K  https://github.com/linux-test-project/ltp/releases/download/20200120/ltp-full-20200120.tar.bz2 -O
	lava_test_result "curl_limit_download_rate"
}

#Main
curl_package_check
curl_functions_check
cleanup
