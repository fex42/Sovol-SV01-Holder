//
// Board-Fan and stepdown holder for Sovol SV01
//
// This is a non invasive holder for a fan and two step down converters
//
// The fan used is this 70x70x10 fan (driven with 8-9V it is quite enough):
// https://www.pollin.de/p/axialluefter-y-s-tech-fd127010lb-70x70x10-mm-12-v-320452
//
// The step down converters are this (one for 12V, the other for 8.5V):
// https://www.aliexpress.com/item/32721507753.html
//

include <polyround.scad>

$fn = 30;
clearance = 0.1;

bp_h = 2.5; // base plate height

// case mounting screw positions

cms_dx = 35; // delta x of screw posts
cms_dy = 35; // delta y of screw posts

cms = [[-cms_dx/2, +cms_dy/2],    // screw 1
       [+cms_dx/2, -cms_dy/2]];   // screw 2

cms_id1 = 6 + clearance; // inner diameter 1
cms_ih1 = 7; // inner height 1

cms_id2 = 3.5; // inner diameter 2
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


// fan mount posts

fmd = 40; // distance of outer fan mount screws
fmy = 35; //

fmp = [[-fmd/2, fmy],
       [0, fmy-13],
       [fmd/2, fmy]];

fp_od = 6;
fp_oh = 28;

fp_id = 3.0 - clearance;
fp_ih = fp_oh + clearance;
fp_iz = 15;



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
    cylinder(d=fp_od, h=fp_oh);
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
#            allScrewsOuter();
            linear_extrude(bp_h) polygon(polyRound(mirroredOuterPoints,30));
        }
        translate([0,0,-clearance/2]) linear_extrude(bp_h+clearance) polygon(polyRound(mirroredInnerPoints,30));

        allScrewsInner();
    }
    //  %translate([0,0,0.3])polygon(getpoints(mirroredOuterPoints));
}

baseplate();
