# Godot Water
This project has the aim to create 3D open water for the Godot game engine.

Tested with: Godot_v3.0-stable_win64

![water ingame](/uploads/a82860a3f763a9d1e50c375e99cab040/water.gif)

# Principle
The plane on which water is simulated is generated during runtime.
A mesh is generated using the SurfaceTool class.
After that, a vertex shader is applied to the mesh which moves the
vertices every frame.
The movement consists of the average of multiple Gerstner Waves each with
slightly different values.

# Resources
[GPU Gems](https://developer.nvidia.com/gpugems/GPUGems/gpugems_ch02.html)
