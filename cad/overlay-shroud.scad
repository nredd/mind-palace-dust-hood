/*
 * Overlay shroud -- ORIGINAL OpenSCAD CANDIDATE for the user's already-printed
 * MakerWorld collector. Nothing is imported from the third-party model; only
 * the dimensions recorded in docs/overlay-fit.md are used.
 *
 * UNPRINTED CANDIDATE, NOT A PHYSICAL FIT. Cold, nonmetal dust only. Not
 * validated for sparks or metal dust. Airflow, hose fit, seal leakage and tool
 * clearance are untested. Intended for single-material PETG Translucent,
 * without the previous candidate's experimental PLA support interfaces.
 *
 * Select a part:  openscad -D 'part="print"' -o overlay-shroud.stl cad/overlay-shroud.scad
 *   print     the ONE printable solid, rotated rear-face-down on the bed (default)
 *   assembly  installed orientation (z=0 is the table), collector envelope as a
 *             `%` ghost. View only
 *   section   assembly cut at x=0 through the hose arch. View only
 *
 * ASSEMBLY FRAME (collector frame from docs/overlay-fit.md, z shifted to the
 * table): X width centred on the collector, Y depth (front opening toward -Y),
 * Z up, z=0 is the table AND the collector underside.
 *
 * HOW IT MOUNTS (the key decision):
 *  - It does NOT mount on the collector. The shroud is a free-standing tent
 *    that stands on the TABLE around the collector and is located only by
 *    friction/gravity. The collector's upper rim is non-level (sides 19.8,
 *    rear 39.8, rising corners, rounded exterior edge, 1.2 mm hollow cap).
 *    Nothing here touches, traces or loads that rim, and no lip enters the
 *    collector's tapered opening, so the suction slots stay uncovered.
 *  - Sealed interface = the flat bottom edges of the walls on the table
 *    (left, rear, right-low). A thin REMOVABLE compressible gasket tape on
 *    those edges is required but NOT modelled. The open underside is therefore
 *    closed by the table, not a third air opening. The 21.4 mm of front depth
 *    beyond the collector also uses the table as its floor, so no hidden
 *    bottom air gap exists.
 *  - Base pocket is 171.25 (front open) wide, 0.625 mm per side over the
 *    170 mm body. Above the collector it steps in on a 45 degree shoulder to
 *    the 155 mm clear width (>= the 151.2 mm collector opening).
 *  - Rear hose: the 39.8 mm stub (round top, flat base on the table, axis
 *    z=19.9) leaves the collector at Y 45..85 and MUST cross the rear wall.
 *    There is no way around that with the rear wall closed. Candidate: a
 *    closely fitted arch notch (41.0 wide, 0.6 mm per side) cut in the rear
 *    wall. It leaves a ~0.6 mm gap that is NOT sealed by geometry. EXTRA
 *    REQUIRED SEAL: wrap the stub with removable foam/EPDM tape (about 1.5 mm
 *    uncompressed) where it passes the arch and press the shroud onto it. A
 *    snug split seal would be a better revision. The inner face of the rear
 *    wall is at Y 48.6, which is past the stub blend (stub is a true 39.8 mm
 *    profile only from about Y 48).
 *  - Opposite-wall tool clearance was NOT investigated, by user directive.
 *
 * OPENINGS (only these, connected): the front plane (full height) and the
 * right face above z=75 up to the roof underside. Right wall below 75 stays
 * so the lower air is captured.
 *
 * PRINT: rear outer face on the bed. Every wall is then a plain extrusion
 * along the print Z axis, with no geometric overhangs; intended to print
 * without supports. The arch is a through-cut. This is not a print guarantee. Roof-down was rejected: the 75 mm right wall would start in
 * mid-air at its top edge and need a 160 mm unsupported bridge. Caveats: the
 * walls are 2 mm plates 160 mm tall and may wobble in the print; the 155 mm
 * roof is cantilevered from the left and rear walls, so a top-side rim along
 * the open right edge (printed, no support) stiffens it. Stiffness is
 * untested. The rim sits above the roof, outside the clear volume.
 *
 * Roof underside is 210 (>= 210 required, 200 highest hand), clear footprint
 * 155 x 155 above the shoulder, tool contact ~115 high / 125 behind the front
 * opening lies inside it.
 */

// ---------------------------------------------------------------- selector
part = "print"; // print | assembly | section

// ------------------------------------------------------ collector (from docs)
body_half_w = 85;     // collector body X -85..85
body_rear_y = 45;     // collector rear plane
rear_top = 39.8;      // highest collector point above the table
stub_r = 19.9;        // hose stub outer radius, axis z = stub_r, X = 0
stub_end_y = 85;      // hose mouth plane
stub_flat_y = 48;     // stub is a true cylinder/flat-base from about here

// ------------------------------------------------------- shroud dimensions
t = 2;                // wall thickness (left, rear, right)
roof_t = 3;           // roof plate
pocket_half_w = 85.625; // base pocket inner half width (171.25 total, 0.625/side)
clear_half_w = 77.5;  // inner half width above the shoulder (155 total)
clear_d = 155;        // clear depth, front opening to rear inner face
rear_in_y = 48.6;     // rear wall inner face (3.6 behind the body, past stub blend)
shoulder_z = 42;      // shoulder start: 2.2 above the highest collector point
side_open_z = 75;     // right wall top; the right opening starts here
roof_under_z = 210;   // roof underside
rim_h = 10;           // top-side stiffening rim on the open right roof edge
notch_clear = 0.6;    // hose arch clearance per side
$fn = 96;

// ---------------------------------------------------------------- derived
rear_out_y = rear_in_y + t;            // rear outer face, bed face when printed
front_y = rear_in_y - clear_d;         // front opening plane
roof_top_z = roof_under_z + roof_t;
out_half_w = pocket_half_w + t;        // outer half width of the base walls
up_out_half_w = clear_half_w + t;      // outer half width above the shoulder
shoulder_rise = pocket_half_w - clear_half_w; // 45 degree shoulder rise
// The outer shoulder line is the inner one offset t perpendicular.
out_z0 = shoulder_z - t + t * sqrt(2);               // outer line at the base wall
out_z1 = out_z0 + (out_half_w - up_out_half_w);      // outer line at the upper wall
notch_w = 2 * (stub_r + notch_clear);

assert(t >= 1.6 && t <= 3, "wall_t outside 1.6..3 mm");
assert(roof_t >= 2 && roof_t <= 4, "roof_t outside 2..4 mm");
assert(pocket_half_w * 2 >= 170 + 1, "pocket narrower than body plus clearance");
assert(clear_half_w * 2 == 155 && clear_d == 155, "clear footprint must stay 155 x 155");
assert(clear_half_w * 2 >= 151.2, "upper clear width below the collector opening");
assert(shoulder_z >= rear_top + 2, "shoulder must clear the highest collector point");
assert(rear_in_y >= stub_flat_y, "rear wall inside the stub blend zone");
assert(rear_in_y > body_rear_y, "rear wall inside the collector body");
assert(roof_under_z >= 210, "roof underside below 210");
assert(side_open_z > shoulder_z + shoulder_rise, "right opening starts below the shoulder");
assert(rear_out_y <= 256 && roof_top_z + rim_h <= 256, "exceeds the 256 mm bed");

// Extrude a 2D (x, z) profile along Y from y0 to y1.
module slab(y0, y1) {
    translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
}

// Left wall: straight base pocket, 45 degree shoulder, straight upper wall.
module left_wall() {
    slab(front_y, rear_out_y)
        polygon([
            [-out_half_w, 0], [-out_half_w, out_z0], [-up_out_half_w, out_z1],
            [-up_out_half_w, roof_top_z], [-clear_half_w, roof_top_z],
            [-clear_half_w, shoulder_z + shoulder_rise],
            [-pocket_half_w, shoulder_z], [-pocket_half_w, 0]]);
}

// Right wall: low, straight, free top edge at side_open_z.
module right_wall() {
    slab(front_y, rear_in_y) // butts the rear wall inner face, no coplanar overlap
        translate([pocket_half_w, 0]) square([t, side_open_z]);
}

// Rear wall: full profile, closed except the hose arch.
module rear_wall() {
    difference() {
        slab(rear_in_y, rear_out_y)
            polygon([
                [-out_half_w, 0], [out_half_w, 0], [out_half_w, side_open_z],
                [up_out_half_w, side_open_z], [up_out_half_w, roof_top_z],
                [-up_out_half_w, roof_top_z], [-up_out_half_w, out_z1],
                [-out_half_w, out_z0]]);
        // Arch open to the table: flat sides up to the axis, round above.
        translate([0, rear_in_y - 1, 0]) rotate([-90, 0, 0])
            linear_extrude(t + 2) hose_arch();
    }
}

module hose_arch() {
    // 2D in (x, -z) after the rotate above, so mirror z here.
    mirror([0, 1]) union() {
        translate([-notch_w / 2, -1]) square([notch_w, stub_r + 1]);
        translate([0, stub_r]) circle(d = notch_w);
    }
}

// Roof plate plus the top-side stiffening rim on the open right edge.
module roof() {
    slab(front_y, rear_out_y) {
        translate([-up_out_half_w, roof_under_z]) square([2 * up_out_half_w, roof_t]);
        translate([clear_half_w, roof_top_z - 0.01]) square([t, rim_h + 0.01]);
    }
}

module shroud() {
    union() {
        left_wall();
        right_wall();
        rear_wall();
        roof();
    }
}

// Conservative collector envelope, view only (never exported).
module collector_ghost() {
    translate([-body_half_w, -85, 0]) cube([2 * body_half_w, body_rear_y + 85, rear_top]);
    translate([-stub_r, body_rear_y, 0])
        cube([2 * stub_r, stub_end_y - body_rear_y, stub_r]);
    translate([0, body_rear_y, stub_r]) rotate([-90, 0, 0])
        cylinder(r = stub_r, h = stub_end_y - body_rear_y);
}

// Rear face on the bed: x'=x, y'=z, z'=rear_out_y-y (a proper rotation).
module print_orient() {
    multmatrix([[1, 0, 0, 0], [0, 0, 1, 0], [0, -1, 0, rear_out_y], [0, 0, 0, 1]])
        children();
}

if (part == "print") {
    print_orient() shroud();
} else if (part == "assembly") {
    shroud();
    %collector_ghost();
} else if (part == "section") {
    difference() {
        shroud();
        translate([0, -300, -1]) cube([300, 600, 400]);
    }
    %intersection() {
        collector_ghost();
        translate([-300, -300, -1]) cube([300, 600, 400]);
    }
} else {
    assert(false, str("unknown part '", part, "'"));
}
