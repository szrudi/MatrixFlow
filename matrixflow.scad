/**
 * ==============================================================================
 * MATRIXFLOW: UNIVERSAL PARAMETRIC DUCT ADAPTER LIBRARY
 * ==============================================================================
 * FEATURES:
 * 1. MATRIX FRAME ENGINE:
 * Replaced simple Euler angles with full 4x4 Transformation Matrices.
 * This eliminates "Gimbal Lock" and the collapsing twist seen in previous versions.
 *
 * 2. UP-VECTOR INTERPOLATION:
 * Calculates the exact "Up" direction (Depth axis) for the start and end,
 * then smoothly interpolates it. This keeps rectangular ducts perfectly flat
 * and aligned, preventing the "corkscrew" effect.
 *
 * 3. EXACT TANGENCY:
 * Extensions use the exact same matrix as the sweep limits, removing gaps/slits.
 *
 * USAGE:
 * For fast rendering, use OpenSCAD 2026.02+ (Dev Snapshot) where "Manifold"
 * is the default backend (Preferences > Advanced > 3D Rendering).
 *
 * UPDATES v3.2:
 * - Added "Curve Tension" control to fix kinks in tight 90-degree elbows.
 * - Improved handle calculation to account for 3D path length.
 * ==============================================================================
 */

matrixflow_adapter(
    /* [General Dimensions] */
    // Total vertical height of the transition (excluding straight extensions)
    transition_height = 160, // [10:500]
    // Thickness of the duct walls
    wall_thickness = 3.0, // [0.4:10]
    // Stiffness of the curve. Lower (0.3-0.5) for tight 90deg elbows. Higher (0.6-0.8) for gentle S-bends.
    curve_tension = .5, // [0.1:0.05:2.0]
    // Render quality (Higher = smoother but slower). Use 20 for draft, 60+ for export.
    smoothness = 20, // [20:200]
    // Polygon resolution for circles
    fn = 64, // [32:256]
    
    /* [Top Shape (Output)] */
    // Shape of the top opening
    top_shape = "rectangle", // [circle, rectangle]
    // Diameter (if circle) or Width (if rectangle)
    top_width = 90, // [10:500]
    // Depth (only used if rectangle)
    top_depth = 80, // [10:500]
    // Corner radius (only used if rectangle, 0 = sharp)
    top_corner_radius = 10, // [0:100]
    // Length of straight section at the top
    top_extension = 30, // [0:200]
    // Fit mode: 'standard' fits INSIDE a duct. 'slip_over' fits OVER a pipe.
    top_fit = "standard", // [standard, slip_over]
    
    /* [Bottom Shape (Input)] */
    // Shape of the bottom opening
    bottom_shape = "circle", // [circle, rectangle]
    // Diameter (if circle) or Width (if rectangle)
    bottom_width = 100, // [10:500]
    // Depth (only used if rectangle)
    bottom_depth = 70, // [10:500]
    // Corner radius (only used if rectangle, 0 = sharp)
    bottom_corner_radius = 0, // [0:100]
    // Length of straight section at the bottom
    bottom_extension = 30, // [0:200]
    // Fit mode: 'standard' fits INSIDE a duct. 'slip_over' fits OVER a pipe.
    bottom_fit = "slip_over", // [standard, slip_over]
    
    /* [Offsets & Alignment] */
    // Shift the top center along X axis
    offset_x = 20, // [-500:500]
    // Shift the top center along Y axis
    offset_y = 60, // [-500:500]
    
    /* [Exit Angles] */
    // Rotate top connection around Y axis (Left/Right tilt)
    angle_y = 30, // [-90:90]
    // Rotate top connection around X axis (Forward/Back tilt)
    angle_x = 10, // [-90:90]
);

// ==============================================================================
// VECTOR MATH HELPERS
// ==============================================================================

function unit(v) = norm(v)>0 ? v/norm(v) : [0,0,0];
function cross(a, b) = [a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x];
function dot(a, b) = a.x*b.x + a.y*b.y + a.z*b.z;
function lerp(start, end, t) = start + (end - start) * t;
function lerp_vec(a, b, t) = [lerp(a.x, b.x, t), lerp(a.y, b.y, t), lerp(a.z, b.z, t)];

// Rotate vector p by angles [ax, ay, az] (Standard X->Y->Z order)
function rot_x(p, a) = [p.x, p.y*cos(a)-p.z*sin(a), p.y*sin(a)+p.z*cos(a)];
function rot_y(p, a) = [p.x*cos(a)+p.z*sin(a), p.y, -p.x*sin(a)+p.z*cos(a)];
function rot_z(p, a) = [p.x*cos(a)-p.y*sin(a), p.x*sin(a)+p.y*cos(a), p.z];
function rotate_vec(p, a) = rot_z(rot_y(rot_x(p, a.x), a.y), a.z);

// Cubic Bezier Functions
function bezier(t, p0, p1, p2, p3) =
    pow(1-t, 3)*p0 + 3*pow(1-t, 2)*t*p1 + 3*(1-t)*pow(t, 2)*p2 + pow(t, 3)*p3;

function bezier_tangent(t, p0, p1, p2, p3) =
    3*pow(1-t, 2)*(p1-p0) + 6*(1-t)*t*(p2-p1) + 3*pow(t, 2)*(p3-p2);

// ==============================================================================
// GEOMETRY MODULES
// ==============================================================================

module shape_universal(w, d, r) {
    max_r = (min(w, d) / 2) - 0.01;
    actual_r = min(r, max_r);
    if (actual_r <= 0.01) square([w, d], center = true);
    else offset(r = actual_r) square([w - 2 * actual_r, d - 2 * actual_r], center = true);
}

module duct_shell(
    transition_height,
    wall_thickness,
    curve_tension,
    smoothness,
    fn,
    top_shape,
    top_width,
    top_depth,
    top_corner_radius,
    top_extension,
    top_fit,
    bottom_shape,
    bottom_width,
    bottom_depth,
    bottom_corner_radius,
    bottom_extension,
    bottom_fit,
    offset_x,
    offset_y,
    angle_x,
    angle_y,
    is_hole
) {
    // Offset Logic
    b_offset_val = (bottom_fit == "slip_over") ? (is_hole ? 0 : wall_thickness) : (is_hole ? -wall_thickness : 0);
    t_offset_val = (top_fit == "slip_over") ? (is_hole ? 0 : wall_thickness) : (is_hole ? -wall_thickness : 0);

    // Dimensions
    b_w = (bottom_shape == "circle") ? bottom_width : bottom_width;
    b_d = (bottom_shape == "circle") ? bottom_width : bottom_depth;
    b_r = (bottom_shape == "circle") ? bottom_width / 2 : bottom_corner_radius;

    t_w = (top_shape == "circle") ? top_width : top_width;
    t_d = (top_shape == "circle") ? top_width : top_depth;
    t_r = (top_shape == "circle") ? top_width / 2 : top_corner_radius;

    cut_length = is_hole ? 1.0 : 0;

    // --- 1. SETUP VECTORS & FRAMES ---

    // Bottom: Centered at 0, Up-vector is Y [0,1,0], Normal is Z [0,0,1]
    p0 = [0, 0, 0];
    vec_up_start = [0, 1, 0];

    // Top: Rotated by angle_x, angle_y
    p3 = [offset_x, offset_y, transition_height];

    // Calculate the exact vectors for the top frame based on user angles
    vec_normal_end = rotate_vec([0, 0, 1], [angle_x, angle_y, 0]); // Where the pipe points
    vec_up_end     = rotate_vec([0, 1, 0], [angle_x, angle_y, 0]); // Where the "Top" of the rect points

    // Handle Length for Bezier - Controlled by Curve Tension
    // We calculate a baseline distance to normalize the tension influence
    dist_linear = norm(p3 - p0);
    // Mix vertical height and linear distance for a balanced handle
    base_scale = (transition_height + dist_linear) / 2;
    handle_len = base_scale * curve_tension;

    // P1: Straight up from bottom
    p1 = [0, 0, handle_len];

    // P2: Backwards from P3 along the exit vector
    p2 = p3 - (vec_normal_end * handle_len);

    // --- 2. BOTTOM EXTENSION ---
    if (bottom_extension > 0) {
        translate([0, 0, -bottom_extension - cut_length])
        linear_extrude(height = bottom_extension + cut_length) {
            offset(delta = b_offset_val) shape_universal(b_w, b_d, b_r, $fn=fn);
        }
    } else if (is_hole) {
        translate([0, 0, -cut_length])
        linear_extrude(height = cut_length + 0.1)
            offset(delta = b_offset_val) shape_universal(b_w, b_d, b_r, $fn=fn);
    }

    // --- 3. MATRIX SWEEP ---
    steps = smoothness;
    for (i = [0 : steps - 1]) {
        t1 = i / steps;
        t2 = (i + 1) / steps;

        // -- Frame 1 --
        pos1 = bezier(t1, p0, p1, p2, p3);
        tan1 = unit(bezier_tangent(t1, p0, p1, p2, p3));
        // Interpolate the UP vector to prevent twisting
        up1_raw = lerp_vec(vec_up_start, vec_up_end, t1);
        // Orthogonalize (Gram-Schmidt)
        right1 = unit(cross(up1_raw, tan1));
        up1_ortho = unit(cross(tan1, right1));

        // Construct 4x4 Matrix for Frame 1
        // Mapping: X->Right(Width), Y->Up(Depth), Z->Tangent(Flow)
        m1 = [
            [right1.x, up1_ortho.x, tan1.x, pos1.x],
            [right1.y, up1_ortho.y, tan1.y, pos1.y],
            [right1.z, up1_ortho.z, tan1.z, pos1.z],
            [0, 0, 0, 1]
        ];

        // -- Frame 2 --
        pos2 = bezier(t2, p0, p1, p2, p3);
        tan2 = unit(bezier_tangent(t2, p0, p1, p2, p3));
        up2_raw = lerp_vec(vec_up_start, vec_up_end, t2);
        right2 = unit(cross(up2_raw, tan2));
        up2_ortho = unit(cross(tan2, right2));

        m2 = [
            [right2.x, up2_ortho.x, tan2.x, pos2.x],
            [right2.y, up2_ortho.y, tan2.y, pos2.y],
            [right2.z, up2_ortho.z, tan2.z, pos2.z],
            [0, 0, 0, 1]
        ];

        // Interpolate Shape
        w1 = lerp(b_w, t_w, t1); d1 = lerp(b_d, t_d, t1); r1 = lerp(b_r, t_r, t1);
        off1 = lerp(b_offset_val, t_offset_val, t1);

        w2 = lerp(b_w, t_w, t2); d2 = lerp(b_d, t_d, t2); r2 = lerp(b_r, t_r, t2);
        off2 = lerp(b_offset_val, t_offset_val, t2);

        hull() {
            multmatrix(m1) linear_extrude(0.01) offset(delta = off1) shape_universal(w1, d1, r1, $fn=fn);
            multmatrix(m2) linear_extrude(0.01) offset(delta = off2) shape_universal(w2, d2, r2, $fn=fn);
        }
    }

    // --- 4. TOP EXTENSION ---
    // We calculate the Final Matrix at t=1.0 to ensure 100% alignment
    pos_end = p3;
    tan_end = unit(bezier_tangent(1, p0, p1, p2, p3));
    up_end_raw = vec_up_end;
    right_end = unit(cross(up_end_raw, tan_end));
    up_end_ortho = unit(cross(tan_end, right_end));

    m_end = [
        [right_end.x, up_end_ortho.x, tan_end.x, pos_end.x],
        [right_end.y, up_end_ortho.y, tan_end.y, pos_end.y],
        [right_end.z, up_end_ortho.z, tan_end.z, pos_end.z],
        [0, 0, 0, 1]
    ];

    // Apply the matrix. We add a tiny -0.01 Z-shift (in local space) to overlap the hull.
    multmatrix(m_end)
    translate([0,0,-0.01])
    union() {
        if (top_extension > 0) {
            linear_extrude(height = top_extension + cut_length + 0.01) {
                offset(delta = t_offset_val) shape_universal(t_w, t_d, t_r, $fn=fn);
            }
        } else if (is_hole) {
            linear_extrude(height = cut_length + 0.01) {
                offset(delta = t_offset_val) shape_universal(t_w, t_d, t_r, $fn=fn);
            }
        }
    }
}

// ==============================================================================
// MAIN MODULE
// ==============================================================================

module matrixflow_adapter(
    // General Dimensions
    transition_height = 160,
    wall_thickness = 3.0,
    curve_tension = 0.35,
    smoothness = 20,
    fn = 64,
    // Top Shape (Output)
    top_shape = "rectangle",
    top_width = 90,
    top_depth = 80,
    top_corner_radius = 10,
    top_extension = 30,
    top_fit = "standard",
    // Bottom Shape (Input)
    bottom_shape = "circle",
    bottom_width = 100,
    bottom_depth = 70,
    bottom_corner_radius = 0,
    bottom_extension = 30,
    bottom_fit = "slip_over",
    // Offsets & Alignment
    offset_x = 20,
    offset_y = 60,
    // Exit Angles
    angle_x = 10,
    angle_y = 30,
    // Visualization
    show_path = false
) {
    difference() {
        duct_shell(
            transition_height, wall_thickness, curve_tension, smoothness, fn,
            top_shape, top_width, top_depth, top_corner_radius, top_extension, top_fit,
            bottom_shape, bottom_width, bottom_depth, bottom_corner_radius, bottom_extension, bottom_fit,
            offset_x, offset_y, angle_x, angle_y,
            is_hole = false
        );
        duct_shell(
            transition_height, wall_thickness, curve_tension, smoothness, fn,
            top_shape, top_width, top_depth, top_corner_radius, top_extension, top_fit,
            bottom_shape, bottom_width, bottom_depth, bottom_corner_radius, bottom_extension, bottom_fit,
            offset_x, offset_y, angle_x, angle_y,
            is_hole = true
        );
    }

    // Visual Helper: Path Points
    if (show_path) {
        color("red") {
            p0=[0,0,0];
            p3=[offset_x, offset_y, transition_height];
            dist_linear = norm(p3 - p0);
            base_scale = (transition_height + dist_linear) / 2;
            handle_len = base_scale * curve_tension;
            vec_normal_end = rotate_vec([0, 0, 1], [angle_x, angle_y, 0]);
            p1=[0,0,handle_len];
            p2 = p3 - (vec_normal_end * handle_len);

            for(i=[0:20]) {
                t = i/20;
                translate(bezier(t, p0, p1, p2, p3)) sphere(r=2, $fn=16);
            }
        }
    }
}

