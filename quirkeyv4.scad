// quirkeyv4.scad - Quirkey version to fit MX clone keyboard switches.
// Released under the GPL 3.0 or later by vik@diamondage.co.nz
// Todo:
// Squish key stem a little more

include <quirkey.inc>
// Logo takes a while to compile. If developing set this to disable it, otherwise use 1.
uselogo=1;
// Flip model for left handers. Complicated by reset hole location and logos...
left_hand=1;                    // 1 for right-handed, -1 for lefties

// Length of the keyswitch body
keyswitch_len=14 ;
keyswitch_rim_len=16 ;
// Height of the keyswitch body including pins, sticky out bits, and solder blobs.
keyswitch_ht=16;
// The distance between the top of the switch body and the bottom of the rim
keyswitch_rim_down=4.0;
// Width of the keyswitch body
keyswitch_wid=13.8;
keyswitch_rim_wid=16;
// The amount of stem you want to leave sticking out of the switch when uncompressed.
keyswitch_stem=4.5;     // Height of stem that descends into the switch. Needs to be a bit over-long
// Clearance for the hole to give a tight fit.
keyswitch_clearance=0.2;

// NOT keyswitch stuff. This is the keycap dimensions.
keycap_width=14;
keycap_height=11;
keycapInset=5;
keycapToeWidth=8;
keycapToeHeight=2;  // "toe" that digs into the back of the pillar to limit key movement
keycapToeLen=7;
keycapClearance=1.0;
doublekeyWidth=26;
doublekeyLength=keycap_width;
doublekeyHeight=7+shellThickness;
doubleswitchSpacing=doublekeyWidth-2*keyswitch_wid;
// The extra amount thumb keys are extended (and inserted)
thumb_key_extension=5.8;
thumb_key_extra_height=0;   // Ammount thumb key extends upwards more than keycap

// Dimensions of a key pillar supports with key cavity therein
pillarWall=1.8;
pillarWid=keyswitch_rim_wid+2*pillarWall;
pillarLen=keyswitch_rim_len+2*pillarWall;
doublepillarLen=keyswitch_rim_len+4*pillarWall;
doublepillarWid=keyswitch_rim_wid*2+4*pillarWall;

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
// Location of the reset button relative to the board.
boardResetHoleY=6.9;
boardResetHoleX=12.25;
boardPlacement=[boardLen/2+shellThickness+6,thumb_loc[1]+22,base_ht];

// Screw hole variables
screwRad=1.9;
screwHeadRad=4;
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
    intersection() {
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


// A cavity for just a keyswitch. This has to have a step half way down, which
// supports the rim of the keyswitch
module switch_cavity() {
    difference() {
        union() {
            // Hole going all the way in, room for pins etc.
            cube([keyswitch_wid+keyswitch_clearance,keyswitch_len+keyswitch_clearance,keyswitch_ht*2],center=true);
            // Bigger hole that the rim can fit into (scale up height to ensure access for inserting
            // (Provide 50mm of clearance to blow a hole through the top of the switch pillar)
            translate([0,0,25])
                cube([keyswitch_rim_wid,keyswitch_rim_len,keyswitch_rim_down+50],center=true);
        }
    }
}

// Screw holes
module screw_holes() {
    for (i=[0:len(screw_hole_list)-1]) {
        translate(screw_hole_list[i]) translate([0,0,-0.1]) {
            cylinder(h=15,r1=screwRad,r2=screwRad-0.3);
            // 45 degree taper for screw head
            cylinder(h=screwHeadRad,r1=screwHeadRad,r2=0);
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
module core_form() union() {
    import("core.stl");
    // Rings around rear screw holes. This fixes a printing issue that requires a brim.
    // Avoiding the brim saves on manufacturing time 'cos it doesn't need cutting off.
    for (i=[0:1]) {
        translate(screw_hole_list[i]) {
            cylinder(h=base_ht,r=screwHeadRad+1.5*junior_scale);
        }
    }
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
    translate([0,0.6,0]) cube([keycap_width+keycapClearance*2,keycap_width+3*keycapClearance,100],center=true);
}

// Fingertip model with a keycap hole attached
module fingerPlusHole() {
    finger();
    // The switch cover hole
    keycapHole() ;
}

// Key cap for finger keys.
keyswitch_stem_width=7.0;      // Width of the stem that descends into the keycap
keyswitch_stem_length=5.4;     // Length ditto
keyswitch_xbar_thick=1.4;       // Thickness of stem cross along X axis
keyswitch_ybar_thick=1.2;       // Ditto y axis
keyswitch_top_section=12;      // Width of the square section knocked out to clear top of switch

// A pair of toes for a keycap with tapered ends.
module toe_pair() {
    translate([0,0,keycapToeHeight/2]) {
        difference() {
            // With of toes is slightly less than the pillar width to avoid collisions with
            // the casing on extremely small-sized keyboards.
            // This decision may come back to bite me.
            cube([keycapToeWidth,pillarWid-1,keycapToeHeight],center=true);
            translate([-keycapToeWidth/2,-pillarWid/2,0]) rotate([0,0,45]) cube(keycapToeHeight*1.4, center=true);
            translate([keycapToeWidth/2,-pillarWid/2,0]) rotate([0,0,45]) cube(keycapToeHeight*1.4, center=true);
            translate([-keycapToeWidth/2,pillarWid/2,0]) rotate([0,0,45]) cube(keycapToeHeight*1.4, center=true);
            translate([keycapToeWidth/2,pillarWid/2,0]) rotate([0,0,45]) cube(keycapToeHeight*1.4, center=true);
        }
    }
}

// Radius of the hole in the centre of the stem. Started out at 2.1
keyswitch_stem_centre=4.0/2;
// Stem is slightly narrower in one direction
keyswitch_stem_scale=[1,4/3.8,1];

module keycap_body() union(){
    difference() {
        difference() {
            // Keycap body
            union() {
                // Basic cube shape of keycap, leaving a space for the stem, one side lopped off.
                difference() {
                    // Create body of keycap with "toes" to prevent it exiting through the lid
                    union() {
                        translate([0,0,keycap_height/2])
                            cube([keycap_width,keycap_width,keycap_height],center=true);
                        toe_pair();
                    }
                    // Hollow it out.
                    translate([-keyswitch_top_section/2,0,keyswitch_stem/2])
                        cube([keyswitch_top_section*2,keyswitch_top_section,keyswitch_stem+0.01],center=true);
                }
                // The stem
                translate([0,0,keycap_height/2])
                    scale(keyswitch_stem_scale) cylinder(h=keycap_height,r=keyswitch_stem_length/2,center=true,$fn=25);
            }
            // Knock a hole in the stem, but leave some solid material at the top
            scale(keyswitch_stem_scale) cylinder(h=keyswitch_stem*2-2,r=keyswitch_stem_centre,center=true,$fn=25);
        }
    }
}

// The thumb keycaps need to have the tops shifted to reduce the separation betweeen
// the keys to 0.5mm, and have the outside edges trimmed back by 1mm to fit through
// the hole in the shell.
thumbcap_displace=(keyswitch_rim_wid-keycap_width)/2-0.1;
thumbcap_trim=1.0;
thumbcap_trim_ht=6;  // Level up the switch at which we trim the edge off and shift it
thumbcap_height=thumb_key_extension+keycap_height+thumb_key_extra_height;
module thumbcap() {
    union() {
        difference() {
            // Keycap body
            union() {
                // Basic cube shape of keycap, leaving a space for the stem, one side lopped off.
                difference() {
                    // Create body of keycap with "toes" to prevent it exiting through the lid
                    union() {
                        // Unshifted lower section
                        translate([-keycap_width/2,-keycap_width/2,0])
                            cube([keycap_width,keycap_width,thumbcap_trim_ht]);
                        // Shifted top section with a bevelled overhanging edge.
                        translate([-keycap_width/2,thumbcap_displace*2-keycap_width/2,thumbcap_trim_ht]) difference() {
                            cube([keycap_width,keycap_width-thumbcap_trim,thumbcap_height-thumbcap_trim_ht]);
                            // The bevel
                            translate([0,keycap_width-thumbcap_trim,0]) rotate([-4,0,0])
                                cube([keycap_width*4,thumbcap_trim*1.4,(keycap_height-thumbcap_trim)*2],center=true);
                        }
                        // Toes, sticking out either side
                        rotate([0,0,90]) toe_pair();
                    }
                    // Whack a hole in the side for the lumpy top part of the switch
                    translate([0,-keyswitch_top_section/2,keyswitch_stem/2])
                        cube([keyswitch_top_section,keyswitch_top_section*2,keyswitch_stem+0.01],center=true);
                }
                // The stem
                translate([0,0,thumbcap_height/2])
                    scale(keyswitch_stem_scale) cylinder(h=thumbcap_height,r=keyswitch_stem_length/2,center=true,$fn=25);
            }
            // Knock a hole in the stem, but leave some solid material at the top
            scale(keyswitch_stem_scale) cylinder(h=keyswitch_stem*2-2,r=keyswitch_stem_centre,center=true,$fn=25);
            // Knock out finger groove in top
            translate([keycap_width*2,thumbcap_displace+thumbcap_trim,finger_groove_rad*2+thumbcap_height-1])
                rotate([180,0,90]) finger();
       }
    }
}


module keycap() difference() {
    keycap_body();
        // Knock out finger groove in top
    translate([keycap_width*.2,0,finger_groove_rad*2+keycap_height-1]) rotate([180,0,90]) finger();
}

// A double keycap for the thumb buttons, working like a teeter-totter.
// Slot sizes are uneven because thumb pressure and angle change with position.
module doublekeyHole() {
        cube([doublekeyWidth+2.3,doublekeyLength+2.3,100],center=true);
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

// Scooped hollow for thumb key
thumb_shape_maj=keycap_width*0.9;
thumb_shape_min=keycap_width*0.5;
thumb_shape_sep=overall_length*0.9;
module weird_thumb_shape() {
    rotate([20,-55,0]) union() {
            sphere(thumb_shape_maj,$fn=60);
            rotate([90,0,0]) cylinder(r1=thumb_shape_maj,r2=thumb_shape_min,h=thumb_shape_sep,$fn=60);
            translate([0,-thumb_shape_sep,0]) sphere(thumb_shape_min,$fn=60);
    }
}

// The previous scalop that didn't come all the way to the rear of the shell.
// Dunno if I like the new one yet.
module weird_thumb_shape_old() {
    sphere(keycap_width*0.95,$fn=60);
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
            rotate([3-wrist_tilt,thumb_slope+10,0])  rotate(thumb_twist) scale([2,1.8,0.45]) 
        weird_thumb_shape();
    }
}

// Scaled down core form, used for hollowing out.
module reduced_core_form(reduce) {
    translate([reduce,reduce,-0.01])
        scale([(overall_width-2*reduce)/overall_width,(overall_length-2*reduce)/overall_length,(overall_height-reduce)/overall_height])
        core_form();
}

// Hollow top shell minus the base.
module hollow_top_shell() scale([left_hand,1,1]) translate([0,0,-base_ht])  difference() {
    union() {
        difference() {
            body_construction();
            reduced_core_form(shellThickness);
            // Chop the base off
            translate([0,0,base_ht-overall_length*2]) cube(overall_length*4,center=true);
            // Fancy schmanzy logo
            if (uselogo==1)
                translate([overall_width/2,overall_length/2,(overall_height+height_boost)*0.83-0.75]) rotate([-wrist_tilt,0,0]) scale([4*left_hand,4,4]) linear_extrude(height=10) import("quirkey_logo.svg");
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
// Socket for putting keyswitch and cap cover in.
module switch_socket() {
    // A switch cavity
    translate([0,0,-keycapInset-keyswitch_stem]) switch_cavity();
}

pillarInset=keycapInset-1;    // Tweakable inset for thumb pillar

// A double socket for the thumb switches
module doubleswitch_socket() {
    translate([-keyswitch_rim_wid/2,0,-keyswitch_stem-pillarInset-thumb_key_extension]) switch_cavity();
    // Remove ugly boolean artifact between them with teeny fiddlefactor
    translate([keyswitch_rim_wid/2-0.01,0,-keyswitch_stem-pillarInset-thumb_key_extension]) switch_cavity();
}

switchPillarShave=5;    // Shave this much off at the bottom of the rear edge.
module switch_pillar(ht) translate([0,0,-ht]) {
    difference() {
        // Main body of pillar
        translate([0,0,ht/2]) cube([pillarWid,pillarLen,ht],center=true);
        // We don't need *all* the pillar, so shave some off to save print time.
        translate([0,-pillarLen/2,ht/2-15]) difference() {
            cube([pillarWid*2,switchPillarShave*2,ht],center=true);
            // Slope the leading edge of the shaved bit.
            translate([0,pillarLen/2,ht/2]) rotate([45,0,0])
                cube([pillarWid*3,switchPillarShave*3,switchPillarShave*3],center=true);
        }
        // Wiring slot
        translate([0,-pillarLen/2,ht*2-20]) cube([3.5,pillarLen,ht*2],center=true);
        // Switch cavity in the top
        translate([0,0,ht]) switch_socket();
         // Slots for "toes" of keycap
         translate([0,0,ht-keycapToeHeight])
            cube([pillarWid+pillarWall*4,keycapToeWidth+keyswitch_clearance*3,keycapInset*2],center=true);
    }
    // DEBUG: The keycap for testing fit.
    //%translate([0,0,ht-keycapInset]) color([1,0,0]) rotate([0,0,90]) keycap();
}

// Amount to trim off top corners
dsTrim=6;
// Amount of "flex" in letting the double switch flop backwards and forward.
dsFlex=1.4;
// A pillar that holds the double thumb switches, so either or both switches can be activated.
module doubleswitch_pillar(ht) translate([0,0,-ht]) {
    difference() {
        // Main body of pillar
        translate([0,0,ht/2]) cube([doublepillarWid,doublepillarLen,ht],center=true);
        // Trim top corners for snug fit against shell
        translate([doublepillarWid/2,0,ht]) rotate([0,45,0]) cube([dsTrim,doublepillarLen*2,dsTrim],center=true);
        translate([-doublepillarWid/2,0,ht]) rotate([0,45,0]) cube([dsTrim,doublepillarLen*2,dsTrim],center=true);
        // Wiring slot
        translate([keyswitch_len/2-0.01,0,ht*2-27]) cube([doublepillarWid,3.5,ht*2],center=true);
        // Switch cavity in the top
        translate([0,0,ht]) doubleswitch_socket();
         // Slots for "toes" of keycap
         translate([keyswitch_rim_wid/2-(keycapToeWidth+keyswitch_clearance*3)/2,-(doublepillarLen+pillarWall*4)/2,ht-thumb_key_extension-keycapToeHeight-keycapInset])
            cube([keycapToeWidth+keyswitch_clearance*3,doublepillarLen+pillarWall*4,keycapInset*4]);
         translate([-keyswitch_rim_wid/2-(keycapToeWidth+keyswitch_clearance*3)/2,-(doublepillarLen+pillarWall*4)/2,ht-thumb_key_extension-keycapToeHeight-keycapInset])
            cube([keycapToeWidth+keyswitch_clearance*3,doublepillarLen+pillarWall*4,keycapInset*4]);
    }
    // DEBUG: The keycaps for testing fit.
    /*
    translate([keyswitch_rim_wid/2,0,ht-keycapInset-thumb_key_extension+1]) color([1,0,0])
        %rotate([0,0,90]) thumbcap();
    translate([-keyswitch_rim_wid/2,0,ht-keycapInset-thumb_key_extension+1]) color([1,0,0])
        %rotate([0,0,-90]) thumbcap();*/
}

// Test part for switch fitting
module test_pillar(ht) difference() {
    translate([0,0,ht]) switch_pillar(ht);
    translate([0,0,-50]) cube(100,center=true);
}

// Doube switch pillar for testing
module test_double_pillar() difference() {
    translate([0,0,28]) doubleswitch_pillar(28);
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
            translate([thumb_loc[0]+77,thumb_loc[1],0]) cube([100,100,100],center=true);
        }
    }
}

module base() scale([left_hand,1,1]) intersection() {
    union() {
        difference() {
            union() {
                // Join up the pillars with the base.
                pillar_collection();
                difference() {
                    core_form();
                    translate([0,0,overall_length*2+base_ht]) cube(overall_length*4,center=true);
                }
                // Block to make cable support in.
                translate([overall_width-shellThickness-6.1,cableHoleShift,4+base_ht])
                    cube([12,14,8],center=true);
            }
            // Chop the excess off the bottom
            translate([0,0,-overall_length]) cube(overall_length*2,center=true);
            // Nice logo
            if (uselogo==1)
                translate([overall_width/2,30,0.5]) scale([2*left_hand,2,1]) rotate([0,180,0]) linear_extrude(height=11) import("Open-source-hardware-logo.svg");
            // Add screw holes
            screw_holes();
            // Add a "Pi hole" Allow an extra 20 (40/2)for the USB plug
            translate([0,0,8]) translate(boardPlacement) cube([boardLen+34,boardWid+4,16],center=true);
            // A hole right under the reset button. Flip this for the left-hand version as board
            // is rotated through 180 degrees to point at the other side of the keyboard shell.
            translate([boardLen/2-boardResetHoleX,left_hand*(boardResetHoleY-boardWid/2),0])
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

// Holds 4 key switches, and can be clamped in a PCB holder to make
// soldering wires onto switches easier
jigSpacing=2;
module key_soldering_jig() {
    for (i=[0:3])
        translate([(pillarWid+jigSpacing)*i,0,0])
            // Basically a key pillar with a lot of the top lopped off for soldering access
            difference() {
                union() {
                    test_pillar(15);
                    // Tabs to grab on to each other and PCB holder
                    cube([pillarWid+jigSpacing*2+2,pillarLen,pillarWall],center=true);
                }
                // Lop off top
                translate([0,0,50+3+keycapInset]) cube(100,center=true);
                // Hole for keyswitch head to poke through
                cube([keyswitch_wid,keyswitch_len,15],center=true);
            }
}

// Thing to hold keyswitches while you solder the wires on (optional)
//key_soldering_jig();
// Use this to test switch and keycap fit
//test_pillar(25);
//translate([0,30,0]) rotate([0,0,90])
//keycap();
//test_double_pillar();
//translate([0,-25,0]) thumbcap();
// translate([0,25,0]) thumbcap();
base();
//translate([0,0,base_ht]) 
// hollow_top_shell();
