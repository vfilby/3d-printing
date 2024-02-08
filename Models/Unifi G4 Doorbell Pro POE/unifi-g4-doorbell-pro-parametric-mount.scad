
// ===== PARAMETERS ===== //

/* [General Settings] */

angle = 15; // [25:1:45]


// Angle the back to fix siding
siding_angle = -5; // siding angle (e.g. -12)
siding_extra_offset = 7.5; // extra offset to provide enough depth to account for the extra cut

mount_door_side = 1; // [0:left, 1:right]

trim_back_edge = false;

rotate_for_printing = true;

/* [Setup Parameters] */
$fa = 3;
$fs = 0.25;

// ===== IMPLEMENTATION ===== //

module screw_hole (offset = [0, 0, 0]) {
               translate(offset) {
            
                color("cyan")
                mirror([0, 0, 1])
                cylinder(depth, screw_hole_radius, screw_hole_radius);

                color("blue")                
                translate([0, 0, -screw_hole_indent_depth])
                linear_extrude(height = screw_hole_indent_depth + epsilon * 2) {
                    offset(r = screw_hole_indent_corner_radius) {
                        square(screw_hole_indent_size - [screw_hole_indent_corner_radius, screw_hole_indent_corner_radius] * 2.0, center = true);
                    }
                }
            }
}

module access_holes () {
    
    translate([0, 0, -(outer_size.y / 2.0 + epsilon)]) {
        translate([pin_hole_offset.x, -pin_hole_offset.y, -pin_hole_depth/2]) {

            cylinder(pin_hole_depth, pin_hole_outer_radius, pin_hole_outer_radius);
            
            translate( [-pin_hole_outer_radius,0,0] )
            cube([pin_hole_outer_radius*2,10,pin_hole_depth]);
          
        }

        // slit
        translate([0, -slit_top_offset, 0])
        linear_extrude(height = pin_hole_depth + epsilon)
        offset(r = slit_corner_radius) 
        square(slit_size - [slit_corner_radius, slit_corner_radius] * 2.0, center = true);
    }
}

min_edge_height = 6.5;

outer_size = [53.0, 162.5];
depth = 100;
inner_depth = 8.5;

corner_radius = 11;
chamfer = [5, 5];
wall_thickness = [1.0, 1.0];
lip_height = 0.65;

inner_size = outer_size - wall_thickness * 2.0;

inner_bottom_size = inner_size - chamfer * 2.0;
inner_bottom_scale = [inner_bottom_size.x / inner_size.x, inner_bottom_size.y / inner_size.y];

inner_hole_size = [ 31.0, 50.5 ];
inner_hole_scale = inner_hole_size.x / outer_size.x;
inner_hole_corner_radius = corner_radius * inner_hole_scale;

screw_hole_indent_size = [19.0, 14.0];
screw_hole_indent_depth = 1.25;
screw_hole_indent_corner_radius = 1;
screw_hole_diameter = 6.2;
screw_hole_radius = screw_hole_diameter / 2.0;
screw_hole_distance = 67.5;
screw_hole_offset = screw_hole_distance / 2.0;
screw_hole_depth = depth;

// slit
slit_size = [5.0, 1.1];
slit_corner_radius = 0.5;
slit_top_offset = 2.25 + slit_size.y / 2.0;

// hole
// G4 pro 4.75mm
pin_hole_offset = [9.5, 3.5];
pin_hole_width = 4.75;
pin_hole_outer_diameter = pin_hole_width;
pin_hole_depth = 10;
pin_hole_outer_radius = pin_hole_outer_diameter / 2.0;

// wedge cut
wedge_cut_size = [200, 200, 200];
wedge_cut_offset = min_edge_height + (sin(angle) * outer_size.x / 2.0) / cos(angle);
wedge_cut2_offset = (inner_hole_size.x) / sin(90 - angle) / 2.0 + wall_thickness.x;


epsilon = 0.001;
print_angle = rotate_for_printing ? angle : 0;
flip_angle = mount_door_side == 0 ? 0 : 180;

rotate(flip_angle, [0, 0, 1])
rotate(print_angle, [0, 1, 0]) { // for printing without supports
    difference() {
        // shell
        translate([0, 0, -depth]) {
            linear_extrude(height = depth) {
                offset(r = corner_radius) {
                    square(outer_size - [corner_radius, corner_radius] * 2.0, center = true);
                }
            }
        }
        
        translate([0, 0, -lip_height]) {
        
            // inner lip cut
            color("red")
            linear_extrude(height = lip_height + epsilon) {
                offset(r = corner_radius) {
                    square(inner_size - [corner_radius, corner_radius] * 2.0, center = true);
                }
            }
            
            
            // inner chamfer cut
            color("purple")
            translate([0, 0, epsilon]) {
                mirror([0, 0, 1]) {
                    linear_extrude(height = inner_depth, scale = inner_bottom_scale) {
                        offset(r = corner_radius) {
                            square(inner_size - [corner_radius, corner_radius] * 2.0, center = true);
                        }
                    }
                }
            }
            

            translate([0, 0, -inner_depth]) {
               // inner hole cut
                color("orange")
                translate([0, 0, -depth - epsilon]) {
                    linear_extrude(height = depth + epsilon * 3) {
                        offset(r = inner_hole_corner_radius) {
                            square(inner_hole_size - [inner_hole_corner_radius, inner_hole_corner_radius] * 2.0, center = true);
                        }
                    }
                }
                
                // screw hole cut
                screw_hole(offset = [0, screw_hole_offset, 0]);
                screw_hole(offset = [0, -screw_hole_offset, 0]);
     
                
            }
        }
        
        // bottom hole and slit
        color("green") {
                rotate(90, [1, 0, 0])
                mirror([1, 0, 0])
                mirror([0, 0, 1])
                access_holes();
            
                rotate(90, [1, 0, 0])
                access_holes();  

//            if (mount_door_side == 0) {
//                rotate(90, [1, 0, 0])
//                mirror([1, 0, 0])
//                mirror([0, 0, 1])
//                access_holes();
//            } else {
//                rotate(90, [1, 0, 0])
//                access_holes();        
//            }
        } 
     
        // Siding Angle Cut
        color("grey") {
            cube(wedge_cut_size);
        }
     
        // wedge cut
        color("magenta")
        mirror([0, 0, 1])
        translate([0, 0, wedge_cut_offset + siding_extra_offset])
        rotate(angle, [0, 1, 0])
        rotate(siding_angle, [1,0,0])
        translate([- wedge_cut_size.x / 2.0, - wedge_cut_size.y / 2.0, 0])
        cube(wedge_cut_size, center = false);
        
        // wedge cut 2
        if (trim_back_edge) {
            color("red")
            mirror([0, 0, 1])
            translate([0, 0, wedge_cut_offset])
            rotate(angle - 90, [0, 1, 0])
            translate([0, 0, wedge_cut2_offset])
            translate([- wedge_cut_size.x / 2.0, - wedge_cut_size.y / 2.0, 0])
            cube(wedge_cut_size, center = false);
        }
    }
}
