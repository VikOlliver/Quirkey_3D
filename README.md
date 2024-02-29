# Quirkey_3D
OpenSCAD models for the parts of a Quirkey chord keyboard.

## Overview
These files build a 3D model of a one-handed keyboard with 6 keys (1 per digit, a 2-way for the thumb) using microswitches (V3) or MX type keyswitches (V4). Code and user documentation is available in neighbouring repositories for AT32U4-based Arduinos and Raspberry Pi Pico compatibles.

## Concept And Rationale
On a Quirkey, fingers never move from their assigned keys, and press simultaneous "chords' to create characters. This makes this a usefull accessibility keyboard for people with one hand, restricted or absent arm movement, tremor (the arm can be sandbagged in place), eyesight issues, RSI, or having a posture that renders using a conventional keyboard impractical (such as having to remain laid flat). They are also very handy for typing on for the rest of us, as you become an instant touch-typist and can focus on things other than the keyboard.

## Revision Notes
V3 and V4 feature captive keys that do not require glueing on like the earlier versions. The base now has pillars that hold the switches and keycaps, with slots added so that the entire wiring harness can be installed and removed without having to solder or unsolder any wires. The shell is now hollow, with manually-added support panels so that the whole thing prints without any support material (at least on a Prusa Mk3). The thumb and control key have been combined into one component on the V3.

## Build Process

OpenSCAD Preferences/Advanced may need to be changed to allow 20,000 elements as these models get quite complicated.

The quirkey.inc file contains a scaling factor "junior_scale" to suit the user's hand size. Going much smaller than 0.85 (a "junior" size) may cause ... issues. As it is, the V4 version using MX keyswitches does not have enough room for the switch, so for little people please use the V3 files and quality microswitches.

A factor of 0.92 is about right for the average Anglo, and 1.0 suits me personally 'cos I have big hands. Changing the scaling factor does not alter the size of the key caps.

Having set this, build the core.scad file and save as core.stl in the same directory. This is necessary because OpenSCAD crashes for unknown reasons if the core shape is built with the main file. It is necessary to rebuild the core file every time you change the scaling factor, overall dimensions of the Quirkey, or several other things in quirkey.inc that I don't want to list right now.

In the quirkeyv3.scad file are a series of microswitch_* variables. Use these to configure the dimensions of the smallest lever microswitch you can get. The lever should not protrude significantly forward of the microswitch case (truncate brutally if necessary).

There is a left_hand variable which can be changed from 1 to -1 to mirror the shell for left hand use. There are other implications for this, see notes.

At the bottom of the quirkeyv*.scad file are a number of modules that may be printed. I'd suggest building keycap() and test_pillar() first to make sure your switch dimensions are correct. Then repeat with double_key() and doubleswitch_pillar().

Once these function, build base() and hollow_top_shell(). Four keycap() are also needed; note that software documentation suggests a colour scheme that is used by the user documentation and typing tutor.
V3 needs EITHER a double_key() is you are following your own colour scheme, OR a thumbkey() and commandkey(). The latter should press-fit, but in practice a drop of superglue is advisable. The thumbkey() is best printed without a brim due to the shallow groove under it. V4 uses two separate thumbkeys.

Assembly documents are in there with the rest of the files.

Pre-built STL files for left- and right-handed versions can be found at https://www.printables.com/model/667870-quirkey-v3-accessibility-keyboard-for-one-handed-u

## Acknowledgements
This work is based largely on the efforts of Cy Endfield and his partner Chris Rainey's Microwriter Ltd. in the UK during the 80's. Their concept was brilliant, and many people still use their Microwriter and Quinkey devices. Time has passed, patents have lapsed, and the electronics have become more affordable, thanks to the likes of Arduino and the Raspberry Pi Foundation. Credit is also due to my colleages Dr. Adrian Bowyer, Dr. Ed Sells et al for creating the RepRap and thus making 3D printing itself affordable and accessible for so many people.

Share and enjoy.

Vik Olliver
vik@diamondage.co.nz

## Note For Left Hand Use
While mirroring the shell and mentally reversing the key combinations will mostly work, the writing and Pi Pico anchor points will be inverted and some characters flow naturally in one direction or another. So there is a left_hand flag in the quirkeyv3.scad file to flip it into leftie mode properly, and proper left hand documentation.

