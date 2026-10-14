/*
 * Compact open-front dust hood -- ORIGINAL monolithic OpenSCAD design.
 *
 * UNPRINTED PROTOTYPE. Cold, nonmetal dust only. NOT validated for metal
 * sharpening, hot sparks, or mixed metal/combustible dust. Airflow, hose fit,
 * and tool clearance are untested.
 *
 * Replaces the printed MakerWorld collector with geometry designed from scratch
 * for this repo. Nothing is imported from the third-party model. Only the
 * functional hose socket dimensions are reproduced (docs/source-and-status.md),
 * the same independently reconstructed socket as cad/dust-hood.scad.
 *
 * Select a part:  openscad -D 'part="hood"' -o compact-hood.stl cad/compact-hood.scad
 *   hood      the ONE printable solid (default, the only exportable part)
 *   section   hood cut at the centre plane, for viewing only
 *   reference tool/contact envelopes plus a ghost of the hood, viewing only
 *
 * Frame: X = width, Y = depth (front OPEN at y=0, rear wall at y=155), Z up.
 * z=0 is the supporting TABLE and the print bed (the floor underside). All
 * user dimensions are table-referenced. The 2 mm floor raises anything resting
 * on it, so heights measured from the floor TOP are 2 mm lower than listed.
 *
 * Design assumptions (user brief, not measured):
 *  - interior footprint 155 x 155 mm clear (X by Y), nothing inside it but floor
 *  - motor extends out the open front at y=0
 *  - tool contact point is 115 mm above the table, 125 mm behind the front
 *  - highest tools/hands reach 200 mm above the table
 *  - long knives/pliers/snips sweep in through the broad side openings, which
 *    run from the front to the rear wall between the low side walls (top 57)
 *    and the canopy. They are NOT holes.
 *  - the rear wall rises to 212 and carries a canopy sloping up 45 degrees forward, whose underside
 *    (210) stays above the 200 mm operating height.
 *
 * Printability (floor down, removable slicer supports required for overhangs):
 *  - every wall is vertical; side and rear walls are plain extrusions
 *  - rear wall is stiffened by four vertical outside ribs (plain plates)
 *  - the socket sits on a 45 degree skirt that flares to the bed, so its lower
 *    flanks never overhang more than 45 degrees. No sacrificial supports are
 *    modelled
 *  - the 32.10 mm bore roof still bridges horizontally; review in the slicer.
 *  - the canopy slopes 45 degrees up toward the front (underside 210 -> 225,
 *    top 227), so it self-supports. Overall height 227.
 *    The candidate slicer setup uses PETG bases with PLA interfaces. Removal,
 *    interface quality and hose fit remain untested; do not print unsupported.
 */

// ---------------------------------------------------------------- selector
part = "hood"; // hood | section | reference

// ------------------------------------------------------- design dimensions
// Named for readability. Not freely adjustable: assertions below pin the
// supported envelope and the socket values. Changing one means reviewing all.
clear_w = 155;       // clear interior width (X)
clear_d = 155;       // clear interior depth (Y), front y=0 open
floor_t = 2;         // flat floor, z 0..2
wall_t = 2;          // side, rear and canopy thickness
side_top = 57;       // low side wall top, table-referenced (55 above floor top)
rear_h = 212;        // rear wall top, table-referenced
canopy_proj = 15;    // canopy projection forward of the rear wall inner face
canopy_t = 2;        // canopy thickness; underside = rear_h - canopy_t = 210
rib_t = 2;           // rear stiffening rib thickness
rib_d = 12;          // rib depth behind the rear wall outer face
rib_dx = [-77.5, -45, 45, 77.5]; // rib centres relative to the centre plane

contact_z = 115;     // tool contact height above the table
contact_y = 125;     // tool contact distance behind the front
tool_max_z = 200;    // highest tool/hand height above the table
canopy_under_min = 210;

// ----------------------------------------------------- hose socket (exact)
socket_d = 32.10;     // bore, straight
socket_straight = 39; // straight engagement
mouth_r = 1;          // 1 mm INTERNAL ROUND (not a chamfer)
socket_od = 39.80;
mouth_d = socket_d + 2 * mouth_r;          // 34.10
socket_depth = socket_straight + mouth_r;  // 40, mouth to shoulder
// Throat: insertion shoulder and air hole through the rear wall.
// RESTRICTION: 25 mm is ~61% of the bore area. Airflow effect is unvalidated.
exit_d = 25;
shoulder_t = 4;       // solid shoulder behind the bore, as the previous adapter
socket_z = 30;        // axis height: low on the rear wall, well below the belt
skirt_half = 30;      // half width of the skirt where it meets the bed

// ---------------------------------------------------------- derived values
outer_w = clear_w + 2 * wall_t;    // 159
rear_in = clear_d;                 // rear wall inner face, y=155
rear_out = clear_d + wall_t;       // rear wall outer face, y=157
socket_end = rear_in + shoulder_t + socket_depth; // 199
canopy_under = rear_h - canopy_t;  // 210, underside at the rear wall
canopy_top = canopy_under + canopy_proj + canopy_t; // 227 at the front edge
top_z = canopy_top;                // overall height, bed Z fit
cx = clear_w / 2;                  // centre plane of the interior

// ------------------------------------------------------------- assertions
assert(is_string(part) && (part == "hood" || part == "section" || part == "reference"),
       "part must be one of hood, section, reference");
assert(clear_w == 155 && clear_d == 155, "clear footprint must be 155 x 155");
assert(floor_t >= 1.6 && floor_t <= 2.4, "floor_t must be 1.6..2.4");
assert(wall_t >= 1.6 && wall_t <= 2.4, "wall_t must be 1.6..2.4");
assert(side_top - floor_t <= 55, "side walls must be <= 55 above the floor top");
assert(side_top > floor_t + 10, "side walls must stand at least 10 above the floor");
assert(rear_h >= 210 && rear_h <= 215, "rear wall height must be 210..215");
assert(canopy_under >= canopy_under_min, "canopy underside must be >= 210");
assert(canopy_under > tool_max_z, "canopy must clear the 200 mm tool height");
assert(canopy_proj == 15, "canopy slope is pinned: 15 mm run, 45 degrees");
assert(top_z <= 256, "overall height must fit the 256 mm bed Z");
assert(contact_z > side_top && contact_z < tool_max_z,
       "contact point must sit in the open side-access band");
assert(contact_y > 0 && contact_y < clear_d, "contact point must be inside the footprint");
assert(abs(mouth_d - 34.10) < 1e-6 && abs(socket_depth - 40) < 1e-6,
       "hose socket must match documented 34.10 mouth / 40 mm depth");
assert(abs(socket_od - 39.80) < 1e-6 && abs(socket_d - 32.10) < 1e-6,
       "hose OD/bore must match documented values");
assert(exit_d == 25 && exit_d < socket_d, "throat must leave a 25 mm hose stop shoulder");
assert(shoulder_t >= wall_t, "shoulder must cover the rear wall");
assert(socket_z - socket_od / 2 >= 0 && socket_z < contact_z,
       "socket must sit on the bed and below the belt");
assert(socket_end <= 256 - 20 && rear_out + rib_d <= socket_end,
       "depth must fit the 256 mm bed");
assert(outer_w <= 256, "width must fit the 256 mm bed");

// ------------------------------------------------------------------ socket
// Local frame: socket axis along +Z starting at the bore floor (shoulder).
module socket_cut() {
    rb = socket_d / 2;
    arc = [for (a = [180 : -15 : 90])
              [rb + mouth_r + mouth_r * cos(a), socket_depth - mouth_r + mouth_r * sin(a)]];
    rotate_extrude($fn = 90) polygon(concat(
        [[0, -0.01], [rb, -0.01]], arc,
        [[rb + mouth_r, socket_depth + 0.01], [0, socket_depth + 0.01]]));
}

// Socket body in XZ profile extruded along +Y, from the rear wall inner face to
// the mouth. The skirt flares at 45 degrees from the cylinder tangent points to
// the bed so the lower flanks print without supports. It is the plain mounting
// transition: no screws, no flange.
module socket_body() {
    r = socket_od / 2;
    tx = r * sin(45);                // tangent point x at 45 degrees
    tz = socket_z - r * cos(45);
    assert(abs((tx + tz) - skirt_half) < 0.01, "skirt must flare at 45 degrees to the bed");
    // rotate([90,0,0]) maps (x,y,z) -> (x,-z,y): profile y is world Z and the
    // extrusion runs from the mouth plane back toward the rear wall.
    translate([cx, socket_end, 0]) rotate([90, 0, 0])
        linear_extrude(socket_end - rear_in) union() {
            translate([0, socket_z]) circle(d = socket_od, $fn = 90);
            polygon([[-skirt_half, 0], [skirt_half, 0], [tx, tz], [-tx, tz]]);
        }
}

// ------------------------------------------------------------------- hood
module solid_body() {
    // floor
    translate([-wall_t, 0, 0]) cube([outer_w, rear_out, floor_t]);
    // low side walls, front to rear wall
    for (x = [-wall_t, clear_w])
        translate([x, 0, 0]) cube([wall_t, rear_out, side_top]);
    // rear wall, full height
    translate([-wall_t, rear_in, 0]) cube([outer_w, wall_t, rear_h]);
    // canopy: 2 mm vertical-thickness plate sloping UP 45 degrees toward the
    // front so it self-supports (no flat underside, no supports or tower above
    // the socket). Underside runs z=210 at the rear wall to 225 at y=140; the
    // top is 2 mm higher (227 at the front). Nothing hangs below 210.
    // rotate([90,0,90]) maps profile (x,y,z) -> world (z,x,y): profile x is Y,
    // profile y is Z, extrusion is X.
    translate([-wall_t, 0, 0]) rotate([90, 0, 90]) linear_extrude(outer_w)
        polygon([[rear_out, canopy_under], [rear_in, canopy_under],
                 [rear_in - canopy_proj, canopy_under + canopy_proj],
                 [rear_in - canopy_proj, canopy_top],
                 [rear_in, rear_h], [rear_out, rear_h]]);
    // vertical stiffening ribs behind the rear wall (plain plates)
    for (dx = rib_dx)
        translate([cx + dx - rib_t / 2, rear_out, 0]) cube([rib_t, rib_d, rear_h]);
    socket_body();
}

module hood() {
    difference() {
        solid_body();
        // bore: plain horizontal hole from the mouth back to the shoulder
        translate([cx, rear_in + shoulder_t, socket_z]) rotate([-90, 0, 0]) socket_cut();
        // throat through shoulder and rear wall, open to the interior
        translate([cx, rear_in - 0.01, socket_z]) rotate([-90, 0, 0])
            cylinder(d = exit_d, h = shoulder_t + 0.02, $fn = 72);
    }
}

// ------------------------------------------------------ preview envelopes
// Viewing only, never exported as a part.
module reference() {
    %hood();
    // 155 x 155 clear column up to the highest tool height
    color("blue", 0.2) translate([0, 0, floor_t]) cube([clear_w, clear_d, tool_max_z - floor_t]);
    // contact point marker, 115 above the table, 125 behind the front
    color("red") translate([cx, contact_y, contact_z]) sphere(r = 3, $fn = 24);
    // motor/tool body leaving through the open front
    color("green", 0.4) translate([cx - 30, -120, contact_z - 30]) cube([60, 120 + contact_y, 60]);
}

module section() {
    difference() {
        hood();
        translate([cx, -1, -1]) cube([clear_w, rear_out + rib_d + 60, top_z + 2]);
    }
}

if (part == "hood") hood();
else if (part == "section") section();
else reference();
