/**********************************************************************************
* file: glib2_0_version.c
Author: Muhammad Farhan* Description:  This is a c program application checking verion of glib2.0 package
*
***********************************************************************************/
#include <glib.h>

int main(void)
{
	g_print("glib version number is %d.%d.%d\n", GLIB_MAJOR_VERSION, GLIB_MINOR_VERSION, GLIB_MICRO_VERSION);
	g_print("GLIB_MAJOR_VERSION = %d\n", GLIB_MAJOR_VERSION);
	g_print("GLIB_MINOR_VERSION = %d\n", GLIB_MINOR_VERSION);
	g_print("GLIB_MICRO_VERSION = %d\n", GLIB_MICRO_VERSION);
	return 0;
}
