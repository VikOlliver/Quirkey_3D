// quirkeyv3.scad - Quirkey version with captive keycaps and simplified wiring.
// Todo:

include <quirkey.inc>
// Logo takes a while to compile. If developing set this to disable it, otherwise use 1.
uselogo=1;

// Length of the microswitch body
microswitch_len=13.2 ;
// Height of the microswitch body
microswitch_ht=6.75;
// Width of the microswitch body
microswitch_wid=5.8;
// Clearance for the hole to give a tight fit.
microswitch_clearance=0.25;
lever_width=4;

// NOT Microswitch stuff. This is the keycap dimensions.
keycapWidth=14;
keycapHeight=10;
keycapInset=4;
keycapToeWidth=8;
keycapToeHeight=3;  // "toe" that digs into the back of the pillar to limit key movement
keycapToeLen=7;
pivotRad=2;
doublekeyWidth=26;
doublekeyLength=keycapWidth;
doublekeyHeight=7+shellThickness;
doubleswitchSpacing=doublekeyWidth-2*microswitch_wid;
doubleswitchPivotShift=1;

// Dimensions of a key pillar supports with key cavity therein
pillarWall=1.5;
pillarWid=keycapWidth+2*pillarWall;
pillarLen=microswitch_len+2*pillarWall;
doublepillarLen=microswitch_len+4*pillarWall;
doublepillarWid=doublekeyWidth+4*pillarWall;

// Cable hole location.
cableHoleShift=overall_length*0.2;

// Raspberry Pi hole and useful dimensions
// Fitting a Pi board into a junior-sized shell is actually quite a Tetris job.
boardLen=51;
boardWid=21;
boardHoleX=51-2-2.4;
boardHoleY=11.4;
boardHoleRad=2.0/2; // Includes interference fit.
boardComponentHt=5; // Board mounted upside down, so clearance needed.
boardPillarHt=8;        // Distance from base to top of support pillar
boardResetHoleY=6.9;
boardResetHoleX=12.25;
boardPlacement=[boardLen/2+shellThickness+10,first_finger_loc[1]-3-boardLen/2,base_ht];

// Screw hole variables
screwRad=1.9;
screw_from_back_edge=shellThickness+screwRad;
screw_from_rear_side=shellThickness+screwRad;
screw_from_front_side=shellThickness+screwRad+3*junior_scale;
screw_from_front_edge=34*junior_scale;
screw_hole_list=[
    [screw_from_rear_side,screw_from_back_edge,0],
    [overall_width-screw_from_rear_side,screw_from_back_edge,0],
    [screw_from_front_side,overall_length-screw_from_front_edge,0],
    [overall_width-screw_from_front_side,overall_length-screw_from_front_edge,0]
];

// Locating pins
// A Pin hole has a slightly wider chamber at each end
pinhole_min=5.8/2;
pinhole_max=7/2;
pinhole_end_len=3;
pinhole_len=doublekeyHeight-4;
pinhole_clearance=0.18; // Gap to leave for clearance, insertion, printing deformations etc.
pin_split_wid=(pinhole_max-pinhole_min)*2+pinhole_clearance;

// A pin has a barb on each end that fits within the oversize end of each pin hole.
// They are printed flat for convenience.
module pin_body() {
    // Main body
    cylinder(r=pinhole_min-pinhole_clearance,h=pinhole_len-2*pinhole_clearance,center=true,$fn=18);
    // End cones
    translate([0,0,-(pinhole_len-pinhole_end_len)/2]) cylinder(h=pinhole_end_len-pinhole_clearance*2,r1=pinhole_min-pinhole_clearance,r2=pinhole_max-pinhole_clearance,center=true,$fn=18);
    translate([0,0,(pinhole_len-pinhole_end_len)/2]) cylinder(h=pinhole_end_len-pinhole_clearance*2,r2=pinhole_min-pinhole_clearance,r1=pinhole_max-pinhole_clearance,center=true,$fn=18);
}

// Chop splits in pin and flatten sides.
module pin() {
    translate([-pinhole_min/2,0,0]) intersection() {
        difference() {
            pin_body();
            translate([0,0,pinhole_len/2]) cube([pinhole_max*4,pin_split_wid,pinhole_len*0.75],center=true);
            translate([0,0,-pinhole_len/2]) cube([pinhole_max*4,pin_split_wid,pinhole_len*0.75],center=true);
        }
        cube([pinhole_min,pinhole_max*2,pinhole_len],center=true);
    }
}

module pin_hole() {
    cylinder(h=pinhole_len,r=pinhole_min,center=true,$fn=18);
    translate([0,0,(pinhole_len-pinhole_end_len)/2]) cylinder(h=pinhole_end_len,r=pinhole_max,center=true,$fn=18);
    translate([0,0,-(pinhole_len-pinhole_end_len)/2]) cylinder(h=pinhole_end_len,r=pinhole_max,center=true,$fn=18);
}

// Screw holes
module screw_holes() {
    for (i=[0:len(screw_hole_list)-1]) {
        translate(screw_hole_list[i]) translate([0,0,-0.1]) {
            cylinder(h=15,r1=screwRad,r2=screwRad-0.3);
            cylinder(h=2,r1=4,r2=1.5);
        }
    }
}

// Screw pillars
screwPillarRad=screwRad+2.5;
module screw_pillars() {
    for (i=[0:len(screw_hole_list)-1]) {
        translate(screw_hole_list[i]) {
            cylinder(h=14*junior_scale,r1=screwPillarRad+2,r2=screwPillarRad);
            translate([0,0,14*junior_scale]) sphere(screwPillarRad);
        }
    }
}

// Pillar for mounting a Pi on
module boardPillar() union() {
    // Slightly tapered post
    cylinder(h=boardPillarHt,r1=boardHoleRad+0.6,r2=boardHoleRad);
    translate([0,0,boardComponentHt/2])
        cube([boardHoleRad+4,boardHoleRad+1.4,boardComponentHt],center=true);

}

// Cluster of pillars for mounting board on.
module boardPillars() union() {
    translate([boardHoleX/2,boardHoleY/2,0]) boardPillar();
    translate([boardHoleX/2,-boardHoleY/2,0]) boardPillar();
    translate([-boardHoleX/2,boardHoleY/2,0]) boardPillar();
    translate([-boardHoleX/2,-boardHoleY/2,0]) boardPillar();
}

// The very basic solid form. Compiled separately because compiling it inline causes
// OpenSCAD to crash and core dump for unknown reasons.
module core_form() {
    import("core.stl");
}

// Finger groove. Lays flat, round end facing away, hole for keycap
module finger() {
    translate([0,0,finger_groove_rad]) {
        rotate([90,0,0]) cylinder(h=100,r=finger_groove_rad,$fn=50);
        sphere(finger_groove_rad,$fn=50);
    }
}

// Hole for keycap to poke through
module keycapHole() {
    translate([0,0.6,0]) cube([keycapWidth+1.6,keycapWidth+2.5,100],center=true);
}

// Fingertip model with a keycap hole attached
module fingerPlusHole() {
    finger();
    // The switch cover hole
    keycapHole() ;
}

// Key cap for finger keys.
module keycap() union() {
    difference() {
        // Keycap body
        union() {
            // Basic cube shape of keycap with pivoting corner knocked off.
            translate([0,0,keycapHeight/2]) difference() {
                cube([keycapWidth,keycapWidth,keycapHeight],center=true);
                translate([-keycapWidth/2,0,-keycapHeight/2])
                    cube([pivotRad*2,keycapWidth*2,pivotRad*2],center=true);
            }
            // Pivot at rear
            translate([pivotRad-keycapWidth/2,0,pivotRad])
                rotate([90,0,0]) cylinder(h=keycapWidth+pillarWall*2,r=pivotRad,center=true,$fn=25);
        }
        // Big slot at rear to guide switch lever
        translate([-keycapWidth/2,0,0]) cube([keycapWidth,lever_width,6],center=true);
        // Shallow ledge front to contact and guide lever
        translate([0,0,-1]) cube([keycapWidth*2,lever_width,3],center=true);
        translate([keycapWidth*.2,0,finger_groove_rad*2+keycapHeight-1]) rotate([180,0,90]) finger();
        // Slope the front edge to reduce chance of binding
        translate([keycapWidth/2,0,keycapHeight]) rotate([0,3,0]) translate([5,0,0]) cube([10,keycapWidth*2,keycapHeight*4],center=true);
   }
   // The "toe". This stops the back of the keycap flipping up out of the case.
   translate([-keycapWidth/2+1,0,keycapToeHeight/2]) 
   cube([keycapToeLen,keycapToeWidth,keycapToeHeight],center=true);
}

// A double keycap for the thumb buttons, working like a teeter-totter.
// Slot sizes are uneven because thumb pressure and angle change with position.
module double_key() {
    difference() {
        union() {
            // Body of key
            translate([0,0,doublekeyHeight/2])
                cube([doublekeyWidth,doublekeyLength, doublekeyHeight],center=true);
            // captive pivots
            translate([doubleswitchPivotShift,0,pivotRad]) rotate([90,0,0]) cylinder(h=pillarWall*4+doublekeyLength,r=pivotRad,center=true,$fn=25);
        }
        // Finger slots
        translate([doublekeyWidth*.24,0,finger_groove_rad*2+doublekeyHeight-1]) rotate([180,0,180]) finger();
        translate([-doublekeyWidth*.24,0,finger_groove_rad*2+doublekeyHeight-1]) rotate([180,0,180]) finger();
        translate([0,2,finger_groove_rad*2+doublekeyHeight-1]) scale([0.2,1,1]) rotate([180,0,180]) finger();
        // Switch arm slots
        // Command key first
        // The thumb key slots
       translate([-doubleswitchSpacing/2,-doublekeyWidth/2+0.01,-1.3]) cube([lever_width,doublekeyWidth,3],center=true);
        translate([-doubleswitchSpacing/2,doublekeyWidth/2,-1.5]) cube([lever_width,doublekeyWidth,6],center=true);
        // The command key slots
        translate([doubleswitchSpacing/2,-doublekeyWidth/2+0.01,-1]) cube([lever_width,doublekeyWidth,3],center=true);
       translate([doubleswitchSpacing/2,doublekeyWidth/2,-1]) cube([lever_width,doublekeyWidth,6],center=true);
        // Slope the sides
        translate([-doublekeyWidth/2,0,0])  rotate([0,2,0]) translate([-5,0,0]) cube([10,doublekeyLength*2,doublekeyHeight*4],center=true);
        translate([doublekeyWidth/2,0,0])  rotate([0,-2,0]) translate([5,0,0]) cube([10,doublekeyLength*2,doublekeyHeight*4],center=true);
    }
 }

// Hole that a double keycap fits through.
 module doublekeyHole() {
        cube([doublekeyWidth+2.3,doublekeyLength+2.3,100],center=true);
 }

// Double key with the command hey cut out and pin hole in it.
 module thumbkey() {
     difference() {
        double_key();
         // Lop off the command key
         translate([doublekeyLength/2,0, doublekeyHeight]) cube([doublekeyLength,doublekeyWidth*2,doublekeyHeight],center=true);
     }
     // Poke a pin in it
     translate([doublekeyLength/2,0, doublekeyHeight/2]) pin();
}

// Command key half of thumb key with a pinhole in its arse.
module commandkey() translate([0,0,-doublekeyHeight/2]) {
     difference() {
         intersection() {
            double_key();
             // Lop off the command key, tiny displacement for interference fit.
             translate([doublekeyLength/2+0.1,0, doublekeyHeight]) cube([doublekeyLength,doublekeyWidth*2,doublekeyHeight],center=true);
         }
         // Poke a pin hole in it.
         translate([doublekeyLength/2,0, doublekeyHeight/2]) pin_hole();
     }
 }

relief_len=overall_length*0.1;  // Overall length of strain relief module
relief_curve_rad=8;                   // Radius of relief curve
relief_eccent=1.5;                         // Eccentricity of releif curve
relief_curve_ht=usb_cable_rad*2.3;    // Height of the relieved curve hole
module strain_relief_hole() {
    // Central slot for cable
   translate([0,0,usb_cable_rad]) rotate([-90,0,0]) cylinder(h=relief_len,r=usb_cable_rad,$fn=12);
   translate([0,relief_len/2,usb_cable_rad/2]) cube([usb_cable_rad*2,relief_len,usb_cable_rad],center=true);
    // Curved side, forward half
    translate([0,0,-0.01]) difference() {
        cube([relief_curve_rad,relief_curve_rad*relief_eccent,relief_curve_ht]);
        translate([relief_curve_rad+usb_cable_rad,relief_curve_rad*relief_eccent,0]) scale([1,relief_eccent,1]) cylinder(h=relief_curve_ht*4,r=relief_curve_rad,center=true,$fn=80);
    }
    // Curved side, rear half (didle factor of 0.01 to fix booleans in OpenSCAD)
    translate([0.01-relief_curve_rad,0,-0.01]) difference() {
        cube([relief_curve_rad,relief_curve_rad*relief_eccent,relief_curve_ht]);
        translate([-usb_cable_rad,relief_curve_rad*relief_eccent,0]) scale([1,relief_eccent,1]) cylinder(h=relief_curve_ht*4,r=relief_curve_rad,center=true,$fn=80);
    }
}

// The body core with finger grooves and thumb divots knocked out of it.
module body_construction() {
    difference() {
        core_form();
        translate([0,-0.6,-2]) union() {
            // First finger
            translate(first_finger_loc)
                rotate(first_finger_rot) fingerPlusHole();
            // 2nd finger
            translate(second_finger_loc)
                rotate(second_finger_rot) fingerPlusHole();
            // Ring finger
            translate(ring_finger_loc)
                rotate(ring_finger_rot) fingerPlusHole();
            // Pinkie finger
            translate(pinkie_finger_loc)
                rotate(pinkie_finger_rot) fingerPlusHole();
            // Fiddling to line tilted thumb switch up with hole that I do not understand the need for.
            translate([-1.5,-0.4,0]) translate(thumb_loc)
                rotate(thumb_rot) rotate(thumb_twist) doublekeyHole();
        }
        // Divot for thumb between switches
        translate([-4-shellThickness/2,-2,shellThickness/2]) translate(thumb_loc)
            rotate([3-wrist_tilt,thumb_slope+10,0])  rotate(thumb_twist) scale([2,1.8,0.45]) sphere(keycapWidth*0.95,$fn=60);
    }
}

// Scaled down core form, used for hollowing out.
module reduced_core_form(reduce) {
    translate([reduce,reduce,-0.01])
        scale([(overall_width-2*reduce)/overall_width,(overall_length-2*reduce)/overall_length,(overall_height-reduce)/overall_height])
        core_form();
}

// Hollow top shell minus the base.
module hollow_top_shell() translate([0,0,-base_ht])  difference() {
    union() {
        difference() {
            body_construction();
            reduced_core_form(shellThickness);
            // Chop the base off
            translate([0,0,base_ht-overall_length]) cube(overall_length*2,center=true);
            // Fancy schmanzy logo
            if (uselogo==1)
                translate([overall_width/2,overall_length/2,overall_height*0.815-0.75]) rotate([-wrist_tilt,0,0]) scale(4) linear_extrude(height=10) import("quirkey_logo.svg");
        }
        translate([0,0,base_ht]) screw_pillars();
        // Some slices for bridging support
        intersection() {
            // Slightly drop the core form so that these supports barely skim the underside.
            translate([0,0,-0.2]) reduced_core_form(shellThickness);
            union() {
                translate([(first_finger_loc[0]+second_finger_loc[0])/2,overall_length*0.4,base_ht+overall_height])
                    cube([1.2,overall_length*0.63,overall_height*2],center=true);
                translate([(ring_finger_loc[0]+pinkie_finger_loc[0])/2,overall_length*0.4,base_ht+overall_height])
                    cube([1.2,overall_length*0.63,overall_height*2],center=true);
            }
        }
    }
    // Whack out the screw holes
    screw_holes();
    //  Gap for cable support hole
    translate([overall_width+0.01,cableHoleShift,base_ht-0.01]) rotate([0,0,90]) strain_relief_hole();
}

// A cavity for just a microswitch
module switch_cavity() {
    difference() {
        union() {
        cube([microswitch_wid+microswitch_clearance,microswitch_len+microswitch_clearance,microswitch_ht],center=true);
        // Block the body but allow lots of room for pins and wiring
        translate([0,0,-14]) cube([microswitch_wid-1,microswitch_len-1,28],center=true);
        }
        // Small protrusions to help wedge the switch in place
        translate([-microswitch_wid/2,microswitch_len/4-0.5,0]) rotate([0,-10,0]) translate([0,0,0.5]) cube([0.2,1.5,1],center=true);
        translate([microswitch_wid/2,microswitch_len/4-0.5,0]) rotate([0,10,0]) translate([0,0,0.5]) cube([0.2,1.5,1],center=true);
        translate([-microswitch_wid/2,-microswitch_len/4-0.5,0]) rotate([0,-10,0]) translate([0,0,0.5]) cube([0.2,1.5,1],center=true);
        translate([microswitch_wid/2,-microswitch_len/4-0.5,0]) rotate([0,10,0]) translate([0,0,0.5]) cube([0.2,1.5,1],center=true);
    }
}

// Socket for putting microswitch and cap cover in.
module switch_socket() {
    // The switch cover hole (fidle facto ensures boolean join)
    translate([0,0,-0.05]) cube([keycapWidth+1,keycapWidth+1,keycapInset*2],center=true);
    // A switch cavity
    translate([0,0,-microswitch_ht/2-keycapInset]) switch_cavity();
}

// Enlarge the gap for the pivot to allow clearance
pillarPivotRad=pivotRad+0.2;
pillarBounce=2.5;
pillarInset=keycapInset+pillarBounce;    // Double switch needs room to bounce up and down at the pivot.

// A double socket
module doubleswitch_socket() {
    // The switch cover hole (fidle facto ensures boolean join)
    translate([0,0,-0.05]) cube([doublekeyWidth+1,doublekeyLength+1,pillarInset*2],center=true);
    // A pair of switch cavities
    translate([doublekeyWidth/2-microswitch_wid,0,-microswitch_ht/2-pillarInset]) switch_cavity();
    translate([microswitch_wid-doublekeyWidth/2,0,-microswitch_ht/2-pillarInset]) switch_cavity();
}

switchPillarShave=5;    // Shave this much off at the bottom of the rear edge.
module switch_pillar(ht) translate([0,0,-ht]) {
    difference() {
        // Main body of pillar
        union() {
            translate([0,0,ht/2]) cube([pillarWid,pillarLen,ht],center=true);
            // Bit of reinforcement for the pivot
           translate([0,-pillarLen/2,ht-5]) {
                difference() {
                    // Brace with sloped bottom edge
                    cube([pillarWid,2,10],center=true);
                    translate([0,-2,-5]) rotate([45,0,0]) cube([pillarWid*2,4,4],center=true);
                 }
            }
        }
        // We don't need *all* the pillar, so shave some off to save print time.
        translate([0,-pillarLen/2,ht/2-15]) difference() {
            cube([pillarWid*2,switchPillarShave*2,ht],center=true);
            // Slope the leading edge of the shaved bit.
            translate([0,pillarLen/2,ht/2]) rotate([45,0,0])
                cube([pillarWid*3,switchPillarShave*3,switchPillarShave*3],center=true);
        }
        // Wiring slot
        translate([0,-pillarLen/2,ht*2-15]) cube([3,pillarLen,ht*2],center=true);
        // Switch cavity in the top
        translate([0,0,ht]) switch_socket();
        // Slot for pivot
        translate([0,pillarPivotRad-keycapWidth/2-microswitch_clearance,ht-keycapInset+pillarPivotRad])
            union() {
                rotate([0,90,0]) cylinder(h=pillarWid*3,r=pillarPivotRad,center=true,$fn=25);
                // Slight tweak to semi-captive keycap pivot
                translate([0,0,pillarPivotRad+1.4]) cube([pillarWid*3,pillarPivotRad*2,pillarPivotRad*2],center=true);
            }
         // Slot for "toe" of keycap
         translate([0,-keycapWidth/2,ht-keycapToeHeight*0.24])
            cube([keycapToeWidth+microswitch_clearance*3,pillarWall*4,keycapInset*2],center=true);
         // Gaps allowing for extraction of a switch with pilers
         translate([0,0,ht-keycapInset-2.45]) cube([keycapWidth,4,5],center=true);
    }
    // DEGUG: The keycap for testing fit.
    /*translate([0,0,ht-keycapInset]) color([1,0,0])
        rotate([0,0,90]) translate([pivotRad-keycapWidth/2,0,pivotRad]) rotate([0,-10,0]) translate([keycapWidth/2-pivotRad,0,-pivotRad])
        keycap();*/
}

// Amount to trim off top corners
dsTrim=6;
module doubleswitch_pillar(ht) translate([0,0,-ht]) {
    difference() {
        // Main body of pillar
        translate([0,0,ht/2]) cube([doublepillarWid,doublepillarLen,ht],center=true);
        // Trim top corners for snug fit against shell
        translate([doublepillarWid/2,0,ht]) rotate([0,45,0]) cube([dsTrim,doublepillarLen*2,dsTrim],center=true);
        translate([-doublepillarWid/2,0,ht]) rotate([0,45,0]) cube([dsTrim,doublepillarLen*2,dsTrim],center=true);
        // Wiring slot
        translate([microswitch_len/2-0.01,0,ht*2-15]) cube([doublepillarWid,3,ht*2],center=true);
        // Switch cavity in the top
        translate([0,0,ht]) doubleswitch_socket();
         // Gaps allowing for extraction of a switch with pilers
         translate([0,0,ht-pillarInset-2.45]) cube([doublekeyWidth,4,5],center=true);
        translate([doubleswitchPivotShift,0,0]) {
            // Slot for pivot at front, with captive top
            translate([0,doublepillarLen/2,ht-pillarInset/2-pillarPivotRad/2]) cube([pillarPivotRad*2,doublepillarLen,pillarInset],center=true);
            translate([0,doublepillarLen/2,ht-pillarPivotRad*.9]) rotate([90,0,0]) cylinder(r=pillarPivotRad,h=doublepillarLen,center=true,$fn=22);
            // Slightly higher, narrower slot for pivot at back, with captive top
            translate([0,-doublepillarLen/2,ht+pillarInset-1.3])
            cube([pillarPivotRad*1.9,doublepillarLen,(pillarInset)*2],center=true);
            translate([0,-doublepillarLen/2,ht-pillarInset+pillarPivotRad+1.5]) rotate([90,0,0]) cylinder(r=pillarPivotRad*0.95,h=doublepillarLen,center=true,$fn=22);
        }
    }
    // DEBUG: The keycap for testing fit.
    /*translate([0,0,ht-keycapInset+1]) color([1,0,0])
        translate([pivotRad-keycapWidth/2,0,pivotRad])
        // tilt the switch
        rotate([4,0,0])
        translate([keycapWidth/2-pivotRad,0,-1-pivotRad])
        double_key();*/
}

// Test part for switch fitting
module test_pillar() difference() {
    translate([0,0,18]) switch_pillar(18);
    translate([0,0,-50]) cube(100,center=true);
}

// The translation of this collection of switch pillars is a fiddle factor that frankly I do not understand.
module pillar_collection() {
    translate([0,-shellThickness*0.26,-shellThickness*0.85]) {
        translate(first_finger_loc) rotate(first_finger_rot) switch_pillar(50);
        translate(second_finger_loc) rotate(second_finger_rot) switch_pillar(50);
        translate(ring_finger_loc) rotate(ring_finger_rot) switch_pillar(50);
        // Because pinkie is at a different angle, it needs to come forward a bit.
        translate([0,0.4,0]) translate(pinkie_finger_loc) rotate(pinkie_finger_rot) switch_pillar(50);
        // Trimmed thumb pillar
        difference() {
            translate(thumb_loc) rotate(thumb_rot) rotate(thumb_twist) doubleswitch_pillar(70);
            translate([thumb_loc[0]+70,thumb_loc[1],0]) cube([100,100,100],center=true);
        }
    }
}

module base() intersection() {
    union() {
        difference() {
            union() {
                // Join up the pillars with the base.
                pillar_collection();
                difference() {
                    core_form();
                    translate([0,0,overall_length+base_ht]) cube(overall_length*2,center=true);
                }
                // Block to make cable support in.
                translate([overall_width-shellThickness-6.1,cableHoleShift,4+base_ht])
                    cube([12,14,8],center=true);
            }
            // Chop the excess off the bottom
            translate([0,0,-overall_length]) cube(overall_length*2,center=true);
            // Nice logo
            if (uselogo==1)
                translate([overall_width/2,30,0.5]) scale([2,2,1]) rotate([0,180,0]) linear_extrude(height=11) import("Open-source-hardware-logo.svg");
            // Add screw holes
            screw_holes();
            // Add a "Pi hole" Allow an extra 20 (40/2)for the USB plug
            translate([0,0,6]) translate(boardPlacement) cube([boardLen+40,boardWid+8,12],center=true);
            translate([boardLen/2-boardResetHoleX,boardResetHoleY-boardWid/2,0])
                translate(boardPlacement) cylinder(h=50,r=2.1,center=true,$fn=20);
            // Tunnel and inside part of strain relief hole for cable
            translate([overall_width+0.01,cableHoleShift,base_ht+6])
                cube([50,usb_cable_rad*2-0.4,12],center=true);
            translate([overall_width+0.01,cableHoleShift,base_ht]) rotate([0,0,90])  
                strain_relief_hole();
        }
        // Ridges in USB slot
        translate([overall_width-shellThickness-11,cableHoleShift-usb_cable_rad,base_ht],$fn=10)
            cylinder(h=8,r1=0.8,r2=0.6);
        translate([overall_width-shellThickness-9,cableHoleShift+usb_cable_rad,base_ht],$fn=10)
            cylinder(h=8,r1=0.8,r2=0.6);
        translate([overall_width-shellThickness-7,cableHoleShift-usb_cable_rad,base_ht],$fn=10)
            cylinder(h=8,r1=0.8,r2=0.6);

        // Prop the Pi up.
        translate(boardPlacement) boardPillars();
    }
    // Right, now create a shell * base inclusion to trim off any bits sticking out
    union() {
        translate([overall_width,overall_length,0]) cube([overall_width*2,overall_length*2,base_ht*2],center=true);
        reduced_core_form(shellThickness+0.5);
    }
}


// Use this to test switch and keycap fit
//test_pillar();
//translate([0,30,0]) rotate([0,0,90])
//keycap();
//translate([0,0,18]) doubleswitch_pillar(18);
translate ([0,30,0]) double_key();
//translate([-35,0,0]) thumbkey();
//translate([30,0,0]) commandkey();

//base();
//translate([0,0,base_ht]) 
//  hollow_top_shell();s
