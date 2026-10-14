/*
 * Mind Palace Dust Hood -- original parametric OpenSCAD prototype.
 *
 * UNPRINTED PROTOTYPE. Cold, nonmetal dust only. NOT validated for metal
 * sharpening, hot sparks or mixed metal/combustible dust. User tests required.
 * Do not publish to MakerWorld until printed and tested (see README.md).
 *
 * Original geometry only. Nothing is imported from the third-party model; the
 * hose socket reproduces only the functional measured dimensions documented in
 * docs/source-and-status.md.
 *
 * Select a part:  openscad -D 'part="tub"' -o tub.stl cad/dust-hood.scad
 *
 * Axes (assembly): X = width (246), Y = depth (240, front at y=0, rear at
 * y=240), Z = height (240, floor at z=0).
 *
 * Construction in one paragraph: a 3 mm tub (floor, two side walls, rear wall,
 * open front, open top) takes a separate 3 mm roof. Five 2 mm liners (floor,
 * rear, 2x side, roof) float 10 mm inside the shell. The 10 mm gaps behind the
 * liners are one connected air volume that ends at the rear wall hose hole. The
 * liners are plain slotted plates, slid in through the open front and screwed
 * (M3x8) onto sparse nut posts that stand on the shell. A U-shaped front frame
 * on the tub plus a skirt on the roof close the front of the chambers.
 */

// ---------------------------------------------------------------- selector
// tub roof floor_liner rear_liner side_liner roof_liner adapter fit_coupon
// joint_coupon assembly exploded section
part = "assembly";

// Optional tool reference (229x127x127). Drawn ONLY in assembly/exploded/
// section, as a non-rendering `%` background body. Never part of an export of
// a single part, and not evidence that any tool fits.
show_tool = false;

explode = 70;    // [mm] exploded-view travel
section_x = 123; // [mm] section keeps x < section_x

// ------------------------------------------------------------- enclosure
W = 246;          // exterior width  (X)
D = 240;          // exterior depth  (Y)
H = 240;          // exterior height (Z), tub + roof
wall = 3;         // tub shell thickness
roof_t = 3;       // roof plate thickness
liner_t = 2;      // liner thickness
chamber = 10;     // nominal internal air chamber (shell inner face -> liner)
liner_gap = 0.2;  // clearance between neighbouring liners
frame_t = 4;      // front frame / roof skirt depth (Y)
frame_clr = 0.3;  // slide clearance between frame opening and liner envelope
post_gap = 0.3;   // slide clearance between post tip and liner
bed = 256;        // printer bed edge
bed_margin = 5;   // keep-out per side

// ----------------------------------------------------------------- slots
slot_w = 6;       // rounded slot width
slot_len = 20;    // rounded slot overall length
edge_min = 6;     // minimum plate edge to slot/hole edge

// ------------------------------------------------------------- fasteners
// M3 pan head. Only two lengths: M3x8 (liners, roof), M3x16 (adapter).
screw_liner_len = 8;
screw_adapter_len = 16;
screw_clear = 3.4;               // clearance hole
nut_af = 5.5;                    // M3 nut across flats
nut_th = 2.4;                    // M3 nut thickness
nut_clr = 0.3;                   // pocket clearance on flats / depth
post_d = 10;                     // nut post diameter
cap = 1.0;                       // plastic that keeps the nut in the pocket
screw_hole_depth_below_nut = 2.2;// blind hole under the pocket for the tip
screw_ys = [40, 100];            // liner/post rows (Y), near the front
screw_dx = 70;                   // lateral post offset from centre line
rear_dx = 88;                    // rear liner post offsets
rear_dz = 80;
roof_screw_ys = [30, 120, 205];  // roof screws into each side wall boss
roof_screw_rear_xs = [60, 186];  // roof screws into rear wall bosses
boss_u = 10;                     // roof boss depth from the wall
boss_v = 10;                     // roof boss width along the wall
boss_hole_u = 5.5;               // screw axis distance from the wall

// ------------------------------------------------------------ hose adapter
// Mating specs from docs/source-and-status.md (functional dimensions only).
// These are the NOMINAL source values with NO printer/material compensation.
// Any fit adjustment is a deliberate design revision: change the values AND the
// socket assertions below together, after the fit coupon says so.
socket_d = 32.10;     // bore, straight
socket_straight = 39; // straight engagement
mouth_r = 1;          // 1 mm INTERNAL FILLET (not a chamfer)
socket_od = 39.80;    // cylindrical exterior
mouth_d = socket_d + 2 * mouth_r;     // 34.10
socket_depth = socket_straight + mouth_r; // 40 mouth -> shoulder
// Throat (source radius 12.5 at the shoulder): insertion stop and the air hole
// through the shoulder plate and rear wall. RESTRICTION: 25 mm is ~61% of the
// 32.10 bore area. Its airflow effect is unvalidated.
exit_d = 25;
flange_d = 66;
flange_t = 4;
flange_bc_r = 29;     // bolt circle radius, bolts at 45 deg
adapter_post_gap = 0.5;
tape_r_in = 22;       // flange tape land (recess ring), 4 mm wide
tape_r_out = 26;
tape_depth = 0.6;

// --------------------------------------------------------- tool reference
tool_l = 229; tool_w = 127; tool_h = 127; // long axis along Y (open front)

// ---------------------------------------------------------- coupons
fit_depth = 14;       // fit coupon: shortened socket, same profile
$fn = 24;

// ---------------------------------------------------------- derived values
cx = W / 2;
tub_h = H - roof_t;                 // 237, top rim of the tub
in_y1 = D - wall;                   // rear wall inner face (237)
cz_air = H / 2;                     // hose axis height (120)
env_x0 = wall + chamber;            // liner envelope (outer faces of liners)
env_x1 = W - wall - chamber;
env_z0 = wall + chamber;
env_z1 = tub_h - chamber;
rl_y1 = in_y1 - chamber;            // rear liner back face (227)
rl_y0 = rl_y1 - liner_t;            // rear liner front face (225)
liner_y0 = 1;                       // liners start 1 mm behind the front face
liner_y1 = rl_y0 - liner_gap;
lx0 = env_x0 + liner_t + liner_gap; // floor/roof/rear plate x origin
lz0 = env_z0 + liner_t + liner_gap; // rear plate z origin
plate_w = (env_x1 - env_x0) - 2 * (liner_t + liner_gap);
plate_l = liner_y1 - liner_y0;
side_h = env_z1 - env_z0;
rear_h = side_h - 2 * (liner_t + liner_gap);
liner_post_h = chamber - post_gap;
adapter_post_h = chamber - adapter_post_gap;
nut_pocket_h = nut_th + nut_clr;
nut_pocket_af = nut_af + nut_clr;
nut_pocket_d = nut_pocket_af / cos(30);
bc45 = flange_bc_r * cos(45);

// ----------------------------------------------------------- assertions
// SUPPORTED ENVELOPE. Slot rows, screw rows, roof screw positions, tabs and the
// hose/adapter layout are hardcoded numbers tuned for the nominal 246x240x240
// shell. Only these are supported: W 241..246, D 235..246 (bed margin caps W and
// D at 246), H 235..245, wall/roof 2..4, liner 1.6..2.4, chamber 8..12. Anything
// else needs a deliberate review of every position list, not just a new value.
assert(W >= 241 && W <= 246 && D >= 235 && D <= 246 && H >= 235 && H <= 245,
       "W/D/H outside the supported envelope (hardcoded layout)");
assert(wall >= 2 && wall <= 4 && roof_t >= 2 && roof_t <= 4,
       "wall/roof thickness outside 2..4 mm");
assert(liner_t >= 1.6 && liner_t <= 2.4, "liner thickness outside 1.6..2.4 mm");
assert(chamber >= 8 && chamber <= 12, "chamber outside 8..12 mm");
assert(liner_gap > 0 && post_gap > 0 && frame_clr > 0 && adapter_post_gap > 0,
       "clearances must be positive");
assert(frame_t >= 3, "front frame depth must be >= 3 mm");
assert(post_d - nut_pocket_d >= 2, "post wall around nut pocket < 1 mm");
// Fastener stacks (measured from the part face the screw head sits on).
assert(liner_post_h >= cap + nut_pocket_h + screw_hole_depth_below_nut,
       "liner post too short for cap + nut pocket + screw hole");
assert(screw_liner_len >= liner_t + post_gap + cap + nut_th + 0.5 &&
       screw_liner_len <= liner_t + post_gap + cap + nut_pocket_h + screw_hole_depth_below_nut,
       "M3 liner screw must pass the nut and stay inside the post");
assert(screw_liner_len >= roof_t + cap + nut_th + 0.5 &&
       screw_liner_len <= roof_t + cap + nut_pocket_h + screw_hole_depth_below_nut,
       "M3 roof screw must pass the nut and stay inside the boss");
// Adapter: flange + wall + nut start = 12.8, nut ends at 15.2 (pocket 15.5),
// post tip at 16.5. M3x16 leaves 0.5 mm past the pocket-top nut; any gasket
// projecting past the flange tape recess eats into that margin.
assert(screw_adapter_len >= flange_t + wall + (adapter_post_h - cap - nut_pocket_h) + nut_th + 0.5 &&
       screw_adapter_len <= flange_t + wall + adapter_post_h,
       "M3 adapter screw must pass the nut and stay inside the post");
assert(W <= bed - 2 * bed_margin && D <= bed - 2 * bed_margin,
       "tub/roof footprint must fit the bed with margins");
assert(abs(mouth_d - 34.10) < 1e-6 && abs(socket_depth - 40) < 1e-6,
       "hose socket must match documented 34.10 mouth / 40 mm depth");
assert(abs(socket_od - 39.80) < 1e-6 && abs(socket_d - 32.10) < 1e-6,
       "hose OD/bore must match documented values");
assert((socket_od - mouth_d) / 2 >= 2, "socket wall too thin at mouth");
assert(exit_d < socket_d, "exit hole must leave a hose stop shoulder");
assert(flange_bc_r - post_d / 2 > exit_d / 2, "adapter posts hit exit hole");
assert(flange_d / 2 > flange_bc_r + screw_clear / 2 + 2, "flange too small");
assert(tape_r_out + 1 < flange_bc_r - screw_clear / 2, "tape ring hits bolts");
assert(tape_r_in > exit_d / 2 + 1, "tape ring inside exit hole");
assert(tool_w < plate_w && tool_h < side_h - 2 * liner_t,
       "tool reference must clear the liners (reference only)");
assert(rear_dx + post_d / 2 < plate_w / 2 - edge_min, "rear post too close to edge");
// Bolt circle posts must not touch rear-liner posts or each other.
assert(bc45 + post_d / 2 < rear_dx - post_d / 2, "adapter posts hit rear posts");

// ------------------------------------------------------------------ 2D bits
// Rounded slot, long axis along local X (ang=0) or Y (ang=90).
module slot2d(ang = 0) {
    rotate(ang) hull()
        for (s = [-1, 1])
            translate([s * (slot_len - slot_w) / 2, 0])
                circle(d = slot_w, $fn = 16);
}

// Flat 2 mm plate (u across, v along). holes: [[u,v],..]; slots: [[u,v],..]
module plate(w, l, t, holes, slots, ang) {
    hu = (ang == 0 ? slot_len : slot_w) / 2;
    hv = (ang == 0 ? slot_w : slot_len) / 2;
    for (s = slots)
        assert(s[0] - hu >= edge_min && s[0] + hu <= w - edge_min &&
               s[1] - hv >= edge_min && s[1] + hv <= l - edge_min,
               "slot too close to plate edge");
    for (h = holes)
        assert(h[0] >= edge_min && h[0] <= w - edge_min &&
               h[1] >= edge_min && h[1] <= l - edge_min, "hole off plate");
    linear_extrude(t) difference() {
        square([w, l]);
        for (h = holes) translate(h) circle(d = screw_clear);
        for (s = slots) translate(s) slot2d(ang);
    }
}

// ---------------------------------------------------------- hole/slot sets
// Global post positions (single source of truth for posts AND liner holes).
floor_pts = [for (sx = [-1, 1]) for (y = screw_ys) [cx + sx * screw_dx, y]];
side_pts  = [for (y = screw_ys) for (sz = [-1, 1])
                [y, cz_air + sz * screw_dx]];           // (y, z)
rear_pts  = [for (sx = [-1, 1]) for (sz = [-1, 1])
                [cx + sx * rear_dx, cz_air + sz * rear_dz]]; // (x, z)
adapter_pts = [for (sx = [-1, 1]) for (sz = [-1, 1])
                [cx + sx * bc45, cz_air + sz * bc45]];  // (x, z)

// Plate-local hole lists
floor_holes = [for (p = floor_pts) [p[0] - lx0, p[1] - liner_y0]];
side_holes  = [for (p = side_pts) [p[0] - liner_y0, p[1] - env_z0]];
rear_holes  = [for (p = rear_pts) [p[0] - lx0, p[1] - lz0]];

// Slots: 4 floor, 4 rear, 3 per side, 2 roof. All >= 120 mm from the front.
floor_slots = [for (dx = [-60, -20, 20, 60]) [cx + dx - lx0, 170 - liner_y0]];
roof_slots  = [for (dx = [-30, 30]) [cx + dx - lx0, 170 - liner_y0]];
side_slots  = [for (y = [130, 165, 200]) [y - liner_y0, cz_air - env_z0]];
rear_slots  = [for (dx = [-62, -40, 40, 62]) [cx + dx - lx0, cz_air - lz0]];

// ----------------------------------------------------------------- liners
// Local plates (flat, z = 0..2). These ARE the print orientation.
module floor_liner_flat() plate(plate_w, plate_l, liner_t, floor_holes, floor_slots, 90);
module roof_liner_flat()  plate(plate_w, plate_l, liner_t, floor_holes, roof_slots, 90);
module side_liner_flat()  plate(plate_l, side_h, liner_t, side_holes, side_slots, 0);
module rear_liner_flat()  plate(plate_w, rear_h, liner_t, rear_holes, rear_slots, 90);

// Axis mapping matrices (local -> assembly), all right handed.
M_left  = [[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]]; // x->Y y->Z z->+X
M_right = [[0,0,-1,0],[-1,0,0,0],[0,1,0,0],[0,0,0,1]]; // x->-Y y->Z z->-X
M_rear  = [[1,0,0,0],[0,0,-1,0],[0,1,0,0],[0,0,0,1]]; // x->X y->Z z->-Y

module floor_liner_asm() translate([lx0, liner_y0, env_z0]) floor_liner_flat();
module roof_liner_asm()  translate([lx0, liner_y0, env_z1 - liner_t]) roof_liner_flat();
module side_liner_left_asm()
    translate([env_x0, liner_y0, env_z0]) multmatrix(M_left) side_liner_flat();
// Right liner = the SAME part turned 180 deg about the Y axis (pattern is
// symmetric about the mid-height), so one print file serves both sides.
module side_liner_right_asm()
    translate([cx, 0, cz_air]) rotate([0, 180, 0])
        translate([-cx, 0, -cz_air]) side_liner_left_asm();
module rear_liner_asm()  translate([lx0, rl_y1, lz0]) multmatrix(M_rear) rear_liner_flat();

// ------------------------------------------------------------- nut posts
// Post along local +Z (base z=0, tip z=h). Nut pocket sits `cap` below the tip
// with a side slot toward local +X, so the nut cannot fall out of the tip and
// is loaded sideways. Screw hole is blind (tip stays inside the post) unless
// hole_from < 0 (adapter, where the screw arrives from the wall side).
// tear=true is for a post that points sideways in the tub (local -Y = down in
// the print). A teardrop section alone still starts a one-ended cantilever, so
// a 45 degree underside gusset (post_gusset) joins its lowest edge back to the
// shell.
gusset_w = 3;
module post_gusset(h) {
    // Triangle in (z, y): 45 degree hypotenuse from the shell (z = -0.5, buried
    // in the wall) up to the post flank. Top face sits inside the teardrop
    // (|y| < apex) and stops 1 mm short of the post tip, so no face is
    // coplanar with a post face.
    ytop = -4.5;
    g = h - 1;
    translate([-gusset_w / 2, 0, 0])
        multmatrix([[0,0,1,0],[0,1,0,0],[1,0,0,0],[0,0,0,1]])
            linear_extrude(gusset_w)
                polygon([[-0.5, ytop - g - 0.5], [-0.5, ytop], [g, ytop]]);
}
module nut_post(h, hole_from = 1.5, tear = false) {
    r = post_d / 2;
    difference() {
        union() {
          linear_extrude(h) union() {
            circle(d = post_d);
            // Teardrop apex: triangle tangent to the circle at 45 degrees
            // (circle has $fn=24, so vertices exist at +/-45 deg below axis).
            if (tear) polygon([[-r * cos(45), -r * sin(45)], [0, -r * sqrt(2)],
                               [r * cos(45), -r * sin(45)], [0, 0]]);
          }
          if (tear) post_gusset(h);
        }
        translate([0, 0, hole_from]) cylinder(d = screw_clear, h = h);
        translate([0, 0, h - cap - nut_pocket_h]) {
            cylinder(d = nut_pocket_d, h = nut_pocket_h, $fn = 6);
            translate([0, -nut_pocket_af / 2, 0])
                cube([post_d, nut_pocket_af, nut_pocket_h]);
        }
    }
}

// Roof boss: wedge off a wall (45 deg underside, no support). Local frame:
// u = away from wall, v = along wall, z = absolute. Slot opens toward +v.
module roof_boss() {
    z_nut = tub_h - cap - nut_pocket_h;
    difference() {
        hull() {
            translate([0, -boss_v / 2, tub_h - 3]) cube([boss_u, boss_v, 3]);
            translate([0, -boss_v / 2, tub_h - 3 - boss_u + 0.5]) cube([0.5, boss_v, 0.5]);
        }
        translate([boss_hole_u, 0, z_nut - screw_hole_depth_below_nut])
            cylinder(d = screw_clear, h = tub_h);
        translate([boss_hole_u, 0, z_nut]) rotate(90) {
            cylinder(d = nut_pocket_d, h = nut_pocket_h, $fn = 6);
            translate([0, -nut_pocket_af / 2, 0])
                cube([boss_v, nut_pocket_af, nut_pocket_h]);
        }
    }
}

// Roof screw centres (global x,y) -- shared by roof holes and tub bosses.
roof_screws = concat(
    [for (y = roof_screw_ys) [wall + boss_hole_u, y]],
    [for (y = roof_screw_ys) [W - wall - boss_hole_u, y]],
    [for (x = roof_screw_rear_xs) [x, in_y1 - boss_hole_u]]);

// ------------------------------------------------------------------- tub
module tub() {
    difference() {
        union() {
            // Shell: floor, side walls, rear wall. Open front and top.
            difference() {
                cube([W, D, tub_h]);
                translate([wall, -1, wall]) cube([W - 2 * wall, D - wall + 1, tub_h]);
            }
            // U frame: closes the front of the floor and side chambers.
            // Open at the top; the roof skirt closes the roof chamber.
            difference() {
                translate([wall, 0, wall]) cube([W - 2 * wall, frame_t, tub_h - wall]);
                translate([env_x0 - frame_clr, -1, env_z0 - frame_clr])
                    cube([env_x1 - env_x0 + 2 * frame_clr, frame_t + 2, tub_h]);
            }
            // Liner posts: floor (+Z), side walls (+/-X), rear wall (-Y).
            for (p = floor_pts) translate([p[0], p[1], wall]) nut_post(liner_post_h);
            for (p = side_pts) {
                translate([wall, p[0], p[1]]) multmatrix(M_left)
                    nut_post(liner_post_h, tear = true);
                translate([W - wall, p[0], p[1]]) multmatrix(M_right)
                    nut_post(liner_post_h, tear = true);
            }
            for (p = rear_pts) translate([p[0], in_y1, p[1]]) multmatrix(M_rear)
                nut_post(liner_post_h, tear = true);
            // Adapter posts, nut near the tip, screws arrive from outside.
            for (p = adapter_pts) translate([p[0], in_y1, p[1]]) multmatrix(M_rear)
                nut_post(adapter_post_h, hole_from = -0.01, tear = true);
            // Roof bosses.
            for (y = roof_screw_ys) {
                translate([wall, y, 0]) roof_boss();
                translate([W - wall, y, 0]) mirror([1, 0, 0]) roof_boss();
            }
            for (x = roof_screw_rear_xs)
                translate([x, in_y1, 0]) rotate(-90) roof_boss();
        }
        // Rear wall: air hole and adapter screw holes.
        translate([cx, in_y1 - 0.01, cz_air]) rotate([-90, 0, 0])
            cylinder(d = exit_d, h = wall + 1);
        for (p = adapter_pts) translate([p[0], in_y1 - 0.01, p[1]]) rotate([-90, 0, 0])
            cylinder(d = screw_clear, h = wall + 1);
    }
}

// ------------------------------------------------------------------ roof
module roof() {
    difference() {
        union() {
            translate([0, 0, tub_h]) cube([W, D, roof_t]);
            // Skirt: closes the roof chamber at the front, between frame bars.
            translate([env_x0 - frame_clr + 0.2, 0, env_z1 + frame_clr])
                cube([env_x1 - env_x0 + 2 * frame_clr - 0.4, frame_t,
                      tub_h - env_z1 - frame_clr]);
            // Roof liner posts hang from the underside.
            for (p = floor_pts) translate([p[0], p[1], tub_h]) rotate([180, 0, 0])
                nut_post(liner_post_h);
            // Locating tabs along the walls (sparse, 16 mm long, 3 mm deep).
            for (y = [75, 165]) {
                translate([wall + 0.2, y - 8, tub_h - 3]) cube([2, 16, 3]);
                translate([W - wall - 0.2 - 2, y - 8, tub_h - 3]) cube([2, 16, 3]);
            }
            for (x = [40, 206])
                translate([x - 8, in_y1 - 0.2 - 2, tub_h - 3]) cube([16, 2, 3]);
        }
        for (p = roof_screws) translate([p[0], p[1], tub_h - 1])
            cylinder(d = screw_clear, h = roof_t + 2);
    }
}

// --------------------------------------------------------------- adapter
// Local frame = print orientation: flange face (against the rear wall) on z=0.
module socket_cut() {
    rb = socket_d / 2;
    arc = [for (a = [180 : -15 : 90])
              [rb + mouth_r + mouth_r * cos(a), socket_depth - mouth_r + mouth_r * sin(a)]];
    rotate_extrude($fn = 90) polygon(concat(
        [[0, -0.01], [rb, -0.01]], arc,
        [[rb + mouth_r, socket_depth + 0.01], [0, socket_depth + 0.01]]));
}

module adapter() {
    difference() {
        union() {
            cylinder(d = flange_d, h = flange_t, $fn = 90);
            cylinder(d = socket_od, h = flange_t + socket_depth, $fn = 90);
        }
        translate([0, 0, flange_t]) socket_cut();
        translate([0, 0, -1]) cylinder(d = exit_d, h = flange_t + 1.01, $fn = 72);
        for (a = [45, 135, 225, 315])
            rotate(a) translate([flange_bc_r, 0, -1]) cylinder(d = screw_clear, h = flange_t + 2);
        // Gasket tape land: recessed ring on the wall-facing face.
        translate([0, 0, -0.01]) linear_extrude(tape_depth + 0.01) difference() {
            circle(r = tape_r_out, $fn = 90);
            circle(r = tape_r_in, $fn = 90);
        }
    }
}

// Adapter placed on the rear wall: local z -> +Y, local y -> -Z.
M_adapter = [[1,0,0,0],[0,0,1,0],[0,-1,0,0],[0,0,0,1]];
module adapter_asm() translate([cx, D, cz_air]) multmatrix(M_adapter) adapter();

// --------------------------------------------------------------- coupons
// Hose fit coupon: same bore/mouth profile, shortened, with a stop ledge.
module fit_coupon() {
    difference() {
        cylinder(d = socket_od, h = 3 + fit_depth, $fn = 90);
        translate([0, 0, 3]) {
            rb = socket_d / 2;
            arc = [for (a = [180 : -15 : 90])
                      [rb + mouth_r + mouth_r * cos(a), fit_depth - mouth_r + mouth_r * sin(a)]];
            rotate_extrude($fn = 90) polygon(concat(
                [[0, -0.01], [rb, -0.01]], arc,
                [[rb + mouth_r, fit_depth + 0.01], [0, fit_depth + 0.01]]));
        }
        translate([0, 0, -1]) cylinder(d = exit_d, h = 5, $fn = 72);
    }
}

// Joint coupon (one connected specimen): (a) wall tile + liner post + adapter
// post, (b) liner tile with hole + slot, (c) 4 mm flange tile. Tiles are joined
// by break-away bridges (cut before use).
// Stack b over a with M3x8 + nut to check the screw/nut/post stack and the
// slot. Tile (b) sits post_gap above the post tip when assembled.
module joint_coupon() {
    // (a) wall tile (3 mm): one liner post and one adapter-height post.
    difference() {
        cube([40, 85, wall]);
        translate([20, 65, -1]) cylinder(d = screw_clear, h = wall + 2);
    }
    translate([20, 20, wall]) nut_post(liner_post_h);
    translate([20, 65, wall]) nut_post(adapter_post_h, hole_from = -0.01);
    // (c) flange tile (4 mm): stack it UNDER (a) with the M3x16 from below to
    // check the adapter stack (4 + 3 + post). Gasket tape is NOT included.
    translate([50, 45, 0]) difference() {
        cube([40, 40, flange_t]);
        translate([20, 20, -1]) cylinder(d = screw_clear, h = flange_t + 2);
    }
    translate([39, 63, 0]) cube([12, 4, 1]);
    // (b) liner tile (2 mm): hole over the post + one 6x20 slot.
    translate([50, 0, 0]) plate(40, 40, liner_t, [[20, 20]], [[10, 20]], 90);
    // Thin break-away bridge keeps the specimen one connected body; cut it
    // with a knife before use.
    translate([39, 18, 0]) cube([12, 4, 1]);
}

// -------------------------------------------------------- tool reference
module tool_ref() {
    translate([cx - tool_w / 2, liner_y1 - tool_l, env_z0 + liner_t])
        cube([tool_w, tool_l, tool_h]);
}

// ---------------------------------------------------------- compositions
module assembly() {
    tub();
    roof();
    floor_liner_asm();
    roof_liner_asm();
    side_liner_left_asm();
    side_liner_right_asm();
    rear_liner_asm();
    adapter_asm();
}

module exploded() {
    tub();
    translate([0, 0, explode]) roof();
    translate([0, -3.5 * explode, -0.6 * explode]) floor_liner_asm();
    translate([0, -3.5 * explode, 0.6 * explode]) roof_liner_asm();
    translate([-0.6 * explode, -3.5 * explode, 0]) side_liner_left_asm();
    translate([0.6 * explode, -3.5 * explode, 0]) side_liner_right_asm();
    translate([0, -6 * explode, 0]) rear_liner_asm();
    translate([0, explode, 0]) adapter_asm();
}

// Print orientations (z >= 0, footprint inside bed).
module roof_print() translate([0, D, H]) rotate([180, 0, 0]) roof();

// ------------------------------------------------------------------ main
if (part == "tub") tub();
else if (part == "roof") roof_print();
else if (part == "floor_liner") floor_liner_flat();
else if (part == "rear_liner") rear_liner_flat();
else if (part == "side_liner") side_liner_flat();   // print 2
else if (part == "roof_liner") roof_liner_flat();
else if (part == "adapter") adapter();
else if (part == "fit_coupon") fit_coupon();
else if (part == "joint_coupon") joint_coupon();
else if (part == "assembly") { assembly(); if (show_tool) %tool_ref(); }
else if (part == "exploded") { exploded(); if (show_tool) %tool_ref(); }
else if (part == "section") {
    intersection() {
        assembly();
        translate([-50, -50, -50]) cube([section_x + 50, D + 200, H + 100]);
    }
    if (show_tool) %tool_ref();
}
else assert(false, "unknown part selector");
