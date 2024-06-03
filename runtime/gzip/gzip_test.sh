#!/bin/sh

###############################################################################
#
# DESCRIPTION :
# Test script  verifies the availability of gzip package,
# Verifies the compression of file,Verifies the decompression of file.
#
Author: Muhammad Farhan
# 
###############################################################################

echo "About to run gzip package test..."
#textfile path
textFile="/tmp/textfile.txt"
zippedFile="/tmp/textfile.txt.gz"

# Importing Lava libraries
. ../lib/sh-test-lib

# Importing debian wrapper libraries
. ../lib/sh-debian-lib

# Deleting log file
cleanup() {
	if [ -f "$textFile" ]; then
		rm -f $textFile

	fi
	if [ -f "$zippedFile" ]; then
		rm -f $zippedFile

	fi
}
setup() {
	touch $textFile
	dd if=/dev/zero of=$textFile bs=1024 count=1024
}

#Gzip Package Test
gzip_package_check() {
	# Add your testcases in skip_list if you want to skip
	skip_list="gzip_compress_check gzip_decompress_check"
	echo "Checking for Gzip Package..."
	check_if_package_installed gzip
	lava_test_result "gzip_package_check" "${skip_list}"
}
#Test compressing a file using gzip
gzip_compress_check() {
	skip_list="gzip_decompress_check"
	echo "Gzip : Compressing a file check..."
	fileSize= `du -h $textFile | cut -f1`
	echo $fileSize
	gzip $textFile
	zippedSize= `du -h $zippedFile` | cut -f1
	ls /tmp | grep "textfile.txt.gz"
	if [ $? -eq 0 ] && [ $zippedSize -lt $fileSize ]; then
        	lava_test_result "gzip_compress_check" "${skip_list}"
	fi
}
#Test decompressing a file using gzip
gzip_decompress_check() {
	echo "Gzip: Decompressing a file check"
	gzip -d $zippedFile
	ls /tmp | grep "textfile.txt"
	lava_test_result "gzip_decompress_check" ""
	
}

cleanup
setup
gzip_package_check
gzip_compress_check
(gzip_decompress_check)
cleanup
