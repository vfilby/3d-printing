
include <BOSL/shapes.scad>;

usw_8_60_height = 30.7;
usw_8_60_width = 148;
usw_8_60_depth = 99.5;
dimension_padding = 0.5;

side_foot_offset = 15;
front_foot_offset = 20;
back_foot_offset = 11;

foot_height = 1;
foot_width = 12;
foot_depth = 7;
foot_clearance = 3;

back_ground_width = 13;
back_ground_clearance = 1;

module usw_8_60w() {
	union() { 
		// main unit
		cube(  [usw_8_60_width+dimension_padding,
				usw_8_60_depth+dimension_padding,
				usw_8_60_height]);
		
		// foot pads
		for( trans = [[side_foot_offset,front_foot_offset], 
				  	[side_foot_offset,usw_8_60_depth-back_foot_offset], 
				  	[usw_8_60_width-side_foot_offset, front_foot_offset], 
				  	[usw_8_60_width-side_foot_offset,usw_8_60_depth-back_foot_offset] ] ) 
		{
								
			translate( [trans[0],trans[1],+3] ) {
				cuboid( [foot_width+foot_clearance, foot_depth+foot_clearance, 10], fillet=2, center=true);
			}
		}
		// back ground cable
        translate([usw_8_60_width-(back_ground_width/2)-back_ground_clearance,
                   usw_8_60_depth,
                   usw_8_60_height/2]) {
            cuboid( [back_ground_width, 5, usw_8_60_height-(back_ground_clearance*2)], fillet=2, center=true );
        }
	}
}

usw_8_60w();