/*
 * This test calls gettimeofday() repeatedly.  It reports an error if
 * the time returned by a call is earlier than the previous call to
 * gettimeofday().
 *
 * Usage: Tu-hrt_11210 [duration]
 *	duration: length of time the program will run
 *
 * If duration is not supplied, the program will run forever unless killed.
 */

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/time.h>

void PrintUsage(void);
void handler(int);

int killed = 0;

int main(int argc, char *argv[])
{
	struct timeval tv0;
	struct timeval tv1;
	struct timeval tvstart;
	long long iter = 0;
	int error_count = 0;
	int duration = 0;
	int current_duration = 0;
	int error_limit = 50;

	if (argc == 1)
		;
	else if (argc == 2)
		duration = atoi(argv[1]);
	else {
		PrintUsage();
		return 1;
	}

	if (duration)
		printf("\nTest to be run for %d seconds.\n",duration);
	else
		printf("\nTest to be run until killed.\n");

	signal(SIGINT, handler);
	signal(SIGQUIT, handler);

	printf("Starting gettimeofday test\n");

	gettimeofday(&tv0, NULL);
	tvstart = tv0;
	while (1) {
		gettimeofday(&tv1, NULL);

		current_duration = tv1.tv_sec - tvstart.tv_sec;
		if (duration != 0 && current_duration >= duration)
			break;

		if (error_count >= error_limit) {
			printf("Test hit errors limit set at %d. "
				"Stopping test.\n", error_limit);
			break;
		}

		if (killed) {
			printf("Test killed.\n");
			break;
		}

		if ((tv1.tv_sec < tv0.tv_sec) ||
		    ((tv1.tv_sec == tv0.tv_sec) &&
		     (tv1.tv_usec < tv0.tv_usec))) {
			printf("duration: %d, "
			       "t0: %d.%06d > t1: %d.%06d (iter=%lld)\n",
			       current_duration, tv0.tv_sec, tv0.tv_usec,
			       tv1.tv_sec, tv1.tv_usec, iter);
			error_count++;
		}
		tv0 = tv1;
		iter++;
	}

	printf("Test ran for %d seconds.\n", current_duration);

	if (error_count) {
		printf("FAIL: Gettimeofday went backwards in time %d times.\n",
			error_count);
		return 1;
	}

	printf("PASS: Gettimeofday test passed.\n");
	return 0;
}

void PrintUsage() {
	printf("\n"
		"<number of seconds>: Run for a specified number of seconds\n"
		"		    : Run in a loop\n");
}

void handler(int signo)
{
	killed = 1;
}
