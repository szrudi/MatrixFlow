"""
MATRIXFLOW TEST SUITE
=====================
This script verifies the mathematical and physical constraints of the MatrixFlow generator.
It uses OpenSCAD's CLI to generate test models and `trimesh` to analyze the geometry.

Requirements:
    pip install pytest trimesh numpy networkx rtree

Usage:
    pytest test_matrixflow.py -v

If you are using a custom OpenSCAD installation (like an AppImage via GearLever), 
you can pass the path via an environment variable:
    OPENSCAD_EXEC=/path/to/openscad.appimage  pytest test_matrixflow.py -v
"""

import os
import subprocess
import pytest
import trimesh
import numpy as np

# Configuration
# Read the custom executable path from the environment, fallback to system 'openscad'
OPENSCAD_CMD = os.environ.get("OPENSCAD_EXEC", "openscad")
SCAD_FILE = "matrixflow.scad"
STL_FILE = "temp_test_output.stl"

def generate_stl(params):
    """
    Helper function to call OpenSCAD via CLI, pass parameters, 
    generate an STL, and load it into a trimesh object.
    """
    # Enable the high-performance Manifold backend for significantly faster test execution
    args = [OPENSCAD_CMD, "--enable=manifold", "-o", STL_FILE, SCAD_FILE]
    
    # Pass parameters to OpenSCAD
    for key, value in params.items():
        if isinstance(value, str):
            args.extend(["-D", f'{key}="{value}"'])
        else:
            args.extend(["-D", f"{key}={value}"])
    
    # Run OpenSCAD (Ensure openscad is in your system PATH or OPENSCAD_EXEC is set)
    subprocess.run(args, check=True, capture_output=True)
    
    # Load and return the generated mesh
    return trimesh.load(STL_FILE)

def teardown_module(module):
    """Clean up the temporary STL file after all tests finish."""
    if os.path.exists(STL_FILE):
        os.remove(STL_FILE)

# =====================================================================
# 1. TOPOLOGICAL INTEGRITY TESTS
# =====================================================================

def test_manifold_watertight():
    """Verify there are no gaps, slits, or inverted normals in the model."""
    mesh = generate_stl({
        "transition_height": 100,
        "offset_x": 60,
        "offset_y": 60,
        "curve_tension": 0.5,
        "fn": 32  # Lower resolution for faster test execution
    })
    
    # This is the most critical check: guarantees the mesh is fully sealed for 3D printing
    assert mesh.is_watertight, "FAIL: Mesh has gaps, slits, or holes! It is not manifold."
    assert mesh.is_winding_consistent, "FAIL: Mesh has inverted/flipped normals!"
    
    # Check for Kinking (Volume Collapse)
    # If the mesh volume is suspiciously low, the inner wall folded over itself 
    # causing the boolean subtraction of the inner hole to wipe out the walls.
    assert mesh.volume > 0, "FAIL: Mesh has zero or negative volume! Geometry collapsed."

# =====================================================================
# 2. DIMENSION & EXTENSION TESTS
# =====================================================================

def test_transition_height_and_extensions():
    """Verify the exact Z-height constraints, including straight extensions."""
    t_height = 120
    b_ext = 25
    t_ext = 35
    
    mesh = generate_stl({
        "transition_height": t_height,
        "bottom_extension": b_ext,
        "top_extension": t_ext,
        "offset_x": 0, "offset_y": 0,
        "angle_x": 0, "angle_y": 0,
        "fn": 32
    })
    
    min_z = mesh.bounds[0][2]
    max_z = mesh.bounds[1][2]
    
    # The bottom extension grows downwards into negative Z
    assert min_z == pytest.approx(-b_ext, abs=0.1), "Bottom extension length is incorrect."
    
    # The top extension grows upwards from the transition_height
    expected_max_z = t_height + t_ext
    assert max_z == pytest.approx(expected_max_z, abs=0.1), "Total height / Top extension is incorrect."

def test_lateral_offsets():
    """Verify the X and Y shifting of the top opening."""
    target_x = 75
    target_y = -40
    
    mesh = generate_stl({
        "transition_height": 100,
        "offset_x": target_x,
        "offset_y": target_y,
        "top_extension": 10,
        "bottom_extension": 0,
        "straighten_path": 0,
        "angle_x": 0, "angle_y": 0,
        "fn": 32
    })
    
    # Take a 2D cross-section slice precisely through the top extension
    top_slice = mesh.section(plane_origin=[0, 0, 109], plane_normal=[0, 0, -1])
    centroid = top_slice.centroid
    
    # The centroid of the top slice should match the requested offsets
    assert centroid[0] == pytest.approx(target_x, abs=1.0), "X offset failed."
    assert centroid[1] == pytest.approx(target_y, abs=1.0), "Y offset failed."

# =====================================================================
# 3. SHAPE & FIT TESTS
# =====================================================================

def test_top_bottom_shapes():
    """Verify widths, depths, and shapes of the openings."""
    b_width = 40
    t_width = 80
    
    mesh = generate_stl({
        "bottom_shape": "circle",
        "bottom_width": b_width,
        "top_shape": "rectangle",
        "top_width": t_width,
        "top_depth": t_width, # Square for testing
        "wall_thickness": 2.0,
        "bottom_fit": "standard", # Standard = Outer dimension exactly matches width
        "top_fit": "standard",
        "transition_height": 100,
        "bottom_extension": 10,
        "top_extension": 10,
        "offset_x": 0, "offset_y": 0,
        "angle_x": 0, "angle_y": 0,
        "fn": 64
    })
    
    # Check Bottom Bounding Box (Circle)
    b_slice = mesh.section(plane_origin=[0, 0, -5], plane_normal=[0, 0, 1])
    b_measured_width = b_slice.bounds[1][0] - b_slice.bounds[0][0]
    assert b_measured_width == pytest.approx(b_width, abs=0.5), "Bottom width/fit mode is incorrect."
    
    # Check Top Bounding Box (Rectangle)
    t_slice = mesh.section(plane_origin=[0, 0, 105], plane_normal=[0, 0, -1])
    t_measured_width = t_slice.bounds[1][0] - t_slice.bounds[0][0]
    assert t_measured_width == pytest.approx(t_width, abs=0.5), "Top width/fit mode is incorrect."

# =====================================================================
# 4. ANGLE / TANGENCY TESTS
# =====================================================================

def test_exit_angles():
    """Verify the exit angles (face normals at the opening)."""
    angle_y = 45 # 45 degree tilt around Y axis (pitch)
    
    mesh = generate_stl({
        "transition_height": 100,
        "angle_y": angle_y,
        "angle_x": 0,
        "top_extension": 0, # No extension so we can test the exact end of the sweep
        "bottom_extension": 0,
        "fn": 32
    })
    
    # Sort all faces by their Z position to find the uppermost rim
    face_centroids = mesh.triangles_center
    top_faces_indices = np.argsort(face_centroids[:, 2])[-10:] # Grab top 10 highest triangles
    
    # Get the normal vector of the absolute highest face
    top_normal = mesh.face_normals[top_faces_indices[-1]]
    
    # Calculate what the expected normal vector should be (Rotated 45 deg around Y)
    # Sin(45) on X axis, Cos(45) on Z axis
    expected_normal = [np.sin(np.radians(angle_y)), 0, np.cos(np.radians(angle_y))]
    
    assert abs(top_normal[0]) == pytest.approx(abs(expected_normal[0]), abs=0.1), "Exit angle normal X component failed."
    assert abs(top_normal[1]) == pytest.approx(abs(expected_normal[1]), abs=0.1), "Exit angle normal Y component failed."
    assert abs(top_normal[2]) == pytest.approx(abs(expected_normal[2]), abs=0.1), "Exit angle normal Z component failed."
