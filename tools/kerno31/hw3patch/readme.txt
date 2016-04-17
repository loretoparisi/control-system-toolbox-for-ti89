HW3Patch 1.02 by Kevin Kofler
=============================

COPYRIGHT AND LICENSE:
----------------------

Copyright (C) 2004-2005 Kevin Kofler. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
the HW3Patch executable and associated documentation files (the "HW3Patch"), to
deal in the HW3Patch, including without limitation the rights to use, copy,
merge, publish, distribute, sublicense, and/or sell copies of the HW3Patch, and
to permit persons to whom the HW3Patch is furnished to do so, subject to the
following conditions:
(1) The HW3Patch package (hw3patch.zip) shall only be distributed UNMODIFIED and
    in its entirety, including, but not limited to, the above copyright notice,
    this permission notice and the following disclaimer. Any derivative works
    are NOT allowed without my explicit permission. This License becomes null
    and void when the HW3Patch or HW3Patch package has been modified.
(2) The origin of this software must not be misrepresented; you must not claim
    that you wrote the HW3Patch or misrepresent it as a part of a program you
    bundle it with.
(3) The HW3Patch may be sold as part of a larger software package but no copy of
    the HW3Patch may be sold by itself.
(4) This License Agreement will automatically terminate upon a material breach
    of its terms and conditions.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHOR BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING FROM, OUT OF OR
IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


QUESTIONS AND ANSWERS:
----------------------

Q: What is the HW3Patch?
A: It is a program which modifies TI's Advanced Mathematics Software operating
   system in a way which allows memory-resident programs (TSRs), dynamically-
   linked libraries (DLLs), nested function trampolines and similar constructs
   to run.

Q: What hardware and software versions does HW3Patch run on?
A: Hardware:
   * Hardware version 2 (TI-89 HW2, TI-92+ HW2, Voyage 200)
   * Hardware version 3 (TI-89 Titanium)
   Software: Any AMS version between (and including) 2.00 and 3.10.

Q: How do I run the HW3Patch?
A: Send hw3patch.89z to your calculator, type hw3patch() and press [ENTER].

Q: How does it work?
A: It disables the RAM execution protection and modifies the AMS to make this
   permanent.

Q: OK, but how EXACTLY does it work?
A: In technical terms, it:
   1. disables the FlashROM and I/O port protection (do NOT ask me how to do
      that!)
   2. zeros out the ports at 0x700000-0x700007
   3. zeros out the initializers for 0x700000-0x700007 in the function 15 of the
      trap 11
   4. zeros out a check in the function 15 of the trap 11 which makes it fail
      when called from the trap 4 and thus causes a crash when changing the
      batteries with a TSR installed

Q: Will you release the source code of HW3Patch?
A: No, sorry. I MIGHT send it to trusted people who give me really good reasons
   why this might be a good idea, but generally the answer will be "no". The
   reason for this is that the methods for disabling the FlashROM and I/O port
   protection are a closely-guarded secret, because that protection is the only
   one stopping you from writing a program which makes the calculator
   PERMANENTLY UNBOOTABLE.

Q: After running the HW3Patch, can I still send my copy of AMS to another
   calculator?
A: NO, UNLESS you are using the TIB Receiver on the receiving calculator. You
   CAN however RECEIVE an AMS update, and doing so will uninstall the HW3Patch
   and allow you to send your copy of AMS again (until you run HW3Patch again).

Q: How can I uninstall the HW3Patch?
A: You need to send a fresh copy of the AMS operating system. This will
   overwrite the patched AMS with a clean version.

Q: Can I switch from h220xTSR to HW3Patch on my HW2 calculator?
A: Yes, the HW3Patch can "upgrade" h220xTSR installations. The only caveat is
   that, in order to be able to uninstall h220xTSR's trap 4 hook, there must not
   be any keyboard accelerators, password programs or similar trap 4 TSRs (i.e.
   memory-resident programs which are executed whenever the calculator is turned
   on or off) installed. Otherwise, you will get an "ERROR: Unknown trap 4
   hook", which means you need to temporary uninstall the aforementioned types
   of TSRs.

Q: Can I switch from HW2Patch to HW3Patch on my HW2 calculator?
A: Yes, the HW3Patch can upgrade both RAM-resident and FlashROM-resident
   installations of the HW2Patch. The result will always be a FlashROM-resident
   HW3Patch installation. The advantage of doing this is that you will no longer
   get crashes when you change your batteries.

Q: Is the HW3Patch dangerous?
A: There is always a risk involved with disabling the FlashROM and I/O port
   protection, but I really do NOT think the HW3Patch is going to harm your
   calculator in any way. However, please keep in mind that this is NOT a
   legally binding promise, and that I can IN NO EVENT be held legally
   responsible for any type of damage (see the license terms).

Q: Where can I contact the author?
A: Web page: http://www.tigen.org/kevin.kofler/ti89prog/
   E-mail: kevin.kofler@chello.at or Kevin@tigcc.ticalc.org


CREDITS:
--------

Thanks to:
* My teammates in the TIGCC Team (http://tigcc.ticalc.org) for TIGCC. Especially:
  - Zeljko Juric for documenting many important operating system functions as
    a part of TIGCCLIB, and for explaining the Flash unprotection method to me
  - Sebastian Reichelt for the TIGCC IDE (integrated developer environment) and
    linker, which were used for this program, and his many other contributions
    to TIGCC
* ExtendeD for discovering the Flash unprotection method and for giving me a few
  tips for the HW3Patch development
* Rusty Wagner and Corey Taylor for the Virtual TI emulator
* The GNU project and its contributors for the GNU assembler
* Julien Muchembled for his work on the HW2 execution protection
* My beta-testers for their testing efforts, in particular:
  - Lionel Debroux for reporting a bug in the private beta 0.90 which left the
    calculator in a potentially unstable state


HISTORY:
--------

0.91 Beta  2004-06-21
* First public release.

1.00       2004-08-01
* First non-beta release. No changes.

1.01       2005-02-14
* Added support for AMS 3.01 (relaxed version check only).

1.02       2005-08-21
* Added support for AMS 3.10 (relaxed version check only).
