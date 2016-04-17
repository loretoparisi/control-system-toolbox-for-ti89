// C Source File
// Created 8/3/2002; 2:44:51 PM

#ifndef USE_TI89	//More Recent Versions Of TIGCC Store These settings in the TPR file
	#define USE_TI89              // Compile for TI-89
	#define USE_TI92PLUS          // Compile for TI-92 Plus
	#define USE_V200              // Compile for V200
	
	#define ENABLE_ERROR_RETURN   // Enable Returning Errors to AMS
	
	#define OPTIMIZE_ROM_CALLS    // Use ROM Call Optimization
	
	#define MIN_AMS 100           // Compile for AMS 1.00 or higher
	
	#define SAVE_SCREEN           // Save/Restore LCD Contents
#endif

#include <tigcclib.h>         // Include All Header Files

// Main Function
void _main(void)
{
//error.h
	ER_throw(940);
}
