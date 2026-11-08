# Blending Sentinel Collision (BSC) for Godot 4

**BSC** is a lightweight, open-source editor plugin and post-import pipeline utility for Godot 4. It bridges the gap between Blender and Godot by automatically converting specially prefixed 3D meshes into optimized physics colliders upon import—saving you from tedious manual collision setup in the editor.

Tested and fully compatible with **Godot 4.6.1 Stable**.

---

## Features

*   **Convex Hulls (`BSC_`)**: Automatically generates optimized convex collision hulls for solid props, boulders, and general assets.
*   **Box Primitives (`BSC_BOX_`)**: Instantly creates fast native primitive `BoxShape3D` colliders based on the mesh's exact bounding box (AABB) and center offset. Ideal for crates and barriers.
*   **Concave Trimeshes (`BSC_TRIMESH_`)**: Generates accurate triangle mesh colliders (`ConcavePolygonShape3D`) for complex or hollow geometry.
*   **Smart Hollow Detection**: Automatically routes names containing keywords like `doorway`, `arch`, `cave`, `tunnel`, or `room` to trimesh collision so characters can walk straight through them.
*   **Zero Visual Render Noise**: Automatically strips away the source collision mesh so it acts purely as invisible physics geometry in your game.

---

## Project Directory Structure

Your project layout should look like this:

```text
res://
└── addons/
    └── blending_sentinel_collision/
        ├── plugin.cfg
        ├── plugin.gd
        └── bsc_importer.gd
```

---

## Installation

1. Clone or download this repository.
2. Copy the `addons/blending_sentinel_collision/` folder directly into your Godot project's `addons/` directory (`res://addons/blending_sentinel_collision/`).
3. Open your project in Godot, navigate to **Project** -> **Project Settings** -> **Plugins**, and switch **Blending Sentinel Collision (BSC)** to **Enable**.

---

## Usage Guide

### 1. Naming Objects in Blender
When modeling your assets in Blender, name your collision meshes using the appropriate prefix:
*   `BSC_PropName` $\rightarrow$ Generates a convex collision shape.
*   `BSC_BOX_CrateName` $\rightarrow$ Generates a fast primitive box collider.
*   `BSC_TRIMESH_ArchName` $\rightarrow$ Generates a hollow concave trimesh collider. 
    *(Note: Keywords like `doorway`, `arch`, and `tunnel` will also trigger trimesh generation automatically).*

### 2. Configuring Godot Import Settings
1. Drop your `.blend` or `.glb` file into your Godot **FileSystem** dock.
2. Select the model file, then navigate to the **Import** dock (located next to the Scene tab).
3. Scroll down to the **Import Script** section.
4. Click the dropdown, select **Load**, and choose `res://addons/blending_sentinel_collision/bsc_importer.gd`.
5. Click **Reimport** at the bottom of the dock.

BSC will now parse your asset, generate the correct physics body and shape hierarchy, attach it to the parent model, and clear out the visual collision mesh automatically!

---

## License
Distributed under the MIT License. See `LICENSE` for more information.