#!/bin/bash

# 1. Check the number of processors
# 2. If uniprocessor run 'no_affinity' test
# 3. If more than one processor run 'set_affinity' and 'no_affinity' and compare the time taken
# 4. Show result summary


# 1. Check the number of processors
num_of_processors=`cat /proc/cpuinfo | grep processor | wc -l`
echo "======================================================================================"
echo Number of Processors on this system is $num_of_processors
echo ""


# 2. If uniprocessor run 'no_affinity' test
if [ $num_of_processors -eq 1 ]; then
	echo "This is a UniProcessor system. Hence, we dont run this test."
	echo "Test Result: UNSUPPORTED"
	echo "======================================================================================"
	exit 0
fi

# 3. If more than one processor run 'set_affinity' and 'no_affinity' and compare the time taken
if [ $num_of_processors -gt 1 ]; then
	echo "Running the test without setting CPU affinity, allowing SMP"

	START=$(date +%s)
	./no_affinity
	END=$(date +%s)
	DIFF1=$(( $END - $START ))
	echo "TIME TAKEN:$DIFF1 seconds"

	echo ""
	echo "Running the test by setting CPU affinity of the process to processors 0 and 1"
	START=$(date +%s)
	./set_affinity
	END=$(date +%s)
	DIFF2=$(( $END - $START ))
	echo "TIME TAKEN:$DIFF2 seconds"
	echo ""

fi

# 4. Show result summary
if [ $DIFF2 -lt $DIFF1 ]; then
	echo "Looks like there is an issue with the SMP system"
	echo "Test Result: FAIL"
	echo "======================================================================================"
	exit 1
else
	echo "SMP system has a better performance"
	echo "Test Result: PASS"
	echo "======================================================================================"
	exit 0
fi

exit
