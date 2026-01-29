// Conceptual parametric airframe (OpenSCAD). Units: mm
wing_span = 950;
wing_chord = 190;
fuse_len = 550;
fuse_w = 60;
fuse_h = 70;

translate([-wing_span/2, -wing_chord/2, 0]) cube([wing_span, wing_chord, 8]);
translate([-fuse_len/2, -fuse_w/2, 25-fuse_h/2]) cube([fuse_len, fuse_w, fuse_h]);
