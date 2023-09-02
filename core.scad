// quirkeyv3.scad - Quirkey version with captive keycaps and simplified wiring.

include <quirkey.inc>

// This is the rounded bit you put the heel of your palm on.
// Round off the lower edge of the rear of the shell.
heel_rad=3.5;
module heel() translate([0,palm_rest_rad,0]) union() {
    // Smoothed cylindrical bit where palm rests
    translate([0,0,palm_rest_rad]) rotate([-wrist_tilt,0,0]) {
        rotate([0,90,0])
            cylinder(h=overall_width,r=palm_rest_rad,$fn=pow(palm_rest_rad,1.4));
        cube([overall_width,overall_length-palm_rest_rad,palm_rest_rad]);
    }
    // Corner radius on heel
    translate([0,heel_rad-palm_rest_rad,heel_rad]) rotate([0,90,0])
        cylinder(h=overall_width,r=heel_rad,$fn=pow(heel_rad,2));
    // Squared off heel
    translate([0,-palm_rest_rad,0])
        difference() {
            cube([overall_width,palm_rest_rad,palm_rest_rad]);
            rotate([45,0,0])
                translate ([overall_width,-1,0])
                    cube([overall_width*3,heel_rad*2,heel_rad*2],center=true);
        }
}

// The very basic solid form, designed so that eveything happens relative
// to the bottom rear corner of the heel.
module core_form()  intersection() {
    difference() {
        union() {
            // Part under heel of palm
            heel();
            // Part directly under palm
            translate([0,palm_rest_rad,0]) 
                cube([overall_width,overall_length-palm_rest_rad,palm_rest_rad]);
        }
        // Subtract basic outline shaping parts.
        // Thumb side slope
        translate([0,-palm_rest_rad,palm_rest_rad*1.5])
        rotate([-wrist_tilt,0,0]) rotate([0,-thumb_slope,5]) 
            translate([-overall_length,0,0]) cube([overall_length*2,overall_length*4,overall_length*2],center=true);
        // Pinky side slope
        translate([overall_width+1,0,palm_rest_rad]) 
            rotate([-wrist_tilt,-8,0]) translate([overall_length*2,0,0]) cube(overall_length*4,center=true);
        // Slope under the fingers
        translate([0,overall_length,palm_rest_rad*0.2])
            rotate([-25-wrist_tilt,0,0]) translate([-overall_width,-overall_length*2,0]) cube([overall_width*3,overall_length*4,palm_rest_rad*10]);
    }
    // INTERSECTION
    // Dynamic curve to trim front
    rotate([15,0,0]) translate([overall_width/2,overall_length-dc_min_rad-6,0]) {
    // The curve
    scale([1,dc_scale,1]) cylinder(h=palm_rest_rad*10,r=dc_overscale*overall_width/2,center=true,$fn=overall_width);
    // Solid block behind curve.
    translate([0,-overall_length*2,0])
        cube([dc_overscale*overall_width,overall_length*4,palm_rest_rad*10],center=true);
    }
}

core_form();
