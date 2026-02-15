# MatrixFlow: Universal Parametric Duct Adapter

MatrixFlow is a fully parametric, airflow-optimized generator for creating adapters between pipes, hoses, and HVAC ducts of different shapes and sizes.

[Try it online on MakerWorld!](#)

## The Problem

Connecting distinct airflow systems (e.g., a 110mm rigid PVC pipe to a 125mm flexible hose) often requires complex offsets. Standard adapters are straight, and flexible hoses can kink if forced into tight S-bends.

Most 3D printed adapters use simple "hull" or "loft" operations. When these bend sharply, the internal cross-section narrows (ovalizes), choking the airflow.

## The Solution: MatrixFlow Engine

This script uses a custom Matrix-based Sweep Engine to generate geometry:

1. It calculates a cubic bezier curve between the start and end points.
1. It generates 4x4 Transformation Matrices for every slice, ensuring the shape is always perpendicular to the airflow.
1. It calculates proper Up-Vector Interpolation to prevent rectangular ducts from twisting or collapsing during complex compound turns.

## Features

 - Universal Shape Morphing: Seamlessly transitions between:
   - Circle ↔ Circle (Reducers/Expanders)
   - Rectangle ↔ Rectangle (HVAC)
   - Circle ↔ Rectangle (Square-to-Round)
 - Complex Geometry: Handles independent X, Y, and Z offsets plus independent exit angles (Pitch and Yaw).
 - 3D Printing Optimized:
   - Constant wall thickness.
   - "Slip-over" vs "Standard" (Insert) fit modes.
   - No support material needed for most angles (<45°).

## Usage (Local)

1. Download and install OpenSCAD.
> [!NOTE]
> For fastest rendering, use the latest Development Snapshot and enable "Manifold" in Preferences -> Features.

2. Open MatrixFlow_adapter.scad.
1. Open the Customizer panel (Window -> Customizer).
1. Adjust parameters to fit your needs.
1. Press F6 to Render, then F7 to export as STL.

## Parameter Guide

| Parameter | Description |
|-----------|-------------|
| Transition Height | The vertical distance between the two ends. |
| Smoothness | Resolution of the curve. Use 20 for preview, 60+ for printing. |
| Top/Bottom Shape | Select Circle or Rectangle. |
| Fit Mode | Standard = adapter goes INSIDE the pipe. Slip Over = adapter goes OVER the pipe. |
| Offsets (X/Y) | Physical displacement of the top opening relative to the bottom. |
| Exit Angles | Rotates the top opening to align with angled pipes. |

## License

This project is licensed under the MIT License - feel free to use, modify, and distribute.
