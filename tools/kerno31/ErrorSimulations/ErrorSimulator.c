// C Source File
// Created 7/31/01; 6:22:54 PM
/*
	Error Simulator Copyright 2001-2002 by Greg Dietsche
		Simulates various error conditions that may be encountered on
		the TI-89 and TI-92+ Graphing Calculators
		
		This application is far from optimal. It was written hastilly, and 
		no care was taken to write good code. Much of the code was simply
		cut and pasted from different places to make this program work...
		
		If you feel like doing some optimization, feel free to go ahead.
		Once you are happy with the source, please send it to me so i can
		include it and credit to you in its next release.
*/
//intr.h
#define ASSUME_DUMB_USER
#define MY_SAVE_SCREEN			//comment out to destroy the Home Screen 
//#define SAVE_SCREEN			//if compiling with crash lib, you may want to define this

#define OPTIMIZE_ROM_CALLS    // Use ROM Call Optimization
//#define NO_EXIT_SUPPORT
#define NO_CALC_DETECT
#define NO_AMS_CHECK
#define USE_TI89
#define USE_TI92PLUS
#define USE_V200

#include <tigcclib.h>         // Include All Header Files
//#include "crashlib.h"						//anticrash protection

static BOOL h220xtsrInstalled(void);
unsigned long GetHardwareVersion();
UCHAR HW2PatchInstalled();
void BuildEditorMenu(volatile HANDLE hMenuStruct);

volatile HANDLE hMenuStruct;
volatile HANDLE hMenu;
short mnuResult;

// Main Function
void _main(void)
{
#ifdef MY_SAVE_SCREEN
	LCD_BUFFER b;
#endif
	//AntiCrashProtection(Crash_No_HUD);
	//AntiCrashProtection(Crash_Simple_HUD);
	//AntiCrashProtection(Crash_Debug_HUD);
	//AntiCrashProtection(Crash_File_HUD);
	//GrayOn();
	//SetPlane(DARK_PLANE);

#ifdef MY_SAVE_SCREEN
	LCD_save(b);
#endif

	if(AMS_1xx)
	{
		DlgMessage("Error Simulator","AMS 2.xx Required!",BT_OK,0);
		return;
	}

#ifdef ASSUME_DUMB_USER
	if(KEY_ENTER!=DlgMessage("Error Simulator","Warning, this program *is* designed to crash calculators for debugging purposes. Data loss can and will result from using this program!!",BT_OK,0))
		return;
#endif

	ClrScr();
	FontSetSys(F_6x8);
	DrawStrXY(12,20,"*Error Simulator 2003*",A_NORMAL);
	DrawStrXY(30,30,"By: Greg Dietsche",A_NORMAL);
	DrawStrXY(0,50,"System Information:",A_NORMAL);
	DrawStrXY(12,59,"KERNEL:",A_NORMAL);
	DrawStrXY(12,68,"HW VER:",A_NORMAL);
	DrawStrXY(0,77,"HW PATCH:",A_NORMAL);
	
//detect Kernel
	if(*(short*)0x30)
	{
		if(*(unsigned short*)0x32 == 0x4B4E)//0x4B4E==#'KN'==KerNO
			DrawStrXY(60,59,"KerNO",A_NORMAL);
		else	if(*(unsigned short*)0x32 == 0x554F)//0x554F==#'UO'==Universal OS
			DrawStrXY(60,59,"Universal OS",A_NORMAL);
		else	if(*(unsigned short*)0x32 == 0x4c58)//0x4c58==#'LX'==Lex OS
			DrawStrXY(60,59,"Lex OS",A_NORMAL);
		else	if(*(unsigned short*)0x32 == 0x544F)//0x544F==#'TO'==TEOS
			DrawStrXY(60,59,"TEOS",A_NORMAL);
		else	if(*(unsigned short*)0x32 == 0x5053)//0x5053==#'PS'==Plusshell (this was actually the FIRST Kernel... so technically speaking, kernel based programs are Plusshell programs and not DoorsOS programs... :)
			DrawStrXY(60,59,"Plusshell",A_NORMAL);
		else	if(*(unsigned short*)0x32 == 0x4454)//0x4454==#'DN'==Doors OS
			DrawStrXY(60,59,"Doors OS",A_NORMAL);
		else  if(*(unsigned short*)0x32 == 0x504F)//0x504F==#'PO'==PreOS
			DrawStrXY(60,59,"PreOS",A_NORMAL);
		else
			DrawStrXY(60,59,"Unknown Kernel",A_NORMAL);
	}
	else
	{
		DrawStrXY(60,59,"<NONE>",A_NORMAL);
	}
	
//detect Hardware Version
	if(GetHardwareVersion()==1)
		DrawStrXY(60,68,"1",A_NORMAL);
	else	if(GetHardwareVersion()==2)
		DrawStrXY(60,68,"2",A_NORMAL);
	else
		DrawStrXY(60,68,"Unknown",A_NORMAL);

//Detect HW Patch
	if(HW2PatchInstalled())
		DrawStrXY(60,77,"HW2 Patch",A_NORMAL);
	else	if(h220xtsrInstalled())
		DrawStrXY(60,77,"h220xtsr",A_NORMAL);
	else
		DrawStrXY(60,77,"<NONE>",A_NORMAL);
		
	hMenuStruct=MenuNew (2, 0, 0);
	BuildEditorMenu(hMenuStruct);
	hMenu = MenuBegin(HLock (hMenuStruct), 0, 0, 0);
	
	if((mnuResult=MenuKey(hMenu,ngetchx())))
	{
	#ifdef MY_SAVE_SCREEN
		LCD_restore(b);
	#endif
		switch (mnuResult)
		{
			case 2:
				asm(".word 0xF800 + 0x19E");
				DrawStrXY(0,20,"Rom Call 0x19E Executed",A_NORMAL);
				ngetchx();
				break;
			case 3:
				asm(".word 0xF000");
				break;
			case 4://trace
				//asm("trap #0xC;move #0x8000,%sr");
				asm("trap #0xc");
				break;
			case 5:
				asm("Infinity: jmp Infinity");
				break;
			case 6://addr err
			OSSetSR(0x777);
			 asm(			
			"move.l #0xa55,%d0\n"
			 "move.l #0x31337,%a6\n"
			 "move.w %sr,%d1\n"
			 "lea.l dummy,%a1\n"
			 "move.l %sp,%a0\n"
			 "move.l 0x11,0x11\n"
			 "dummy:\n"
			 );
			 asm("move.l 0x11,0x11");
				break;
			case 7:
			 asm("ILLEGAL");
			 break;
			case 8://div 0
			OSSetSR(0x700);
			 asm(
			 "move.l #0xa55,%d0\n"
			 "move.l #0x31337,%a6\n"
			 "move.w %sr,%d1\n"
			 "lea.l dummy2,%a1\n"
			 "move.l %sp,%a0\n"
			 "DIVU #0,%d0\n"
			 "dummy2:\n"
			 			 );
			 	asm("DIVU #0,%d0");
				break;
			case 9:
				asm("move.l #4,%d0;chk #2,%d0");
				break;
			case 10:
				asm("move #0x2,%CCR;TRAPV");
				break;
			case 11:
				asm("rte");
				break;
			case 12:
				asm("move 2,4");
				break;
			case 13:
			 asm("trap #5");
			 break;
			case 14:
			 asm("trap #6");
			 break;
			case 15:
			 asm("trap #7");
			 break;
			case 16:
			 asm("trap #8");
			 break;
			case 17:
			 asm("trap #13");
			 break;
			case 18:
			 asm("trap #14");
			 break;
			case 19:
			 asm("trap #15");
			 break;
			default:
			break;
		}
	}
	
	MenuEnd(hMenu);
	HeapFree(hMenuStruct);
#ifdef MY_SAVE_SCREEN
	LCD_restore(b);
#endif
	GrayOff();
}

void BuildEditorMenu(volatile HANDLE hMenuStruct)
{
MenuAddText(hMenuStruct, 0, "Error",						 				1, 0);
MenuAddText(hMenuStruct, 0, "Line 1111",								50, 0);
MenuAddText(hMenuStruct, 50, "$F99E (Good)",						2, 0);
MenuAddText(hMenuStruct, 50, "$F000 (Bad)",							3, 0);
MenuAddText(hMenuStruct, 1, "Infinite Loop",						5, 0);
MenuAddText(hMenuStruct, 1, "Address Error",						6, 0);
MenuAddText(hMenuStruct, 1, "Illegal Instruction",			7, 0);
MenuAddText(hMenuStruct, 1, "Divide By Zero",						8, 0);
MenuAddText(hMenuStruct, 1, "CHK",											9, 0);
MenuAddText(hMenuStruct, 1, "TRAPV",										10, 0);
MenuAddText(hMenuStruct, 1, "Privilege Violation",			11, 0);
MenuAddText(hMenuStruct, 1, "Protected Memory",					12, 0);
MenuAddText(hMenuStruct, 0, "Trap",											51, 0);
MenuAddText(hMenuStruct, 51, "5",												13, 0);
MenuAddText(hMenuStruct, 51, "6",												14, 0);
MenuAddText(hMenuStruct, 51, "7",												15, 0);
MenuAddText(hMenuStruct, 51, "8",												16, 0);
MenuAddText(hMenuStruct, 51, "13",											17, 0);
MenuAddText(hMenuStruct, 51, "14",											18, 0);
MenuAddText(hMenuStruct, 51, "15",											19, 0);
MenuAddText(hMenuStruct, 0, "Exit",							 				53, 0);
}

/*
from h220xtsr 1.10 source code:

;This will mean less detection work for future updaters.
 dc.w $5110 ;5 = signature (to make it bigger than $4e75=rts which was there in
            ;               previous versions)
            ;110 = version 1.10
;Changes in the memory resident part will ALWAYS induce a version number increase.
;Only changes which do not touch the memory resident part get lettered numbers
;(such as "1.05a"). This was always my policy.

newtrap4:
 dc.b '2Tsr' ;signature
oldtrap4: dc.l 0 ;This is a placeholder for the original trap #$4 address.

*/
static BOOL h220xtsrInstalled(void)
{		
	switch(*(ULONG*)(*(ULONG*)0xAC-8))
	{
		case 0x32547372:	//2Tsr (new signature)
		case 0x32545352:	//2TSR (old signature)
			return TRUE;
		break;
		
		default:
			return FALSE;		
	}
}

unsigned long GetHardwareVersion() // returns the Hardware version
{
  unsigned long hwpb, *rombase;
  rombase = (unsigned long *)((*(unsigned long *)0xC8) & 0x600000);
  hwpb = rombase[65];
  return (hwpb - (unsigned long)rombase < 0x10000 &&
    *(unsigned short *)hwpb > 22 ? *(unsigned long *)(hwpb + 22) : 1);
}

UCHAR HW2PatchInstalled()  // Assuming a HW2 AMS 2.xx calculator
{
  ULONG *ptr;
  if (*(ULONG *)0xAC == 0x100)
    return 1;
  ptr = (ULONG *)(((void *)EX_stoBCD)+0x52);
  if (*ptr++ != 0x700000)
    return 1;
  if (*ptr != 0x36BCFFDF)
    return 1;
  return 0;
} 

 /*
 from KerNO source code
 ;detect HW2 Patch
 EX_stoBCD 	equ	$C0
 move.l $c8,a4
 move.l EX_stoBCD*4(a4),a0
 tst.w 92(a0) ;HW2Patch - ROM
 beq ContinueInstall 
 cmp.l #$100,$ac ;HW2Patch - RAM
 beq ContinueInstall
 */
 