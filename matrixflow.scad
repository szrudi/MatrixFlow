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
 * 4. SMART TENSION & EASING (v4.1):
 * - Proportional Handles: Dynamically prevents inner-wall kinking.
 * - Smart Easing Toggle: Optional non-linear shape morphing to protect tight bends.
 *
 * 5. ECCENTRIC PATH STRAIGHTENING (v4.2.1):
 * - Dynamically shifts the 2D profile off-center during the sweep. 
 * - Eliminates the "S-curve Belly" mimicking professional eccentric HVAC reducers.
 *
 * USAGE:
 * For fast rendering, use OpenSCAD 2026.02+ (Dev Snapshot) where "Manifold"
 * is the default backend (Preferences > Advanced > 3D Rendering).
 * ==============================================================================
 */

/* [General Dimensions] */
// Total vertical height of the transition (excluding straight extensions)
transition_height = 100; // [10:500]
// Thickness of the duct walls
wall_thickness = 2.0; // [0.4:10]
// Stiffness of the curve. Lower (0.3-0.5) for tight 90deg elbows. Higher (0.6-0.8) for gentle S-bends.
curve_tension = 0.5; // [0.1:0.05:2.0]
// Path Straightening: Shifts the profile internally to eliminate the "belly" on offsets. 1.0 = Max Straight.
straighten_path = 0.25; // [0.0:0.05:1.0]
// Enable smart shape morphing to hold the smaller profile deeper into the curve (helps extreme size differences).
smart_easing = false; // [true, false]
// Render quality (Higher = smoother but slower). Use 20 for draft, 60+ for export.
smoothness = 20; // [20:200]
// Polygon resolution for circles
fn = 64; // [32:256]

/* [Top Shape (Output)] */
// Shape of the top opening
top_shape = "rectangle"; // [circle, rectangle]
// Diameter (if circle) or Width (if rectangle)
top_width = 100; // [10:500]
// Depth (only used if rectangle)
top_depth = 60; // [10:500]
// Corner radius (only used if rectangle, 0 = sharp)
top_corner_radius = 10; // [0:100]
// Length of straight section at the top
top_extension = 20; // [0:200]
// Fit mode: 'standard' fits INSIDE a duct. 'slip_over' fits OVER a pipe.
top_fit = "standard"; // [standard, slip_over]

/* [Bottom Shape (Input)] */
// Shape of the bottom opening
bottom_shape = "circle"; // [circle, rectangle]
// Diameter (if circle) or Width (if rectangle)
bottom_width = 100; // [10:500]
// Depth (only used if rectangle)
bottom_depth = 0; // [10:500]
// Corner radius (only used if rectangle, 0 = sharp)
bottom_corner_radius = 0; // [0:100]
// Length of straight section at the bottom
bottom_extension = 20; // [0:200]
// Fit mode: 'standard' fits INSIDE a duct. 'slip_over' fits OVER a pipe.
bottom_fit = "standard"; // [standard, slip_over]

/* [Offsets & Alignment] */
// Shift the top center along X axis
offset_x = 0; // [-500:500]
// Shift the top center along Y axis
offset_y = 0; // [-500:500]

/* [Exit Angles] */
// Rotate top connection around Y axis (Left/Right tilt)
angle_y = 0; // [-90:90]
// Rotate top connection around X axis (Forward/Back tilt)
angle_x = 0; // [-90:90]

/* [Visualization] */
show_path = false; // [true, false]

matrixflow_adapter(
    transition_height = transition_height,
    wall_thickness = wall_thickness,
    curve_tension = curve_tension,
    straighten_path = straighten_path,
    smart_easing = smart_easing,
    smoothness = smoothness,
    fn = fn,
    top_shape = top_shape,
    top_width = top_width,
    top_depth = top_depth,
    top_corner_radius = top_corner_radius,
    top_extension = top_extension,
    top_fit = top_fit,
    bottom_shape = bottom_shape,
    bottom_width = bottom_width,
    bottom_depth = bottom_depth,
    bottom_corner_radius = bottom_corner_radius,
    bottom_extension = bottom_extension,
    bottom_fit = bottom_fit,
    offset_x = offset_x,
    offset_y = offset_y,
    angle_x = angle_x,
    angle_y = angle_y,
    show_path = show_path
);

// ==============================================================================
// MAIN MODULE
// ==============================================================================

module matrixflow_adapter(
    transition_height = 100,
    wall_thickness = 2.0,
    curve_tension = 0.5,
    straighten_path = 0.25,
    smart_easing = false,
    smoothness = 20,
    fn = 64,
    top_shape = "rectangle",
    top_width = 100,
    top_depth = 60,
    top_corner_radius = 10,
    top_extension = 20,
    top_fit = "standard",
    bottom_shape = "circle",
    bottom_width = 100,
    bottom_depth = 0,
    bottom_corner_radius = 0,
    bottom_extension = 20,
    bottom_fit = "standard",
    offset_x = 0,
    offset_y = 0,
    angle_x = 0,
    angle_y = 0,
    show_path = false
) {
    difference() {
        duct_shell(
            transition_height, wall_thickness, curve_tension, straighten_path, smart_easing, smoothness, fn,
            top_shape, top_width, top_depth, top_corner_radius, top_extension, top_fit,
            bottom_shape, bottom_width, bottom_depth, bottom_corner_radius, bottom_extension, bottom_fit,
            offset_x, offset_y, angle_x, angle_y,
            is_hole = false
        );
        duct_shell(
            transition_height, wall_thickness, curve_tension, straighten_path, smart_easing, smoothness, fn,
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
            vec_normal_end = rotate_vec([0, 0, 1], [angle_x, angle_y, 0]);
            
            b_r_eff = (bottom_shape == "circle") ? bottom_width / 2 : max(bottom_width, bottom_depth) / 2;
            t_r_eff = (top_shape == "circle") ? top_width / 2 : max(top_width, top_depth) / 2;
            
            handles = calc_handles(p0, p3, vec_normal_end, transition_height, offset_x, offset_y, curve_tension, b_r_eff, t_r_eff);
            p1 = handles[0];
            p2 = handles[1];

            // Render main orientation bezier
            for(i=[0:20]) {
                t = i/20;
                translate(bezier(t, p0, p1, p2, p3)) sphere(r=1, $fn=16);
            }
        }
    }
}

// ==============================================================================
// VECTOR MATH & EASING HELPERS
// ==============================================================================

function unit(v) = norm(v)>0 ? v/norm(v) : [0,0,0];
function cross(a, b) = [a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x];
function dot(a, b) = a.x*b.x + a.y*b.y + a.z*b.z;
function lerp(start, end, t) = start + (end - start) * t;
function lerp_vec(a, b, t) = [lerp(a.x, b.x, t), lerp(a.y, b.y, t), lerp(a.z, b.z, t)];

// Standard smoothstep to maintain tangency but without extreme exponential morphing
function basic_ease(t) = t * t * (3 - 2 * t);

// Dynamic non-linear easing to prevent inner-wall kinks.
function smart_shape_ease(t, b_size, t_size) =
    let(
        // 1. Calculate size difference (e.g. 120mm top / 20mm bottom = 6.0 ratio)
        ratio = max(t_size, 0.001) / max(b_size, 0.001),
        
        // 2. Square root dampens extreme ratios so the exponent doesn't get wildly high for massive adapters
        exp_raw = sqrt(ratio),
        
        // 3. Clamp the exponent to safe bounds:
        // - Lower bound (0.3): Max bias when the bottom is much larger than the top. 
        //   Setting this closer to 0 creates a harsh step at the beginning.
        // - Upper bound (3.5): Max bias when the top is much larger than the bottom. 
        //   Setting this higher (e.g., 5+) forces the pipe to stay tiny longer, but causes a harsh expansion step at the very end.
        exp_clamped = min(max(exp_raw, 0.3), 2),
        
        // 4. Apply the exponential bias to the linear 0-1 time step
        t_biased = pow(t, exp_clamped)
    )
    // Wrap in a standard smoothstep to guarantee 0-derivative at the ends (perfect vertical tangency)
    t_biased * t_biased * (3 - 2 * t_biased);

// Rotate vector p by angles [ax, ay, az]
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
// SMART PATH GENERATOR
// ==============================================================================

// Calculates intelligent Bezier handles to prevent topological kinks and loops
function calc_handles(p0, p3, vec_normal_end, transition_height, offset_x, offset_y, curve_tension, b_r_eff, t_r_eff) = 
    let(
        dist_linear = norm(p3 - p0),
        
        // 1. Proportional Handle Distribution
        total_r = b_r_eff + t_r_eff + 0.001,
        w_b = max(b_r_eff / total_r, 0.15),
        w_t = max(t_r_eff / total_r, 0.15),
        sum_w = w_b + w_t,
        w_b_norm = w_b / sum_w,
        w_t_norm = w_t / sum_w,
        
        // 2. Budget Allocation
        budget = dist_linear * curve_tension * 1.5,
        h1 = budget * w_b_norm,
        h2 = budget * w_t_norm,
        
        // 3. Anti-Looping Clamp
        h1_clamped = min(h1, dist_linear * 0.65),
        h2_clamped = min(h2, dist_linear * 0.65)
    )
    [
        p0 + [0, 0, h1_clamped],
        p3 - (vec_normal_end * h2_clamped)
    ];


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
    straighten_path,
    smart_easing,
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
    
    b_r_eff = (bottom_shape == "circle") ? bottom_width / 2 : max(bottom_width, bottom_depth) / 2;
    t_r_eff = (top_shape == "circle") ? top_width / 2 : max(top_width, top_depth) / 2;

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

    // Smart Handles for Orientation (Loose S-Curve for safe normals)
    handles = calc_handles(p0, p3, vec_normal_end, transition_height, offset_x, offset_y, curve_tension, b_r_eff, t_r_eff);
    p1 = handles[0];
    p2 = handles[1];
    
    // Target Handles for Position (Tight Diagonal Curve to eliminate belly)
    // Relaxed 'tight_mag' from 0.1 to 0.2 to prevent reverse-belly snapping
    tight_mag = norm(p3 - p0) * 0.2;
    p1_tight = p0 + [0, 0, tight_mag];
    p2_tight = p3 - (vec_normal_end * tight_mag);

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
        b_pos1 = bezier(t1, p0, p1, p2, p3);
        tan1 = unit(bezier_tangent(t1, p0, p1, p2, p3));
        // Interpolate the UP vector to prevent twisting
        up1_raw = unit(lerp_vec(vec_up_start, vec_up_end, t1));
        // Orthogonalize (Gram-Schmidt)
        right1 = unit(cross(up1_raw, tan1));
        up1_ortho = unit(cross(tan1, right1));

        // Construct 4x4 Matrix for Frame 1
        // Mapping: X->Right(Width), Y->Up(Depth), Z->Tangent(Flow)
        m1 = [
            [right1.x, up1_ortho.x, tan1.x, b_pos1.x],
            [right1.y, up1_ortho.y, tan1.y, b_pos1.y],
            [right1.z, up1_ortho.z, tan1.z, b_pos1.z],
            [0, 0, 0, 1]
        ];
        
        // Frame 1 Eccentric Shift
        target1 = bezier(t1, p0, p1_tight, p2_tight, p3);
        corr1 = (target1 - b_pos1) * straighten_path;
        shift_x1 = dot(corr1, right1);
        shift_y1 = dot(corr1, up1_ortho);

        // -- Frame 2 --
        b_pos2 = bezier(t2, p0, p1, p2, p3);
        tan2 = unit(bezier_tangent(t2, p0, p1, p2, p3));
        up2_raw = unit(lerp_vec(vec_up_start, vec_up_end, t2));
        right2 = unit(cross(up2_raw, tan2));
        up2_ortho = unit(cross(tan2, right2));

        m2 = [
            [right2.x, up2_ortho.x, tan2.x, b_pos2.x],
            [right2.y, up2_ortho.y, tan2.y, b_pos2.y],
            [right2.z, up2_ortho.z, tan2.z, b_pos2.z],
            [0, 0, 0, 1]
        ];
        
        // Frame 2 Eccentric Shift
        target2 = bezier(t2, p0, p1_tight, p2_tight, p3);
        corr2 = (target2 - b_pos2) * straighten_path;
        shift_x2 = dot(corr2, right2);
        shift_y2 = dot(corr2, up2_ortho);

        // Interpolate Shape (Toggleable Smart Easing)
        t1_shape = smart_easing ? smart_shape_ease(t1, b_r_eff, t_r_eff) : basic_ease(t1);
        w1 = lerp(b_w, t_w, t1_shape); d1 = lerp(b_d, t_d, t1_shape); r1 = lerp(b_r, t_r, t1_shape);
        off1 = lerp(b_offset_val, t_offset_val, t1_shape);

        t2_shape = smart_easing ? smart_shape_ease(t2, b_r_eff, t_r_eff) : basic_ease(t2);
        w2 = lerp(b_w, t_w, t2_shape); d2 = lerp(b_d, t_d, t2_shape); r2 = lerp(b_r, t_r, t2_shape);
        off2 = lerp(b_offset_val, t_offset_val, t2_shape);

        hull() {
            // Apply the shift locally in the frame's 2D plane
            multmatrix(m1) translate([shift_x1, shift_y1, -0.01]) 
                linear_extrude(0.01) offset(delta = off1) shape_universal(w1, d1, r1, $fn=fn);
            multmatrix(m2) translate([shift_x2, shift_y2, -0.01]) 
                linear_extrude(0.01) offset(delta = off2) shape_universal(w2, d2, r2, $fn=fn);
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
