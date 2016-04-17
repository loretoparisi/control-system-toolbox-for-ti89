// C Source File
// Created 6/9/2002; 3:26:31 PM

#define USE_TI89              // Compile for TI-89
#define USE_TI92PLUS          // Compile for TI-92 Plus
#define USE_V200              // Compile for V200

#define USE_FLINE_ROM_CALLS
#define OPTIMIZE_ROM_CALLS    // Use ROM Call Optimization
#define MIN_AMS 204           // Compile for AMS 2.04 or higher
#define SAVE_SCREEN           // Save/Restore LCD Contents
#include <tigcclib.h>         // Include All Header Files

/*
ams 2.05 has several diffent line F emulations this program tests them:

	6 byte bsr w/long word displacement
		.word $FFF0
		.long displacement

	4 byte ROM CALL
		.word $FFF2
		.word rom call index

	2 byte ROM CALL
		.word $F800 + Rom Call Index	valid range $0 through $7EF inclusive

	6 byte bra w/long word displacement
		.word $F800 + $7F1	($FFF1)
		.long displacement
*/

/*
 sorry... at first i thought a c example would be better, but an asm version might be a bit easier to understand...
 
*/

// Main Function
void _main(void)
{

	ST_helpMsg("F800+rom idx FLINE executed");	//ST_helpMsg is automatically a fline instuction due to USE_FLINE_ROM_CALLS
	ngetchx();
	//asm(".word 0xF800+0x29b");	//idle

asm("
TestBsr:
	.word 0xFFF0
	.long (TestBsrFunc-TestBsr)-2
	bra BsrTestFinished
	
TestBsrFunc:
	rts

BsrTestFinished:
	");
	ST_helpMsg("$FFF0 FLINE executed");ngetchx();
	
	asm("bra TestBra");
	asm("retBra:");
	ST_helpMsg("$FFF1 FLINE executed");ngetchx();
	

	asm(".word 0xFFF2
	   .word 0x19E*4 /* ClrScr */");
	ST_helpMsg("FFF2 index*4 FLINE executed");ngetchx();
}


asm("
TestBra:
	.word 0xFFF1	/* $FFF1 bra with long word displacement test */
	.long (retBra-TestBra)-2
	");


