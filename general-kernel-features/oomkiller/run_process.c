#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MEGABYTE 1024*1024
#define MASK "0"
#define PROC "/proc/"
#define OOM_FILE "/oom_adj"

int main(int argc, char *argv[])
{
	pid_t procid;
	char *mask=MASK;
        char procid_str[6],flocation[25]= PROC ,ch;
        FILE *fstream;

        void *myblock = NULL;
        int count = 0;

        procid=getpid();
        printf("Process ID for pidtest: %d", procid);
        sprintf(procid_str,"%d",procid);
        strcat(flocation,procid_str);
        strcat(flocation,"/oom_adj");
/*masking the current process with 0, to make it killable by OOMKiller. */
        fstream = fopen(flocation,"w");
        fputs(mask,fstream);
        fclose(fstream);

        while (1)
        {
                myblock = malloc(MEGABYTE);
                if (!myblock) break;
                memset(myblock, '\0', MEGABYTE);
                printf("Currently allocating %d MB\n", ++count);
        }

        return EXIT_SUCCESS;

}
