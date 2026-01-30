
// tailsitter_vtol_aligned.scad
// Conceptual Tail-sitter VTOL CAD (OpenSCAD)
// Dimensions aligned with requirements.yaml
// Purpose: VISUAL VTOL clarity (prop disk + upright pose)
// Units: mm

// =======================
// Geometry (from YAML)
// =======================
wing_span_mm   = 950;   // 0.95 m
wing_chord_mm  = 190;   // 0.19 m
fuse_len_mm    = 550;   // 0.55 m
taper_ratio    = 0.60;
wing_thk_mm    = 10;

cg_from_nose_mm = 280;  // 0.28 m

// =======================
// VTOL cues
// =======================
prop_diam_mm   = 254;   // 10-inch prop (visual cue)
prop_thk_mm    = 4;
motor_len_mm   = 60;
motor_diam_mm  = 45;

skid_len_mm    = 120;
skid_w_mm      = 18;
skid_h_mm      = 10;
skid_offset_mm = 65;

// =======================
// Display options
// =======================
show_upright_pose = true;
show_cg_marker    = true;

$fn = 96;

// =======================
// Modules
// =======================
module cg_marker() {
    if (show_cg_marker)
        translate([cg_from_nose_mm,0,0]) sphere(d=14);
}

module motor_and_prop() {
    translate([0,0,0])
        rotate([0,90,0])
            cylinder(h=motor_len_mm, d=motor_diam_mm);

    translate([-6,0,0])
        rotate([0,90,0])
            cylinder(h=prop_thk_mm, d=prop_diam_mm);
}

module fuselage() {
    hull() {
        translate([0,0,0])        scale([1,0.9,1]) sphere(d=75);
        translate([300,0,0])      scale([1,0.9,1]) sphere(d=75);
        translate([fuse_len_mm,0,0]) scale([1,0.75,0.8]) sphere(d=75);
    }
}

module wing() {
    half_span = wing_span_mm/2;
    root = wing_chord_mm;
    tip  = taper_ratio * root;
    x0 = fuse_len_mm*0.42;

    module half(sign=1) {
        linear_extrude(height=wing_thk_mm, center=true)
            polygon(points=[
                [x0,0],
                [x0+root,0],
                [x0+tip,sign*half_span],
                [x0,sign*half_span]
            ]);
    }

    union() {
        half(1);
        half(-1);
    }
}

module fins() {
    for (s=[-1,1])
        translate([fuse_len_mm*0.92,s*22,0])
            cube([80,6,70],center=false);
}

module skids() {
    for (s=[-1,1])
        translate([fuse_len_mm*0.78,s*skid_offset_mm,-45])
            cube([skid_len_mm,skid_w_mm,skid_h_mm],center=true);
}

module vehicle() {
    color([0.75,0.75,0.78])
    union() {
        fuselage();
        wing();
        fins();
        motor_and_prop();
        skids();
        cg_marker();
    }
}

// =======================
// Scene
// =======================
if (show_upright_pose) {
    rotate([0,-90,0])
        translate([0,0,prop_diam_mm*0.55])
            vehicle();

    color([0.9,0.92,0.95,0.6])
        cube([1200,1200,2],center=true);
} else {
    vehicle();
}
