#include<stdio.h>
#include<pthread.h>
#include<math.h>

#define TIME_TO_BE_SPENT 500

double spend_time(long n)
{

    double res = 0;
    long i = 0;
    while (i <n * 200000) {
        i++;
        res += sqrt(i);
    }
    return res;
}

void *thread_func(void *param)
{

    unsigned long mask = 1; /* processor 0 */

    /* bind process to processor 0 */
    if (pthread_setaffinity_np(pthread_self(), sizeof(mask),
        &mask) <0) {
        perror("pthread_setaffinity_np");
    }

    /* spend some time so the work is visible with "top" */
    spend_time(TIME_TO_BE_SPENT);

    mask = 2;   /* process switches to processor 1 now */
    if (pthread_setaffinity_np(pthread_self(), sizeof(mask),
        &mask) <0) {
        perror("pthread_setaffinity_np");
    }

    /* spend some more time to see the processor switch */
    spend_time(TIME_TO_BE_SPENT);
}


int main(int argc, char *argv[])
{

    pthread_t my_thread1, my_thread2, my_thread3, my_thread4;

    /* Create 4 thread */
    if (pthread_create(&my_thread1, NULL, thread_func, NULL) != 0) {
        perror("pthread_create");
    }

    if (pthread_create(&my_thread2, NULL, thread_func, NULL) != 0) {
        perror("pthread_create");
    }

    if (pthread_create(&my_thread3, NULL, thread_func, NULL) != 0) {
        perror("pthread_create");
    }

    if (pthread_create(&my_thread4, NULL, thread_func, NULL) != 0) {
        perror("pthread_create");
    }

    pthread_exit(NULL);
}
