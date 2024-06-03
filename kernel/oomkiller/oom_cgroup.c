#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#define KB (1024)
#define MB (1024 * KB)
#define GB (1024 * MB)
int main(int argc, char *argv[])
{
	char *p;
again:
	while ((p = (char *)malloc(GB)))
		memset(p, 0, GB);
	while ((p = (char *)malloc(MB)))
		memset(p, 0, MB);
	while ((p = (char *)malloc(KB)))
		memset(p, 0,KB);
	sleep(1);
	goto again;
	return 0;
}
