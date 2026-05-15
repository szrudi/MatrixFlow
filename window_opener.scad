/**
 * ==============================================================================
 * SMART WINDOW OPENER — CASE & LEVER PULLING MECHANISM
 * ==============================================================================
 * Companion 3D model to the ESPHome motorized ventilation grille project.
 *
 *   Parts in this file (select via `part`):
 *     - case_body          Electronics enclosure (Lolin D1 Mini V4 + DRV8871 +
 *                          Mini360 buck), wall-mount tabs, side cutouts.
 *     - case_lid           Friction-fit lid for the enclosure.
 *     - actuator_bracket   Saddle clamp that holds a cylindrical 12 V linear
 *                          actuator parallel to the window lever (the 90°
 *                          rotated layout from the project notes).
 *     - lever_clevis       U-fork that bolts to the actuator rod-end (double
 *                          shear M5) and grabs the window lever. Print flat.
 *     - preview_assembly   Soft-rendered exploded view, for visual sanity only.
 *
 *   Print orientation:
 *     - case_body          Open side up (no supports for shallow cutouts).
 *     - case_lid           Flat.
 *     - actuator_bracket   Saddle opening up.
 *     - lever_clevis       FLAT on the bed (CF-PETG layers in tension).
 *
 *   Material assumption: CF-PETG with 4+ perimeters on the clevis. M5 bolt
 *   through the rod-end with washers on each side per the project rules.
 * ==============================================================================
 */

/* [Render] */
// Which part to render. Use "preview_assembly" for a rough exploded view.
part = "preview_assembly"; // [case_body, case_lid, actuator_bracket, lever_clevis, preview_assembly]
// Polygon resolution for circles.
fn = 64; // [24:256]

/* [Print Settings] */
// Outer wall thickness. 2.4 = 6 lines at 0.4mm nozzle (stiff in CF-PETG).
wall = 2.4; // [1.2:0.4:4.8]
// Floor / ceiling thickness.
floor_t = 1.6; // [0.8:0.2:3.0]
// Friction-fit slip clearance (lid into body, bracket around actuator).
slip_gap = 0.2; // [0.0:0.05:0.6]
// Loose clearance for bolts through holes.
bolt_gap = 0.2; // [0.0:0.05:0.6]

/* [Electronics Case — Outer Shell] */
// Internal floor dimensions (X = long edge, Y = short edge).
case_inner_w = 78;  // [40:200]
case_inner_d = 56;  // [30:150]
// Internal height. Needs to clear the USB-C connector standing above the D1 Mini.
case_inner_h = 20;  // [10:60]
// Outer corner radius (cosmetic).
case_corner_r = 3;  // [0:15]
// Wall-mount ear depth (extends from one long side). 0 = no ears.
mount_ear_l = 14;   // [0:30]
// Mount ear screw hole (M3 = 3.2, M4 = 4.4).
mount_ear_hole_d = 4.4; // [2.5:0.1:6.0]
// Ear hole centre offset from the case wall.
mount_ear_hole_inset = 7; // [4:20]

/* [Lid] */
// Lid lip depth that sinks into the body.
lid_lip_h = 3; // [1:0.5:6]
// How much of the lid sits proud above the body (visual chamfer).
lid_proud_h = 1.2; // [0:0.2:3]

/* [Lolin D1 Mini V4 Footprint] */
// PCB outline.
d1_w = 34.2;
d1_d = 25.6;
// Mounting hole spacing (corner pattern). Lolin V4 = 27.94 × 22.86 mm.
d1_hx = 27.94;
d1_hy = 22.86;
// Standoff geometry.
d1_standoff_h  = 4;    // [2:0.5:10]
d1_standoff_od = 4.5;  // [3:0.5:8]
d1_standoff_id = 2.0;  // M2 self-tap
// Top-left corner of the D1 PCB inside the case (offset from inner wall).
d1_pos_x = 6;  // [2:100]
d1_pos_y = 7;  // [2:100]
// USB-C connector opening (panel side, on +X wall by default).
usb_w = 10.0; // [6:0.1:14]
usb_h = 5.2;  // [3:0.1:10]
// USB-C opening offset above the PCB top surface (gap between PCB and floor counted automatically).
usb_above_pcb = 0.3; // [0:0.1:3]

/* [DRV8871 Module Footprint] */
// Generic AliExpress DRV8871 module (carrier ~30 × 16 mm).
drv_w = 30;
drv_d = 16;
// Mounting hole pattern (set both to 0 if your module has none; we'll fall back to a snug pocket).
drv_hx = 26;
drv_hy = 11;
drv_standoff_h  = 4;
drv_standoff_od = 5;
drv_standoff_id = 2.5; // M2.5 self-tap
// Position inside the case.
drv_pos_x = 6;
drv_pos_y = 35;

/* [Mini360 Buck — Pocket] */
// Mini360 has no mounting holes; we cradle it in a pocket and rely on the lid.
m360_w = 17.5;
m360_d = 11.5;
m360_h = 5.5;   // includes inductor height clearance
m360_pos_x = 52;
m360_pos_y = 8;

/* [Side Cutouts] */
// Panel-mount push button hole (e.g. 7 mm momentary).
button_hole_d = 7.2; // [4:0.1:14]
button_pos_y = 36;   // along the -X wall, measured from inner wall +Y corner
button_pos_z = 10;   // up from the floor
// 12 V DC input strain-relief notch (semicircle in the wall edge).
power_notch_d = 5;   // [3:0.1:12]
power_pos_y   = 14;

/* [Linear Actuator — Body (rectangular)] */
// IP60-60/108-S3-12V-T: rectangular body, 50 mm stroke, 50 N, 15 mm/s.
// Body length excluding the rod tip extension.
actuator_body_l = 108;  // [40:0.5:200]
// Body width (long cross-section dimension).
actuator_body_w = 30;   // [10:0.5:60]
// Body thickness (short cross-section dimension, including its plastic feet).
actuator_body_h = 17;   // [8:0.5:40]
// Distance from each body end to the centre of the foot mounting hole.
actuator_foot_inset = 6; // [3:0.5:20]
// Mounting foot screw clearance (M3 = 3.2, M4 = 4.4).
actuator_foot_hole_d = 3.2; // [2.5:0.1:6.0]
// Heat-set insert pocket diameter (for an M3 brass insert ≈ Ø4.2 mm). Set 0 to skip.
actuator_foot_insert_d = 4.2; // [0:0.1:6.0]
actuator_foot_insert_h = 4.0;
// Stroke (just for documentation / preview ghost).
actuator_stroke = 50;   // [5:1:100]

/* [Actuator Bracket — Base Plate] */
// The bracket is a flat plate the actuator screws down to. Its two foot holes
// match the actuator's own mounting holes; its outer screw slots clamp the
// plate to the window frame.
bracket_base_w = actuator_body_l + 20; // [40:200] — along actuator axis
bracket_base_d = actuator_body_w + 18; // [20:120] — perpendicular
bracket_base_h = 6;                    // [4:0.5:15] — plate thickness
// Elongated frame-mount slots (two on each long edge) for fine alignment.
bracket_slot_l = 12;
bracket_slot_w = 4.5;  // M4 clearance
bracket_slot_inset = 6;

/* [Lever Clevis — Actuator-Rod End] */
// IP60 rod-end is a small single tab with an M3 cross-hole. The fork on our
// part wraps around that tab to give double-shear on the pin.
// Rod-end tab thickness — the gap inside the fork.
clevis_fork_gap = 4.0;  // [2:0.1:20]
// Pivot pin diameter through the rod-end (M3 = 3.2 clearance).
clevis_pivot_d = 3.2;   // [2:0.1:10]
// Fork arm thickness (each side of the U).
clevis_arm_t = 3.0;     // [2:0.5:8]
// Distance from pivot hole centre to the lever-end pivot hole centre.
clevis_length = 40;     // [15:200]
// Width of the clevis body (max — tapers from fork to lever end if desired).
clevis_body_w = 14;     // [8:30]

/* [Lever Clevis — Lever Attach] */
// thru_bolt: single hole at the lever end (default, simplest).
// knob_clamp: split clamp around a cylindrical knob with an M3 pinch screw.
clevis_lever_mode = "thru_bolt"; // [thru_bolt, knob_clamp]
// thru_bolt hole diameter at the lever end (M5 default).
clevis_lever_hole_d = 5.2;
// knob_clamp inner diameter (matches the window-lever post).
clevis_knob_d = 10;          // [4:0.2:25]
// knob_clamp pinch slit width.
clevis_pinch_slit_w = 1.5;
// knob_clamp pinch screw hole (M3 = 3.4 clearance) and nut trap (M3 nut AF=5.5).
clevis_pinch_screw_d = 3.4;
clevis_pinch_nut_af  = 5.6;
clevis_pinch_nut_th  = 2.6;

$fn = fn;

// =============================================================================
// HELPERS
// =============================================================================

module rounded_plate(w, d, h, r) {
    hull() {
        for (x = [r, w - r], y = [r, d - r])
            translate([x, y, 0]) cylinder(r = r, h = h);
    }
}

module rounded_box(w, d, h, r, t_wall, t_floor) {
    difference() {
        rounded_plate(w, d, h, r);
        translate([t_wall, t_wall, t_floor])
            rounded_plate(w - 2 * t_wall, d - 2 * t_wall, h, max(0.1, r - t_wall));
    }
}

module pcb_standoffs(hx, hy, h, od, id) {
    // Four corner standoffs centred on a hx × hy hole grid.
    for (x = [-hx/2, hx/2], y = [-hy/2, hy/2])
        translate([x, y, 0]) difference() {
            cylinder(d = od, h = h);
            translate([0, 0, -0.1]) cylinder(d = id, h = h + 0.2);
        }
}

// Arc of an annulus, used as a 2D profile for the saddle clamp.
module saddle_profile(od, id, wrap_fraction) {
    // wrap_fraction = how much of the full circle is solid material below.
    // 0.5 = lower half, 0.6 = past equator (snap-fit), 1.0 = full ring.
    angle = 360 * wrap_fraction;
    start = 270 - angle / 2;   // centred on the bottom (-Y) so opening faces +Z
    difference() {
        // Solid annulus
        difference() {
            circle(d = od);
            circle(d = id);
        }
        // Cut everything outside [start, start+angle]
        rotate(start) translate([-od, 0]) square([2 * od, 2 * od]);
        rotate(start + angle) translate([-od, -2 * od]) square([2 * od, 2 * od]);
    }
}

// =============================================================================
// PART: ELECTRONICS CASE — BODY
// =============================================================================

case_outer_w = case_inner_w + 2 * wall;
case_outer_d = case_inner_d + 2 * wall;
case_outer_h = case_inner_h + floor_t;

module case_body() {
    difference() {
        union() {
            // Shell.
            rounded_box(case_outer_w, case_outer_d, case_outer_h,
                        case_corner_r, wall, floor_t);
            // Wall-mount ears on the -Y face.
            if (mount_ear_l > 0) {
                ear_h = max(3, floor_t);
                translate([0, -mount_ear_l, 0])
                    rounded_plate(case_outer_w, mount_ear_l + case_corner_r, ear_h, 3);
            }
            // Internal standoffs (D1 Mini).
            translate([wall + d1_pos_x + d1_w/2,
                       wall + d1_pos_y + d1_d/2,
                       floor_t])
                pcb_standoffs(d1_hx, d1_hy, d1_standoff_h,
                              d1_standoff_od, d1_standoff_id);
            // Internal standoffs (DRV8871) — only if the module has holes.
            if (drv_hx > 0 && drv_hy > 0)
                translate([wall + drv_pos_x + drv_w/2,
                           wall + drv_pos_y + drv_d/2,
                           floor_t])
                    pcb_standoffs(drv_hx, drv_hy, drv_standoff_h,
                                  drv_standoff_od, drv_standoff_id);
            // Mini360 cradle: a shallow pocket frame.
            translate([wall + m360_pos_x, wall + m360_pos_y, floor_t])
                difference() {
                    cube([m360_w + 2, m360_d + 2, m360_h]);
                    translate([1, 1, 0.6])
                        cube([m360_w + slip_gap, m360_d + slip_gap, m360_h]);
                }
            // Lid lip — inner shelf for the lid to sink into.
            translate([wall, wall, case_outer_h - lid_lip_h])
                difference() {
                    rounded_plate(case_inner_w, case_inner_d, lid_lip_h,
                                  max(0.1, case_corner_r - wall));
                    translate([wall/2, wall/2, -0.1])
                        rounded_plate(case_inner_w - wall, case_inner_d - wall,
                                      lid_lip_h + 0.2,
                                      max(0.1, case_corner_r - wall - 0.5));
                }
        }

        // Mount-ear screw holes.
        if (mount_ear_l > 0) {
            for (x = [case_outer_w * 0.2, case_outer_w * 0.8])
                translate([x, -mount_ear_l + mount_ear_hole_inset, -0.1])
                    cylinder(d = mount_ear_hole_d, h = floor_t + 2);
        }

        // USB-C cutout on +X wall, aligned with the D1 Mini USB connector.
        // The USB-C connector sits on the +X-facing short edge of the PCB.
        usb_z = floor_t + d1_standoff_h + 1.6 + usb_above_pcb; // PCB top ≈ standoff + PCB
        translate([case_outer_w - wall - 0.1,
                   wall + d1_pos_y + d1_d/2 - usb_w/2,
                   usb_z])
            cube([wall + 0.2, usb_w, usb_h]);

        // Push-button hole on -X wall.
        translate([-0.1, wall + button_pos_y, floor_t + button_pos_z])
            rotate([0, 90, 0])
                cylinder(d = button_hole_d, h = wall + 0.2);

        // 12 V power strain-relief notch on -X wall (semicircle in the rim).
        translate([-0.1, wall + power_pos_y, case_outer_h - power_notch_d/2])
            rotate([0, 90, 0])
                cylinder(d = power_notch_d, h = wall + 0.2);
    }
}

// =============================================================================
// PART: ELECTRONICS CASE — LID
// =============================================================================

module case_lid() {
    inner_r = max(0.1, case_corner_r - wall - 0.5);
    lip_w = case_inner_w - wall - slip_gap;
    lip_d = case_inner_d - wall - slip_gap;
    union() {
        // Top plate (sits flush on the body rim).
        rounded_plate(case_outer_w, case_outer_d, lid_proud_h, case_corner_r);
        // Lip that drops into the lid shelf.
        translate([(case_outer_w - lip_w)/2, (case_outer_d - lip_d)/2, -lid_lip_h + 0.01])
            rounded_plate(lip_w, lip_d, lid_lip_h, inner_r);
    }
}

// =============================================================================
// PART: ACTUATOR BRACKET (saddle clamp on a base plate)
// =============================================================================

module actuator_bracket() {
    // Flat plate that mounts to the window frame. The actuator body lies flat
    // on top of the plate with its integrated foot screws going through the
    // plate from below (or into heat-set inserts on top, if enabled).
    //
    // In use this whole plate is rotated 90° so it sits vertical against the
    // window frame, parallel to the glass; the actuator body is vertical with
    // its rod hanging downward (the lever it pulls is behind it).

    // Actuator-foot screw positions (centred on the plate).
    foot_x_a = (bracket_base_w - actuator_body_l) / 2 + actuator_foot_inset;
    foot_x_b = bracket_base_w - foot_x_a;
    foot_y   = bracket_base_d / 2;

    difference() {
        rounded_plate(bracket_base_w, bracket_base_d, bracket_base_h, 4);

        // Actuator footprint — a shallow recess so the body keys into the plate
        // (helps alignment, prevents the body sliding sideways under load).
        translate([(bracket_base_w - actuator_body_l)/2,
                   (bracket_base_d - actuator_body_w)/2,
                   bracket_base_h - 1.0])
            cube([actuator_body_l, actuator_body_w, 1.2]);

        // Actuator foot screw holes — through-hole + optional heat-set pocket.
        for (fx = [foot_x_a, foot_x_b]) {
            translate([fx, foot_y, -0.5])
                cylinder(d = actuator_foot_hole_d, h = bracket_base_h + 1);
            if (actuator_foot_insert_d > 0)
                translate([fx, foot_y, bracket_base_h - actuator_foot_insert_h])
                    cylinder(d = actuator_foot_insert_d,
                             h = actuator_foot_insert_h + 0.1);
        }

        // Frame-mount slots: two on each short edge (the long edges are where
        // the actuator sits, so we put the wall screws on the short ends).
        for (sy_off = [bracket_slot_inset,
                       bracket_base_d - bracket_slot_inset - bracket_slot_w]) {
            for (sx_off = [bracket_slot_inset,
                           bracket_base_w - bracket_slot_inset - bracket_slot_l]) {
                translate([sx_off, sy_off, -0.5])
                    hull() {
                        cylinder(d = bracket_slot_w, h = bracket_base_h + 1);
                        translate([bracket_slot_l - bracket_slot_w, 0, 0])
                            cylinder(d = bracket_slot_w, h = bracket_base_h + 1);
                    }
            }
        }
    }
}

// =============================================================================
// PART: LEVER CLEVIS
// =============================================================================

module lever_clevis() {
    // Printed FLAT on the bed. The whole part has uniform thickness in Z
    // except for the two raised fork prongs at the pivot end. Layer lines
    // run in X-Y, parallel to the pulling axis (CF-PETG tension along fibres).
    //
    // Coordinate convention:
    //   x = 0           pivot bolt (the M5 pin going through both prongs)
    //   x = -prong_back  back face of the prongs (gives material behind bolt)
    //   x = +yoke_clear  body starts here (clear of the rod-end yoke disc)
    //   x = +clevis_length  lever attachment hole

    body_z      = clevis_arm_t;
    prong_d     = clevis_arm_t * 2.2;           // prong wall thickness around bolt
    prong_back  = prong_d;                       // extension behind the bolt
    yoke_clear  = max(prong_d, clevis_fork_gap) * 0.6; // clearance for rod-end disc
    prong_z     = clevis_arm_t + clevis_fork_gap;  // top of fork (above body)
    prong_y     = (clevis_fork_gap + prong_d) / 2; // centre of each prong in Y

    difference() {
        union() {
            // Flat body: tapered plate from the fork end (wide) to the lever end.
            hull() {
                translate([yoke_clear, -prong_y, 0])
                    cylinder(d = prong_d, h = body_z);
                translate([yoke_clear, prong_y, 0])
                    cylinder(d = prong_d, h = body_z);
                translate([clevis_length, 0, 0])
                    cylinder(d = clevis_body_w, h = body_z);
            }
            // Two raised fork prongs straddling the yoke gap.
            for (sy = [-prong_y, prong_y])
                translate([0, sy, 0])
                    hull() {
                        cylinder(d = prong_d, h = prong_z);
                        translate([-prong_back, 0, 0])
                            cylinder(d = prong_d, h = prong_z);
                        translate([yoke_clear, 0, 0])
                            cylinder(d = prong_d, h = body_z); // taper into body
                    }
        }

        // Pivot bolt hole through Z (both prongs).
        translate([0, 0, -0.5])
            cylinder(d = clevis_pivot_d + bolt_gap, h = prong_z + 1);

        // Lever-end attachment.
        if (clevis_lever_mode == "thru_bolt") {
            translate([clevis_length, 0, -0.5])
                cylinder(d = clevis_lever_hole_d + bolt_gap, h = body_z + 1);
        } else {
            // knob_clamp: bore for the post, pinch slit, cross-bolt, nut trap.
            translate([clevis_length, 0, -0.5])
                cylinder(d = clevis_knob_d + slip_gap, h = body_z + 1);
            // Slit out to the +X edge so the clamp can flex.
            translate([clevis_length, -clevis_pinch_slit_w/2, -0.5])
                cube([clevis_body_w, clevis_pinch_slit_w, body_z + 1]);
            // Cross-bolt through the slit (Y axis).
            translate([clevis_length + clevis_knob_d/2 + 3,
                       -clevis_body_w, body_z/2])
                rotate([-90, 0, 0])
                    cylinder(d = clevis_pinch_screw_d, h = clevis_body_w * 2);
            // Hex nut trap (M3) on the +Y side.
            translate([clevis_length + clevis_knob_d/2 + 3,
                       clevis_body_w/2 - clevis_pinch_nut_th,
                       body_z/2])
                rotate([-90, 0, 0])
                    cylinder(d = clevis_pinch_nut_af / cos(30),
                             h = clevis_pinch_nut_th, $fn = 6);
        }
    }
}

// =============================================================================
// PREVIEW ASSEMBLY (visual only — not printable)
// =============================================================================

module preview_assembly() {
    case_body();
    translate([0, 0, case_outer_h + 8]) case_lid();

    // Actuator bracket + ghosted actuator in its IN-USE orientation:
    // the bracket sits vertically against the window frame (rotated 90°
    // about Y), with the actuator body pointing downward so the rod hangs
    // toward -Z. The clevis arm extends backward (-Y) from the rod-end.
    translate([case_outer_w + 60, 0, 0])
        rotate([0, 90, 0]) {
            actuator_bracket();
            // Ghost: rectangular actuator body resting on the plate.
            %translate([(bracket_base_w - actuator_body_l)/2,
                        (bracket_base_d - actuator_body_w)/2,
                        bracket_base_h])
                cube([actuator_body_l, actuator_body_w, actuator_body_h]);
            // Ghost: extended rod (assume half-stroke for the snapshot).
            %translate([bracket_base_w/2,
                        bracket_base_d/2,
                        bracket_base_h + actuator_body_h])
                cylinder(d = 6, h = actuator_stroke/2);
            // Ghost: clevis hanging on the rod-end at half-stroke.
            %translate([bracket_base_w/2 + 0,
                        bracket_base_d/2 + 0,
                        bracket_base_h + actuator_body_h + actuator_stroke/2 + 2])
                rotate([0, 0, 90])
                    lever_clevis();
        }

    // Lever clevis solo, off to the side, in print orientation.
    translate([0, -80, 0]) lever_clevis();
}

// =============================================================================
// DISPATCH
// =============================================================================

if (part == "case_body")          case_body();
else if (part == "case_lid")      case_lid();
else if (part == "actuator_bracket") actuator_bracket();
else if (part == "lever_clevis")  lever_clevis();
else                              preview_assembly();
