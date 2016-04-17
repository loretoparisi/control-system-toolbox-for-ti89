// C Source File
// Created 12/26/2001; 3:08:32 PM

#define USE_TI89              // Produce .89z File
#define USE_TI92PLUS          // Produce .9xz File
#define USE_V200

//#define RETURN_VALUE result // Redirect Return Value
#define RETURN_VALUE
#define OPTIMIZE_ROM_CALLS    // Use ROM Call Optimization

// #define SAVE_SCREEN        // Save/Restore LCD Contents

#include <tigcclib.h>         // Include All Header Files

// Main Function
void _main(void)
{
	
  ESI argptr = top_estack;
  short a = GetIntArg (argptr);
  short b = GetIntArg (argptr);
  while (GetArgType (top_estack) != END_TAG)  // Clean up arguments
    top_estack = next_expression_index (top_estack);
  top_estack--;
  
  push_longint (a + b);

}
