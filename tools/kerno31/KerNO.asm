; Assembly Source File
; Created 7/25/01, 8:17:28 PM

;**********************************************************************************************
;*** KerNO for the TI-89, TI-92+, and TI-V200 By Gregory Dietsche Copyright (C) 2001 - 2004 ***
;*** Description: Rough approximation: DoorsOS for NOSTUB Programs...                       ***
;**********************************************************************************************

;NOTE: use build.bat to build KerNO, and not the TIGCC IDE

;Goals:
;Completed
 ;Goal: To provide some features that Kernels provide without the kernel...
 ;Goal: To provide a line 1111 emulator similar to the one found on ams 2.04=>
 ;Goal: To provied protection from exceptions
 ;Goal: To break asm size limit
 ;Goal: TO allow asm programs to return a value in an expression hostile AMS versions ($A emulator)
 ;Goal: Provide ESC->ON to break out of hung programs.


;uncomment to...
;NoVTISupport	set 0	;Exclude Support For VTI 2.5 beta 5

 include "OS.h"

;this macro requires that a4 be initialized with move.l $c8,a4
;prior to its use
ROM_CALL3 macro
 move.l \1*4(a4),a0
 jsr (a0)
 endm

;this macro makes use of the line 1111 emulator for making rom calls...
;it requires either KerNO, or AMS version 2.04 or greater
ROM_CALLF macro
 dc.w $F800+\1
 endm

;makes use of the line 1010 emulator... error codes are those listed in the calc's guide book...
ERR_THROW macro
 dc.w $A000+\1
 endm

;Several Important Constants

VERSION_MAJOR	equ	3
VERSION_MINOR 	equ	1
VERSION_REV	equ	0
KERNO_VERSION	equ $0021	;Identify the installed version of kerno (for the exception vector table)

KERNO_ID	equ 'KN'	;Identifies KerNO
;KERNO_SIG	equ '68kN'	;would take the place of the Doors 68kP/68kL if implemented
K_VER		equ $30		;version number pointer(word)
K_ID		equ $32		;kernel id pointer(word)
K_EXEC		equ $34		;Pointer to the exec function
K_UNINST	equ $38		;pointer to the uninstall function

  ifnd FL_getHardwareParmBloc
FL_getHardwareParmBloc equ $16B	;used to detect calc type: 89 or ti-92p/v200
  endc
  ifnd AB_getGateArrayVersion
AB_getGateArrayVersion equ $15E	;used to get Gate Array Version (HW2 or not)
  endc
  ifnd HeapWalk
HeapWalk	       equ $12C
  endc

 xdef _nostub
 xdef _ti89
 xdef _ti92plus
 xdef _main


NOSTUBHeaderStart:
 move.l (a7),(a7)
 bra.w NOSTUBHeaderEnd
 dc.w $2e76,$5c7b,$4e74,$4e72,$4afc,0
 dc.l $01000000		;Standard Revision of Comment Format Required to read this header
 dc.w 2			;Number of extensions
 dc.w 0			;_comment identifier
 dc.w _comment-NOSTUBHeaderStart
 dc.w 6			;flags identifier
 dc.w _incompatFlags-NOSTUBHeaderStart

_incompatFlags		dc.w %0000000000010111

 EVEN	;not necessary here, but for completeness

NOSTUBHeaderEnd:

_main:
; bra _main
 movem.l a0-a6/d0-d7,-(sp)
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;check to see if installed
 tst.w K_VER
 beq \InstallKerno
 cmp.w #KERNO_ID,K_ID	;kernel identifier
;address to the uninstall routine... ram resident so later versions can
;uninstall earlier versions without alot of extra code (this assumes a bug free uninstall routine :)
 bne PreviousKernel	;a kernel other than KerNO is installed
 move.l K_UNINST,a0

;-------------
;KerNO 2.0 and 2.1 used TWO FLINE instructions after removing KerNO's
;FLINE handler. This caused the uninstall routine to crash on
;AMS versions 2.00 - 2.03
; cmp.w #$11,$30			;check for buggy kerno 2.1 uninstall routine
; beq \PatchNeeded
; cmp.w #$10,$30			;check for buggy kerno 2.0 uninstall routine
; bne \NoPatchNeeded
;\PatchNeeded:
; move.w #$4E71,104(a0)		;change the offensive FLINE instruction to a nop
; move.w #$4E71,110(a0)		;change the offensive FLINE instruction to a nop
;\NoPatchNeeded
;-------------

 jsr (a0)
\FinishDeinstall:
 bra EmergencyExit
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;install code for kerno...
\InstallKerno:

;detect AMS 1.xx
 move.l $c8,a4
 cmp.l #1000,-4(a4) ;check if more than 1000 entries
 bcs NeedAMS2.xx ;if no, it is AMS 1.xx

 ifnd NoVTISupport
   bsr CheckVTI
   bne \NotVTI	;vti is treated as hw1
 endc

;detect Hardware Version
 ROM_CALL3 AB_getGateArrayVersion
 cmpi.l #1,d0
 beq ContinueInstall	;it was hw1

;detect HW2 Patch - this also detects hw3 patch
 ;ROM_CALL2 EX_stoBCD
 move.l EX_stoBCD*4(a4),a0
 tst.w 92(a0) ;HW2Patch - ROM
 beq ContinueInstall
 cmp.l #$100,$ac ;HW2Patch - RAM
 bne NeedHWPatch ;if it is not the old one, show error message

\NotVTI:


ContinueInstall:
;allocate ram for the RAM Resident Portion of KerNO
 move.l #(KernoEnd-KernoBegin),-(sp)
 ROM_CALL3 HeapAllocHigh
 addq.l #4,sp

 tst.w d0
 beq LowRam

 move.w d0,-(sp)
 ROM_CALL3 HeapDeref
 addq.l #2,sp
 
 bclr.b #2,$600001

 move.l a0,a3		;save the pointer for later
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Now, set up the Exception Vector Table
 move.w #KERNO_VERSION,K_VER
 move.w #KERNO_ID,K_ID

 lea OffsetTable(pc),a4		;how far from a3
 lea InstallTable(pc),a5	;vector pointers
 lea UninstallTable(pc),a6	;the saved vectors

 moveq.l #0,d1
 moveq.l #0,d2
 moveq.w #(EndInstallTable-InstallTable)-1,d0	;how many loops?
 
\InstallLoop:
 move.b (a5)+,d2	;get the address of the old vector
 move.w d2,a1
 move.l (a1),(a6)+	;save the old vector
 move.w (a4)+,d1	;get the offset from the beginning
 move.l a3,a0		;restore a0
 adda.l d1,a0		;add the offset to the pointer
 move.l a0,(a1)		;install the new interrupt vector
 dbra d0,\InstallLoop

 move.l #$64,a0
 lea OldAutoInt1(pc),a1
 moveq.l #((OldAutoInt5-OldAutoInt1)/4)-1,d0
\SaveIntsLoop:
 move.l (a0)+,(a1)+
 dbra d0,\SaveIntsLoop

 ifnd NoVTISupport
;Disable Privilege Violation trapping if KerNO is running On vti
;If this is removed, vti will hang and/or crash when entering the debugging console
 bsr CheckVTI
 beq \NotVTI
 move.l OldPrivError(pc),$20
\NotVTI:
 endc

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;copy KerNO to the ram
;this is done after setting up the vectors so
;that the saved vector table is saved in the new location
 move.l #(KernoEnd-KernoBegin),-(sp)
 pea.l KernoBegin(pc)
 move.l a3,-(sp)

 ROM_CALL memcpy
; lea.l 12(sp),sp

 bsr FastKeyboard	;initial keyboard speedup

 bset.b #2,$600001
 
;Display Successful Installation Message
 pea InstallStr(pc)
 bsr DisplayError
; addq.l #4,sp
 lea.l 16(sp),sp	;12 + 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;
EmergencyExit:
 movem.l (sp)+,a0-a6/d0-d7
 rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;
NeedAMS2.xx:
 pea NeedAMS2.xxStr(pc)
 bra.s DoHelpMsg
;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ifnd h220
NeedHWPatch:
 pea NeedPatchStr(pc)
 bra.s DoHelpMsg
 endc
;;;;;;;;;;;;;;;;;;;;;;;;;;;
PreviousKernel:
 pea PreviousKernelStr(pc)
 bra.s DoHelpMsg
;;;;;;;;;;;;;;;;;;;;;;;;;;;
LowRam:
 pea LowRamStr(PC)
 ;bra.s DoHelpMsg
;;;;;;;;;;;;;;;;;;;;;;;;;;;
DoHelpMsg:
 bsr DisplayError
 addq.l #4,sp
 bra.s EmergencyExit
;;;;;;;;;;;;;;;;;;;;;;;;;;;

 EVEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoBegin:
;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoExec:
\DoorsPrgm:
 pea KernoDoorsStr(pc)
 bsr DisplayError
 addq.l #8,sp	;4 for KernoDoorsStr, 4 to return to the ams instead of continuing the DoorsOS program (they use bsr to get here)
 rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoUninstall:
 bclr.b #2,$600001
 
 move.l #0,K_VER
 move.l #0,K_EXEC
 move.l #0,K_UNINST

;restore normal keyboard operation - it is important that this is done before
;the LINE F handler is removed on ams < 2.04
 move.w #48,-(sp)
 ROM_CALLF OSInitBetweenKeyDelay	;default value: 48
 move.w #336,(sp)
 ROM_CALLF OSInitKeyInitDelay		;default value: 336

 lea InstallTable(pc),a1			;vector pointers
 lea UninstallTable(pc),a2			;the saved vectors
 moveq.w #EndInstallTable-InstallTable-1,d0	;how many loops?
 moveq.l #0,d1

 \UnInstallLoop:
 move.b (a1)+,d1	;get the address of the KerNO vector
 move.w d1,a0
 move.l (a2)+,(a0)	;restore the old ti-os vector
 dbra.s d0,\UnInstallLoop

 lea KernoBegin(pc),a0
 move.l a0,-(sp)
 ROM_CALL HeapPtrToHandle
 move.w d0,-(sp)
 ROM_CALL HeapFree

 pea KernoDeInStr(pc)
 bsr DisplayError

 lea 12(sp),sp
 bset.b #2,$600001
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoAddressError:
;vti bug: VTI stacks the short exception frame instead of the long one
 ifnd NoVTISupport
   bsr CheckVTI
   beq \NotVTI
   subq.l #8,sp	;vti stacks 6 bytes, so 14-8==6
\NotVTI:
 endc

 lea 14(sp),sp

 move #$700,sr
 pea AddressError(pc)
 bra Recover
;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoIllegalError:
 addq.l #6,sp
 move #$700,sr
 pea IllegalError(pc)
 bra Recover
;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoDivError:
 addq.l #6,sp
 move #$700,sr
 pea DivError(pc)
 bra Recover
;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoCHKError:
 addq.l #6,sp
 move #$700,sr
 pea CHKError(pc)
 bra Recover
;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoTRAPVError:
 addq.l #6,sp
 move #$700,sr
 pea TRAPVError(pc)
 bra Recover
;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoPrivError:
 addq.l #6,sp
 move #$700,sr
 pea PrivError(pc)
 bra Recover

KernoLine1010Emulator:
 move.l a0,-(sp)	;trust me, saving a0 is _absolutely_ necessary

 move.l 6(sp),a0	;pointer to the op-code
 move.w (a0),a0		;the actual op-code/error code

 cmp.w #$A0A1,a0	;$A1 = ASAP or Exec string too long
 beq \skiperror

 cmp.w #$A244,a0	;$244 = Invalid program reference
 beq \skiperror

; cmp.w #$A2B2,a0	;tiams.h	EXPECTED_RPAR_ERROR
; beq \skiperror

; call the old line 1010 emulator
 move.l (sp)+,a0
 move.l OldLineAEmulator(pc),-(sp)
 rts

\skiperror:
 move.l (sp)+,a0
 add.l #2,2(sp)
 rte

KernoLine1111Emulator:
 movem.l a0-a1/d0,-(sp)	;saving registers for bra/bsr w/long word displacement emulation
 move.l 14(sp),a0	;get the old pc
 moveq.l #0,d0		;clear all of d0...it may be used in long addition (moveq is faster than clr)
 move.w (a0),d0 	;get the instruction that caused the interrupt
 addq.l #2,a0		;go past the 2 byte 1111Emulator Code; point to the accompanying data/or next instruction
 move.l $c8,a1		;initialize rom call table pointer

;6 byte bsr w/long word displacement  ($FFF0)
 cmpi.w	#$FFF0,d0
 bne.s	\NotFFF0
 move.l	a0,a1		;a1=a0=pc
 adda.l	(a0)+,a1	;a1+displacment=new pc=function address
 move.l	a1,14(sp)	;save new pc (return address for _this_ interrupt)
 bra.s	\Quit1111

\NotFFF0:
;6 byte bra w/long word displacement ($FFF1)
 cmpi.w	#$FFF1,d0
 bne.s	\NotFFF1
 adda.l (a0),a0
 move.l a0,14(sp)
 movem.l (sp)+,a0-a1/d0
 ;ti saves registers, so i do too. What about condition code flags??
 rte

\NotFFF1:
;4 byte ROM CALL 	($FFF2)
 cmpi.w	#$FFF2,d0
 bne.s	\NotFFF2
 move.w (a0),d0

 lsr.w #2,d0		;divide by 4 to get the rom call index
 cmp.l -4(a1),d0	;handle a rom call index greater than the total # avail
 bgt \Bad1111		;rom calls as a crash. Would calling the AMS emulator be better....
 lsl.w #2,d0


 move.l 0(a1,d0.w),14(sp)
 addq.l #2,a0	;set pc to the correct location (old pc + 4)
 bra \Quit1111

\NotFFF2:
;2 byte ROM CALL	($F800 + Rom Call)
 subi.w #$F800,d0
 bmi.s \Bad1111		;branch if less than zero (blt #$F800)

 cmp.l -4(a1),d0	;handle a rom call index greater than the total # avail
 bgt \Bad1111		;rom calls as a crash. Would calling the AMS emulator be better....

 lsl.l #2,d0		;*4
 move.l 0(a1,d0),14(sp)	;save new pc (return address for _this_ interrupt)

\Quit1111
 move usp,a1
 move.l a0,-(a1)	;a0.l = return address to push on user stack
 move a1,usp
 movem.l (sp)+,a0-a1/d0
 rte
;rte calls the rom call, the rom call will return to the program that
;called it thru the return address pushed on the user stack.

\Bad1111:
;note to self, if displaying regs for debug info, they must be restored...
 lea 18(sp),sp	;restore supervisor stack (6 + 12)
 move #$700,sr	;user mode, no interrupts
 pea LineFError(pc)	;the call was too low, so recover the error
 bra Recover

KernoTrap4:
;setup the stack so that the AMS's trap #4 returns back here...
 pea.l \trap4ret(pc)
 move sr,-(sp)
 move.l OldTrap4Error(pc),-(sp)
 rts

\trap4ret
 move.b #$FF,$600003		;reset Bus waitstates (fixes the slowdown after off()/trap #4 that affects some games)
 bsr FastKeyboard		;reset the keyboard speed
 rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoAI6Error:
 move #$2700,sr	;disable interrupts
 movem.l a0-a6/d0-d7,-(sp)

;is something already being handled?
 lea NoErrorThrow(pc),a1
 tst.w (a1)
 bne \SkipCheck
 st (a1)

 move.l #$600018,a2	;keymask port
 move.w (a2),d1		;makes normal power down procedures work better... otherwise, they hang

;is the on key really pressed?
;Kevin Kofler Told me that auto-int 6 can be triggered because of low batteries
;this would also be the reason DoorsOS can mess up and think someone pressed STO+ON
;when they really only pressed STO
 btst.b #$1,$60001A
 bne \DefaultAutoInt6

 bsr CALCULATOR
 beq \TI89

\TI92+:
;Test the ESC Key
 move.w #%1011111111,$600018	;mask the row of the ESC key
 bsr WaitLoop
 btst.b #6,$60001B		;Test the ESC Key
 beq \ESCPressed

 ;Test the Diamond Key
 move.w #%1111111110,$600018	;mask the row of the Diamond key
 bsr WaitLoop
 btst.b #1,$60001B		;Test the Diamond Key
 beq \DiamondPressed
 bra \DefaultAutoInt6		;no need to check TI-89 keys on the TI-92+...

\TI89:
;Test the ESC Key
 move.w #%0111111,(a2)	;mask the row of the ESC key
 bsr WaitLoop
 btst.b #0,$60001B	;Test the ESC Key
 beq \ESCPressed

;Test the DIAMOND Key
 move.w #%1111110,(a2)	;mask the row of the Diamond key
 bsr WaitLoop
 btst.b #6,$60001B	;Test the DIAMOND Key
 beq \DiamondPressed

\DefaultAutoInt6:;call the old auto-int 6 handler
 move.w d1,(a2)	;restore the original key mask... otherwise normal power down procedures hang... ie 2nd+Off, Diamond+Off (this bug took forever to fix!!)
		 ;should i restore the original interrupt mask?
 clr.w (a1)

 movem.l (sp)+,a0-a6/d0-d7
 move.l OldESCOnError(pc),-(sp)
 rts

\ESCPressed:
;it doesn't make sense to restore the registers at this point because we are in a crash sequence
; movem.l (sp)+,a0-a6/d0-d7	;restore saved registers
; addq.l #6,sp			;discard the info for rte (clean up supervisor stack)
 lea 66(sp),sp
 move #$700,sr

\LetGoOfESCPlease: ;force the user to let go of ESC... make sure they see the dialog box...
 bsr WaitLoop	;the col mask has already been set... so skip it...
 tst.b d2	;what calc?
 beq \TI89_LetGoPleaseTest

 btst.b #6,$60001B
 bra \TestLetGoOfEscPlease

\TI89_LetGoPleaseTest:
 btst.b #0,$60001B

\TestLetGoOfEscPlease:
 beq \LetGoOfESCPlease
 ROM_CALLF GKeyFlush

 pea ESCOnError(pc)
 bra Recover

\DiamondPressed:
;clear the flag (NoErrorThrow) first because this function is re-enterant on hw2 calcs with the Clock Running...
 clr.w (a1)
 trap #$4

\SkipCheck:
 movem.l (sp)+,a0-a6/d0-d7
 rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;
WaitLoop:
 move.w #$4A,d0		;loop 25 times (waste time for row reading)
\DoWaitLoop:
 dbra d0,\DoWaitLoop
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;
Recover:
;make sure that KerNO is in control before recovering...
 bclr.b #2,$600001
 
 lea KernoBegin(pc),a3		;pointer to the beginning of KerNO in memory
 lea OffsetTable(pc),a4		;how far from a3 (offset from the beginning of KerNO)
 lea InstallTable(pc),a5	;vector pointers

 moveq.w #(EndInstallTable-InstallTable)-1,d0	;how many loops?
 moveq.l #0,d1
 moveq.l #0,d2		;on longwords, moveq is faster than clr.l

\AssertLoop:
 move.b (a5)+,d2	;get the address of the old vector
 move.w d2,a1
 
 move.w (a4)+,d1	;get the offset from the beginning
 move.l a3,a0		;restore/set a0
 add.l d1,a0		;add the offset to the pointer
 move.l a0,(a1)		;restore the kerno interrupt vector
 dbra d0,\AssertLoop

 move.l #$64,a0		;restore the auto-ints
 lea OldAutoInt1(pc),a1
 moveq.l #((OldAutoInt5-OldAutoInt1)/4)-1,d0
\RestoreIntsLoop:
 move.l (a1)+,(a0)+
 dbra d0,\RestoreIntsLoop

 ifnd NoVTISupport
   bsr CheckVTI	;if vti, then fix this...
   beq \NotVTI
   move.l OldPrivError(pc),$20
\NotVTI:
 endc

 ROM_CALLF PortRestore		;make sure the os has the default lcd_mem...

;Redraw LCD_HEIGHT-7 line
 move.l #30,-(sp)
 move.w #$ff,-(sp)
 bsr CALCULATOR
 bne \Restore92pScreen
 pea.l $56e6
 bra \RestoreTheScreen
\Restore92pScreen:
 pea.l $5a2e
\RestoreTheScreen:
 ROM_CALLF memset

;redraw the default menu
 ROM_CALLF MenuUpdate

;Tell The AMS to redraw all windows
;TODO: check for a corrupt window list?
 move.l $c8,a0
 move.l (a0),a0		;FirstWindow
 move.l (a0),a0		;dereference the pointer
 
\DirtyWindows:
 ori.w #$2000,(a0)	;Set Dirty Flag
 tst.l 34(a0)		;is there another window?
 movea.l 34(a0),a0	;movea doesn't affect ccr
 bne.s \DirtyWindows	;this tests the result from the above tst.l instruction

;Redraw the Status Line Indicators
 move.w #10,(sp)
 ROM_CALLF ST_refDsp
 ROM_CALLF ST_eraseHelp

;Reset the Link interface
 ROM_CALLF OSLinkReset

;see if the Heap is valid
 move.w #0,(sp)
 ROM_CALLF HeapWalk
 tst.w d0
 bne \HeapOk
 pea HeapError(pc)
 bsr DisplayError
 addq.l #4,sp
\HeapOk:

 lea.l 10(sp),sp

 bset.b #2,$600001
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 bsr DisplayError		;inform the user
 lea NoErrorThrow(pc),a0	;get addr of auto-int 6 flag
 clr.w (a0)			;reset the auto-int 6 flag
 ERR_THROW $9

;;;;;;;;;;;;;;;;;;;;;;;;;;;
DisplayError:
 move.l #$00010000,-(sp)	;bt_ok, bt_none
 move.l 8(sp),-(sp)		;get the passed argument...
 pea RecoveredStr(pc)
 move.l $C8,a4
 ROM_CALL3 DlgMessage
 lea 12(sp),sp
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;d2==0 if TI-89
CALCULATOR:
 movem.l d0-d1/a0-a1,-(sp)
 ROM_CALL FL_getHardwareParmBloc
 move.l 2(a0),d2
 subq.l #3,d2
  cmp.l #6,d2	;the TI-89 Titanium reports 9 (since -3 already, then 6)
  bne \Not89T
  moveq #0,d2
\Not89T
 
 movem.l (sp)+,d0-d1/a0-a1
 tst.b d2	;this allows immediate testing/jumping based on result
 rts

 ifnd NoVTISupport
CheckVTI:
 ;d0, d1 destroyed!
 ;bit #14 in d0 is key
   trap #12	;supervisor mode
   move.w d0,d1
   move.w #$6000,sr
   move sr,d0
   move.w d1,sr
   btst.w #14,d0	;this allows immediate testing/jumping based on result
   rts
 endc

FastKeyboard:
 movem.l a0-a1/a4/d0-d2,-(sp)
 move.l $c8,a4
 move.w #20,-(sp)
 ROM_CALL3 OSInitBetweenKeyDelay	;default value: 48
 move.w #75,(sp)
 ROM_CALL3 OSInitKeyInitDelay 		;default value: 336
 addq.l #2,sp
 movem.l (sp)+,a0-a1/a4/d0-d2
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;
UninstallTable:
OldExecFunc	  dc.l 0
OldUninstFunc	  dc.l 0
OldAddressError:  dc.l 0
OldIllegalError:  dc.l 0
OldDivError:	  dc.l 0
OldCHKError:	  dc.l 0
OldTRAPVError:	  dc.l 0
OldPrivError:	  dc.l 0
OldLineAEmulator: dc.l 0
OldLineFEmulator: dc.l 0
OldESCOnError:	  dc.l 0
;OldProtectError:  dc.l 0
OldTrap4Error:	  dc.l 0
	ifd EXPERIMENTAL
OldTrapB:	  dc.l 0
	endc

OldAutoInt1:	  dc.l 0
OldAutoInt2:	  dc.l 0
OldAutoInt3:	  dc.l 0
OldAutoInt4:	  dc.l 0
OldAutoInt5:	  dc.l 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;
OffsetTable:
 dc.w KernoExec-KernoBegin	;should == 0
 dc.w KernoUninstall-KernoBegin
 dc.w KernoAddressError-KernoBegin
 dc.w KernoIllegalError-KernoBegin
 dc.w KernoDivError-KernoBegin
 dc.w KernoCHKError-KernoBegin
 dc.w KernoTRAPVError-KernoBegin
 dc.w KernoPrivError-KernoBegin
 dc.w KernoLine1010Emulator-KernoBegin
 dc.w KernoLine1111Emulator-KernoBegin
 dc.w KernoAI6Error-KernoBegin
; dc.w KernoProtectedError-KernoBegin
 dc.w KernoTrap4-KernoBegin
;;;;;;;;;;;;;;;;;;;;;;;;;;;
NoErrorThrow:	dc.w 0			;avoids problems with multiple interrupts... ie key bounce
;;;;;;;;;;;;;;;;;;;;;;;;;;;
InstallTable:
 dc.b $34	;Exec function
 dc.b $38	;uninstall routine
 dc.b $C	;address
 dc.b $10	;illegal
 dc.b $14	;divide/0
 dc.b $18	;CHK
 dc.b $1C	;TrapV
 dc.b $20	;Priv
 dc.b $28	;Line 1010
 dc.b $2C	;line 1111
 dc.b $78	;auto-int 6 (ON key)
; dc.b $80	;auto-int 7 (protected memory)
 dc.b $90	;trap 4 (off)
EndInstallTable:;used to get the number of entries for loops
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Internal Strings...

AddressError:	dc.b 'Address Error',0
IllegalError:	dc.b 'Illegal Instruction',0
DivError:	dc.b 'Divide By Zero',0
CHKError:	dc.b 'CHK Instruction',0
TRAPVError:	dc.b 'TRAPV Instruction',0
PrivError:	dc.b 'Privilege Violation',0
LineFError:	dc.b 'Line 1111 Emulator',0
ESCOnError:	dc.b 'ESC+ON',0
HeapError:	dc.b 'Heap Corrupt',0
;ProtectedError:	dc.b 'Protected memory violation',0
;;;;;;;;;;;;;;;;;;;;;;;;;;;
_comment:
RecoveredStr:	dc.b 'KerNO v',48+VERSION_MAJOR,'.',48+VERSION_MINOR,0	;48 is ASCII '0'
KernoDeInStr:	dc.b 'KerNO Uninstalled',0
KernoDoorsStr:	dc.b "This program needs a kernel",0
;;;;;;;;;;;;;;;;;;;;;;;;;;;
KernoEnd:
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Data for the install portion of this program
InstallStr:		dc.b 'KerNO Installed',0
LowRamStr: 		dc.b 'Low Memory',0
PreviousKernelStr:	dc.b 'Remove Kernel',0
 ifnd h220
NeedPatchStr:		dc.b 'HW3 Patch Required',0
 endc
NeedAMS2.xxStr:		dc.b 'AMS Upgrade Required',0
;;;;;;;;;;;;;;;;;;;;;;;;;;;
