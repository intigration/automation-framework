/**********************************************************************************
* file: glib2_0_test_program.c
# Author:  Muhammad Farhan* Description: This is a c program application for tossing a coin using glib library
***********************************************************************************/

#include <glib.h>

int main(void)
{
	gboolean result;

	result = g_random_boolean();
	if (result == TRUE) {
		g_print("Heads\n");
	}
	else {
		g_print("Tails\n");
	}
	return 0;
}
