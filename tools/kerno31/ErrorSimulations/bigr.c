// C Source File
// Created 7/28/01; 4:20:08 PM
/*
	bigr 2001 by Greg Dietsche
		This is designed to produce an executable that won't run on AMS 2.xx without KerNO
*/

#include <tigcclib.h>         // Include All Header Files
short _ti89;                  // Produce .89Z File
short _ti92plus;              // Produce .9XZ File
#define USE_V200

 LCD_BUFFER t[10];
 
void _main(void)
{
 t[3][3]=3;
 ST_helpMsg("Big is working...");
}
