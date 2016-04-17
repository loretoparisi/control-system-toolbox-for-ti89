// C Source File
// Created 7/29/01; 9:06:02 PM

/*	retval by Greg Dietsche
		 A simple program that always returns a value of 10.
*/

#define RETURN_VALUE	        // Return Pushed Expression
#include <tigcclib.h>         // Include All Header Files
short _ti89;                  // Produce .89Z File
short _ti92plus;              // Produce .9XZ File
// Main Function

#define CLEAN_ESTACK
#define PUSH_TEN

//#define READ_TWO				//this _should_ not be defined with any of the other defines!
//#define FOLDER_LISTING	//this _should_ not be defined with any of the other defines!

void _main(void){

#ifdef CLEAN_ESTACK
	while (GetArgType (top_estack) != END_TAG)  // Clean up arguments
	    top_estack = next_expression_index (top_estack);
  top_estack--;
#endif

#ifdef PUSH_TEN
	push_longint(10);
//	push_longint(5);
//	push_quantum(ADD_TAG);
#endif

#ifdef READ_TWO
  ESI argptr = top_estack;
  short a = GetIntArg (argptr);
  short b = GetIntArg (argptr);
  while (GetArgType (top_estack) != END_TAG)  // Clean up arguments
    top_estack = next_expression_index (top_estack);
  top_estack--;
  push_longint (a + b);
#endif

#ifdef FOLDER_LISTING
  ESI argptr = top_estack;
  SYM_ENTRY *SymPtr = SymFindFirst (GetSymstrArg (argptr), 1);
  while (GetArgType (top_estack) != END_TAG)  // Clean up arguments
    top_estack = next_expression_index (top_estack);
  top_estack--;
  push_END_TAG();
  while (SymPtr)
    {
      push_ANSI_string (SymPtr->name);
      SymPtr = SymFindNext ();
    }
  push_LIST_TAG ();
#endif


}
