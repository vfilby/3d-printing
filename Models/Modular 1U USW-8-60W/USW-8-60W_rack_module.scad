/* [Bolt holes in the corners] */

use <rj45_keystone_receiver.scad>;
use <unifi_usw_8_60w_model.scad>;



// Pick the size of the long threaded rods that run through
// the corners and hold everything together.
//
// These are the sizes that are commonly available at
// Home Depot or Lowes:
//
// 1/4 inch: 3.175
// #12     : 2.778125
// #10     : 2.38125 (default and recommended)
//
// Note: you should pick the same size and fudge factor
// for the ear parts.
bolt_size = 2.38125;

// Make the bolt holes this much bigger than the size of the bolt
// to give a more comfortable fit
bolt_hole_fudge = 0.2; // [0:0.25:1]


/* [Hidden] */
// make the screw holes this much bigger than the
// actual screw for a more comfortable fit
// (a bigger number here will make the screws fit looser)
screw_hole_fudge = 0.15;
number_to_fit = 6;

usw_8_60_height = 30.7;
usw_8_60_width = 148.5;
usw_8_60_depth = 99.5;

jack_width=18;
jack_height=25;
jack_depth=9.9;

back_window_lip = 5;

height = 33.1423; // match the size of a 13 Pi rack
inner_width = usw_8_60_width;
outer_width = (450.85 - 20) / number_to_fit * 3;
length = 90;

bolt_column_size = 12;

// epsilon is used to slightly overlap pieces to help the previewer
epsilon = 0.001;

bolt_radius = bolt_size + bolt_hole_fudge;

wall_thickness = 10;
inner_wall_thickness = 5;
back_wall_thickness = 5;
floor_depth = 3;
tray_depth = 5;
tray_slot_depth = 2.5;
spacer_depth = 3;

pillar_width = 10;
floor_window_width = usw_8_60_width - (pillar_width * 20);
floor_window_border = (inner_width - floor_window_width) / 2;
floor_window_length = length - back_wall_thickness - floor_window_border - bolt_column_size;
port_window_width = length - 2*pillar_width;
pcb_height = floor_depth + tray_depth + spacer_depth;

difference() {
    union() {
        // the main block
        union() {
            difference() {
                union() {
                    // Regular cube
                    cube([outer_width, length, height]);
                    
                    // the bolt columns
                    translate([0, 0, floor_depth - bolt_column_size]) {
                        cube([outer_width, bolt_column_size, bolt_column_size]);
                    }
                    translate([0, length-bolt_column_size, floor_depth - bolt_column_size]) {
                        cube([outer_width, bolt_column_size, bolt_column_size]);
                    }
                    
                    // extension for USW
                    cube([usw_8_60_width + wall_thickness + inner_wall_thickness, usw_8_60_depth+back_wall_thickness, height]);
                    
                }
                
                // carve out the space for the USW-8-60W
                translate([wall_thickness, -epsilon, floor_depth]) {
//                    cube(  [usw_8_60_width,
//                            usw_8_60_depth,
//                            usw_8_60_height - floor_depth + epsilon + 10]);
                    usw_8_60w();
                }
                
                // Carve out the keystone jack space
                translate([usw_8_60_width+ wall_thickness+inner_wall_thickness, -epsilon, floor_depth]) {
                    cube( [outer_width - usw_8_60_width - (wall_thickness*2) - inner_wall_thickness,
                           length + epsilon,
                           usw_8_60_height - floor_depth + epsilon + 10]);
                }
                
                // carve out bottom
                bottom_lip = 10;
                translate([wall_thickness+bottom_lip, -epsilon+bottom_lip, 0]) {
                    cube(  [usw_8_60_width-(bottom_lip*2),
                            length - back_wall_thickness + epsilon - (bottom_lip*2),
                            usw_8_60_height - floor_depth + epsilon + 10]);
                }                
                
                // carve out sides
                side_vent_count = 2;
                side_vent_start = bolt_column_size;
                side_vent_space = length - (bolt_column_size*2);
                side_vent_padding = 10;
                side_vent_size = (side_vent_space - (side_vent_padding*side_vent_count))/side_vent_count;
                side_vent_top_clearance = 3;
                
                for( a = [0:1:side_vent_count-1] ) {
                    translate( [0, side_vent_start + (side_vent_size*a) + (side_vent_padding*(a+1)), floor_depth] ) {
                        cube([outer_width, side_vent_size,height-floor_depth-side_vent_top_clearance]);
                    }
                    
                }
                
                // carve out back
                translate([wall_thickness+back_window_lip, usw_8_60_depth-epsilon, floor_depth+back_window_lip]) {
                    cube(  [usw_8_60_width-(back_window_lip*2),
                            back_wall_thickness + epsilon,
                            usw_8_60_height + floor_depth + epsilon  ]);
                }         
            }
            
            jack_space = outer_width - usw_8_60_width - (wall_thickness*2) - inner_wall_thickness;
            jack_start = usw_8_60_width + wall_thickness + inner_wall_thickness;
            jack_count = 2;
            jack_padding = (jack_space - (jack_width*jack_count))/(jack_count*2);
            padded_jack_width = jack_width + (jack_padding * 2 );
            
            for( j = [0:1:jack_count-1] ) {
                translate([jack_start + (padded_jack_width*j), 
                           -epsilon, 
                           floor_depth]) {
                    cube( [jack_padding, jack_depth, height - floor_depth] );
                }
                translate([jack_start + (padded_jack_width*j) + jack_padding, 
                           -epsilon+jack_depth, 
                           floor_depth]) {
                    rotate([90,0,0]) {
                        rj45Receiver();
                    }
                }
                translate([jack_start + (padded_jack_width*j) + jack_width + jack_padding, 
                           -epsilon, 
                           floor_depth]) {
                    cube( [jack_padding, jack_depth, height - floor_depth] );
                }
            }
            translate([jack_start, 0, jack_height + floor_depth ]) {
                cube( [jack_space, jack_depth, height - floor_depth - jack_height] );
            }

        }
    }

    

    

    

    
    
    
   

   
    // soften the leading edge a bit
    translate([ wall_thickness,
                0,
                floor_depth-0.5]) {
        rotate([25,0,0]) {
            cube([  inner_width,
                    2,
                    2]);
        }
    }

    // drill the bolt holes
    for (a=[bolt_column_size/2, length-bolt_column_size/2]) {
        translate([-epsilon, a, floor_depth - bolt_column_size/2]) {
            rotate([0, 90, 0]) {
                cylinder(   h=outer_width + 2*epsilon,
                            r=bolt_radius,
                            center=false,
                            $fn=360);
            }
        }
    }
    
    // trim the bolt hole columns
    for (a=[0, bolt_column_size, length-bolt_column_size, length]) {
        translate([-epsilon, a, floor_depth - bolt_column_size - 4]) {
            rotate([45, 0, 0]) {
                cube([outer_width + 2*epsilon, 5, 5]);
            }
        }
    }

}