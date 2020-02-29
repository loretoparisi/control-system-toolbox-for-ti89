![cstlogo2](https://cloud.githubusercontent.com/assets/163333/14590189/117e4706-04f5-11e6-8a2a-fd708c1e0849.jpg)

# Control System Toolbox for TI-89
*GnuGPL 2002-2005 Loreto Parisi*

# About CST for TI-89
Control System Toolbox (CST) for TI-89 is a suite of functions and programs for Systems Control and Tuning for the TI-89 personal calculator, developed by Loreto Parisi starting from June 2002.

CST supports Linear Time-Invariant (LTI) Systems in Continuous(t)and Discrete (k) Time Domains simultaneuosly, Delayed Systems (affected by a Time Delay) and Non-Linear Systems (to be linearized).

CST defines systems by Transfer Function or State Space and converts Continuous Time to Discrete Time Systems using known discretizations methods.

CST performs Time Domain and Frequency Analisys, supported by Laplace and Zeta transformations, Bode and Step Response Diagrams.

CST verifies Open-Loop and Closed-Loop Stability by Eigenvalues (and Eigenvectors) calculations, Routh Matrix and Conditions, Gain and Phase Margins evalutations, Root Locus and Nyquist Diagrams plottings.

CST supports Feedback Control Systems Design, Analisys and Tuning, providing P, PI, PD, PID and Lead and Lag Networks Design (even using Nichols maps), Ziegler-Nichols closed-loop Tuning, Optimal Control with ISE, ISTE and IST^2E, Adaptive Filtering, Closed-Loop Gain and Phase Margins evalutations, Time Domain analisys against custom inputs and noises.

CST operates Direct Laplace and Zeta Transformations and Inverse Laplace and Zeta Transformations.

CST loads and saves working sessions at any time, safing you to loose data quitting CST. It saves separately significant data (such as Transfer Function and Step Response) and plots (such as Bode and Nyquist Diagrams).

CST has a robust Error Management System to prevent unsafe aborts and a usefull On-line Help.

What Else?

LP, October 2005. ( @loretoparisi )

# Introducing CST r1.3
Control System Toolbox release 1.3 come with many powerful features. For newbee to CST please see About first. Let see Release 1.3 new features in details.

Nyquist Diagrams;

Root Locus;

Laplace and Zeta Direct and Inverse Transformations;

Simultaneous Continuous and Discrete Time Domain Analisys;

Improvede Continuous to Discrete Time Discretization using Forward and Backward Eulero, Zero-Order Hold and Tustin Method;

Gain and Phase Margins evalutations;

Time Delay and Padé Approximation;

Improved Step Response Diagrams;

Routh Matrix and Parametric Routh Conditions;

Improved Time Constants Evalutation Algorithms;

Feedback Control Systems Design, Analisys and Tuning, providing P, PI, PD, PID and Lead and Lag Networks Design (even using Nichols maps), Ziegler-Nichols Closed-Loop Tuning, Optimal Control with ISE, ISTE and IST^2E, Adaptive Filtering, Closed-Loop Gain and Phase Margins evalutations, Time Domain Analisys against custom inputs and noises.

Working sessions management, safing you to loose data quitting CST. CST saves the current working session and can save separately significant data (such as Transfer Function and Step Response) and plots (such as Bode and Nyquist Diagrams).

Robust Error Management System to prevent unsafe aborts and a useful On-line Help Tool.

## Documentation :new:

- The CST Start Guide, *First Edition October 2005*
[Download :point_left:](https://github.com/loretoparisi/control-system-toolbox-for-ti89/blob/master/docs/CSTStartGuide.pdf)
- The CST Reference Guide, *First Edition October 2005*
[Download :point_left:](https://github.com/loretoparisi/control-system-toolbox-for-ti89/blob/master/docs/CSTReferenceGuide.pdf)
- The CST User Guide, *Fifth Edition October 2005*
[Download :point_left:](https://github.com/loretoparisi/control-system-toolbox-for-ti89/blob/master/docs/CSTUserGuide.pdf)


## FAQ :new:
- Which Texas Instruments calculators are supported?
The currently supported TI calculators are **TI-89**, **TI-89 Titanium** and **TI-92/Plus/Voyage 200**.
- How to fix the **DOMAIN-ERROR** on TI-89 Titanium?
This is a known issue that happens on the TI-89 Titanium series calculators. To solve it please do

```
Mode -> page 2 -> Exact/Approx change from "Exact" -> "Auto"
```

## Tools
Here you are a complete list of Control System Toolbox r1.3 embedded and external tools.


### LZT r7
From release 1.3, CST needs the tool LZT to perform symbolic calculations (i.e. 
Laplace and Zeta transforms). To install LZT please follow instructions we provide in section Install LZT of CST Start Guide. We also raccomend to read the LZT Readme file.

- Author: Jiri Bazant 
- Email: georger@razdva.cz 
- Home: http://www.razdva.cz/georger/
- Licence: Freeware 

### KerNO r3.1
This powerful tool needs any kernel like DoorsOS, UniOS or KerNO. We provide 
KenNO r3.1 from CST r1.3 as its convenient installation. To install KerNO please follow instructions we provide in section Install KerNO of CST Start Guide. We also 
raccomend to read the KerNo readme file. 

- Author: Greg Dietsche 
- E-Mail: calc@gregd.org 
- Home: http://calc.gregd.org/
- Licence: Freeware

### BodeX v2.2.4
The best program for TI calculators that trace frequency plot of a transfer function W(s) of a SISO or MIMO 
system (Bode plots) with or withoout time delay. BodeX use a powered routine to plot the phase plot of a 
transfer function (don't use simply the angle(•) function). The BodeX routines ensure the correct phase plot 
any W(s) it's plotted.

- Author: 92BROTHERS
- Email: 92brothers@infinito.it
- Home: http://www.92brothers.net/
- Licence: Gnu GPL

### NYQUIST, RLOCUS (CT v1.16)
Plots the Nyquist Diagram and the Root Locus.

- Author: Francesco Orabona
- Email: bremen79@infinito.it
- Home: www.infinito.it/utenti/bremen79/
- Licence: Gnu GPL

## Acknowledgments
Many thanks to all those programmers and users which directly or indirectly gave a hand in making CST for TI-89. 

- 92BROTHERS
- Contribute: bodex()
- E-mail: 92brothers@infinito.it
- Home: http://www.92brothers.net

Francesco Orabona
- Contribute: logspace(), poly2cof(),
- zpk(),nyquist(), rlocus()
- E-mail: bremen79@infinito.it
- Home: http://web.genie.it/utenti/b/bremen79

Lars Frederiksen
- Contribute: DiffEq()
- E-mail: ltf@post8.tele.dk

Greg Dietsche
- Contribute: kerno()
- E-Mail: calc@gregd.org
- Home: http://calc.gregd.org

Kevin Kofler
- Contribute: hw3patch()
- Home: http://tigcc.ticalc.org

Jiri Bazant
- Contribute: lzt()
- E-mail: georger@razdva.cz
- Home: http://www.razdva.cz/georger/


## ticalc.org
CST for TI-89 is featured on ticalc.org [here](https://www.ticalc.org/archives/files/fileinfo/379/37951.html) where it is currently ranked
```
Ranked as 159 on our all-time top downloads list with 47121 downloads.
Ranked as 441 on our top downloads list for the past seven days with 13 downloads.
Ranked as 167 on our top rated list with a weighted average of 8.44.
```
