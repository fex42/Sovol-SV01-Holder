//
// Board-Fan and stepdown holder for Sovol SV01
//
// This is a non invasive holder for a fan and two step down converters.
//
// The fan used is this 70x70x10 fan:
// https://www.pollin.de/p/axialluefter-y-s-tech-fd127010lb-70x70x10-mm-12-v-320452
// (driving this fan with 8-9V makes it very quiet while still cooling enough)
//
// The step down converters are this (one for 12V, the other for 8.5V):
// https://www.aliexpress.com/item/32721507753.html
//
// This is also my first attempt zu use the great Round-Anything library
// you can find here:
// https://github.com/Irev-Dev/Round-Anything
// (The needed polyround.scad file from the lib is included for self-containedness)
//

include <polyround.scad>

$fn = 80;
clearance = 0.1;

bp_h = 2.5; // base plate height

// case mounting screw positions

cms_dx = 35; // delta x of screw posts
cms_dy = 35; // delta y of screw posts

cms = [[-cms_dx/2, +cms_dy/2],    // screw 1
       [+cms_dx/2, -cms_dy/2]];   // screw 2

cms_id1 = 6 + 2*clearance; // inner diameter 1
cms_ih1 = 7; // inner height 1

cms_id2 = 3.5 + clearance; // inner diameter 2
cms_ih2 = cms_ih1 + 5; // inner height 2

cms_od = 10; // outer diameter
cms_oh = cms_ih1 + 1.7; // outer height

// step down converter screws

sdc_dx = 15.6; // delta x of the two screws
sdc_dy = 29.8; // delta y of the two screws

sdc1_x = -26; // top right screw of 1st step down converter (x)
sdc1_y = 14.4; // top right screw of 1st step down converter (y)

sdc2_x = 26 + sdc_dx; // top right screw of 2nd step down converter (x)
sdc2_y = sdc1_y; // top right screw of 2nd step down converter (x)

sdcs = [[sdc1_x, sdc1_y],
        [sdc1_x - sdc_dx, sdc1_y - sdc_dy],
        [sdc2_x, sdc2_y],
        [sdc2_x - sdc_dx, sdc2_y - sdc_dy]];

sdc_od = 6; // outer diameter
sdc_oh = 6; // outer height

sdc_id = 3.0 - clearance; // inner diameter
sdc_ih = sdc_oh + 2*clearance; // inner height


// fan mount posts (bottom part)

fmd = 40; // distance of outer fan mount screws
fmy = 35; //

// fan mount post coordinates (used also in top part)
fmp = [[-fmd/2, fmy],
       [0, fmy-18],
       [fmd/2, fmy]];

fp_od = 6; 
fp_oh = 28;
fp_od2 = fp_od + 3;
fp_oh2 = 15;
fp_oht = fp_oh-fp_oh2+bp_h - 3*clearance; //fp_oh-fp_oh2-1;

fp_id = 3.0 - clearance;
fp_ih = fp_oh + clearance;
fp_iz = fp_oh2;

// fanmount (top part)

fwh = 70; // fan width/height
fhd = 67; // fan hole diameter
fsd = 61.5; // fan screw distance
fb = 3; // fan frame border
fy = fmy+15; // y position
fc_x = 0; // fan center x
fc_y = fy+fwh-fb-fhd/2; // fan center y

// fan screw point coordinates
fs = [[fc_x+fsd/2,fc_y+fsd/2],
      [fc_x-fsd/2,fc_y+fsd/2],
      [fc_x+fsd/2,fc_y-fsd/2],
      [fc_x-fsd/2,fc_y-fsd/2]];

module caseMountScrewOuter() {
    cylinder(d=cms_od, h=cms_oh);
}

module caseMountScrewInner() {
        cylinder(d=cms_id1, h=cms_ih1);
        cylinder(d=cms_id2, h=cms_ih2);
}

module caseMountScrews(cms) {
    for (p=cms) {
        translate([p[0], p[1], 0]) children();
    }
}

module stepDownConverterScrewsOuter() {
    cylinder(d=sdc_od, h=sdc_oh);
}

module stepDownConverterScrewsInner() {
    cylinder(d=sdc_id, h=sdc_ih);
}

module stepDownConverterScrews(sdcs) {
    for (p=sdcs) {
        translate([p[0], p[1], 0]) children();
    }
}

module fanMountPostOuter() {
    cylinder(d=fp_od-clearance, h=fp_oh);
    cylinder(d=fp_od2-clearance, h=fp_oh2);
}

module fanMountPostInner() {
    translate([0,0,fp_iz]) cylinder(d=fp_id, h=fp_ih);
}

module fanMountPosts(sdcs) {
    for (p=sdcs) {
        translate([p[0], p[1], 0]) children();
    }
}

module allScrewsOuter() {
    caseMountScrews(cms) caseMountScrewOuter();
    stepDownConverterScrews(sdcs) stepDownConverterScrewsOuter();
    fanMountPosts(fmp) fanMountPostOuter();
}

module allScrewsInner() {
    translate([0,0,-clearance]) {
        caseMountScrews(cms) caseMountScrewInner();
        stepDownConverterScrews(sdcs) stepDownConverterScrewsInner();
        fanMountPosts(fmp) fanMountPostInner();
    }
}

module baseplate() {
    function outerPoints(endR=0)=[[0,32,7],[26,46,7],[27,21,7],[45,21,5],[45,-23,5],[0,-23,endR]];
    mirroredOuterPoints=mirrorPoints(outerPoints(0),180,[1,0]);

    function innerPoints(endR=0)=[[0,11,0],[8,11,5],[16,11,6],[35,11,3],[35,-12,3],[0,-12,endR]];
    mirroredInnerPoints=mirrorPoints(innerPoints(0),180,[1,0]);

    difference() {
        union() {
            allScrewsOuter();
            linear_extrude(bp_h) polygon(polyRound(mirroredOuterPoints,30));
        }
        translate([0,0,-clearance/2]) linear_extrude(bp_h+clearance) polygon(polyRound(mirroredInnerPoints,30));

        allScrewsInner();
    }
    //  %translate([0,0,0.3])polygon(getpoints(mirroredOuterPoints));
}

module fanMountPostOuterTop() {
    translate([0,0,0]) cylinder(d=fp_od+3, h=fp_oht);
    hull() {
        translate([0,11,0]) cylinder(d=2.5, h=bp_h);
        translate([0,0,0]) cylinder(d=fp_od2, h=fp_oh/2-bp_h);
    }
}

module fanMountPostInnerTop() {
    translate([0,0,bp_h]) cylinder(d=fp_od+2*clearance, h=fp_oh-bp_h);
    translate([0,0,-clearance]) cylinder(d=cms_id2+2*clearance, h=fp_oh-bp_h);
}

module fanMount() {
    function outerPoints(endR=0)=[[0,0,17.5],[38,fy,30],[38,fy+fwh,5],[0,fy+fwh,0]];
    mirroredOuterPoints=mirrorPoints(outerPoints(0),180,[1,0]);

    difference() {
        union() {
            linear_extrude(bp_h) polygon(polyRound(mirroredOuterPoints,30));
            fanMountPosts(fmp) fanMountPostOuterTop();
        }
        fanMountPosts(fmp) fanMountPostInnerTop();
        translate([fc_x,fc_y,-clearance/2]) cylinder(d=fhd, h=bp_h + clearance);
        for(s=fs) {
            translate([s[0],s[1],-clearance]) cylinder(d=fp_id,h=10);
        }
    }
}

translate([0,-43,0]) baseplate();
translate([0,-10,0]) fanMount();
