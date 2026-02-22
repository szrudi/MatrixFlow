/**
 * Horn shape
 * For testing eccentric path straightening
 */

use <../matrixflow.scad>

/* [General Dimensions] */
transition_height = 100; // [10:500]
wall_thickness = 2.0; // [0.4:10]
curve_tension = 0.4; // [0.1:0.05:2.0]
straighten_path = 0.4; // [0.0:0.05:1.0]
smart_easing = false;
smoothness = 30; // [20:200]
fn = 64; // [32:256]

/* [Top Shape (Output)] */
top_shape = "circle"; // [circle, rectangle]
top_width = 120; // [10:500]
top_depth = 120; // [10:500]
top_corner_radius = 0; // [0:100]
top_extension = 10; // [0:200]
top_fit = "standard"; // [standard, slip_over]

/* [Bottom Shape (Input)] */
bottom_shape = "circle"; // [circle, rectangle]
bottom_width = 20; // [10:500]
bottom_depth = 20; // [10:500]
bottom_corner_radius = 0; // [0:100]
bottom_extension = 20; // [0:200]
bottom_fit = "standard"; // [standard, slip_over]

/* [Offsets & Alignment] */
offset_x = 60; // [-500:500]
offset_y = 60; // [-500:500]

/* [Exit Angles] */
angle_y = 0; // [-90:90]
angle_x = 0; // [-90:90]

/* [Visualization] */
show_path = true;

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
