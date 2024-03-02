// quirkey.inc - Common values for the quirkey keyboard

junior_scale=1.00;  // Standard size is 1, intermediate 0.92, junior version best at 85%
shellThickness=4.5;               // Thickness of the top shell
// If the junior scale is less than 0.9 we want to raise the height and switches.
// This is needed to let large MX switches fit in the shell.
height_boost=max(0,(0.92-junior_scale)*50);
palm_width=88*junior_scale;      // Width of the palm only.
thumb_width=25*junior_scale;     // Width of the thumb slope only
palm_rest_rad=26*junior_scale;   // Radius of the bit the heel of the palm rests on
overall_length=150*junior_scale;
overall_width=120*junior_scale;
overall_height=2*palm_rest_rad;
fingers_start=105*junior_scale;   // Distance from back of palm to 1st knuckle
finger_groove_rad=25*junior_scale;   // Radius of a finger groove
fingertips_start=115*junior_scale;   // Start of first fingertip, measured from heel.
finger_major_spacing=24*junior_scale;    // Gap between fingers 1, 2 & 3
first_finger_left=thumb_width+finger_groove_rad/2-7*junior_scale;
thumb_up=58*junior_scale;    // Thumb switch from heel
thumb_slope=-50;    // Slope on thumb side.
// We tilt the whole thing so the nice, flat upper surface we designed on
// is now sloping down away from the user for better ergonomics.
wrist_tilt=90-atan((overall_length-palm_rest_rad)/palm_rest_rad);
// Dynamic curving
dc_scale=0.7;
dc_min_rad=(overall_width*dc_scale)/2;
dc_overscale=1.02;

// Base component
base_ht=4;  // Overall height of base.
usb_cable_rad=3.7/2;

// Location of the switch holes. Height of the fingers is relative to
finger_base_ht=(palm_rest_rad+height_boost)*1.34;
thumb_base_ht=palm_rest_rad*1.2+height_boost;
// Location of main thumb key
thumb_loc=[thumb_width/2+finger_major_spacing*0.45-7*junior_scale,(thumb_up+fingertips_start)*0.37-6*junior_scale,thumb_base_ht+6.3*junior_scale];
thumb_rot=[-10,thumb_slope+9,0];
thumb_twist=[0,0,13];
// Location of thumb control key
first_finger_loc=[first_finger_left,fingertips_start,finger_base_ht-4];
first_finger_rot=[-35,0,5];
second_finger_loc=[finger_major_spacing+first_finger_left,fingertips_start+6,finger_base_ht-8.0];
second_finger_rot=[-35,0,3];
ring_finger_loc=[finger_major_spacing*2+first_finger_left,fingertips_start+4,finger_base_ht-6.4];
ring_finger_rot=[-35,0,0];
pinkie_finger_loc=[finger_major_spacing*3+1+first_finger_left,fingertips_start-12,finger_base_ht+0.7];
pinkie_finger_rot=[-18,0,0];

