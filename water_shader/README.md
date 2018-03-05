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

The fragment shader has many adjustable features now:
 * Specular
 * Roughness
 * Wavy albedo texture
 * Refraction
 * Sea foam texture
 * Distance fade

The water plane now follows the camera around, giving the illusion of an
infinite body of water.

Original water shader was made by Tom Langwaldt.
This shader has modifications by Zach Bernal (Chrisknyfe).


# Resources
[GPU Gems](https://developer.nvidia.com/gpugems/GPUGems/gpugems_ch02.html)
[Tom's Original GodotWater](https://gitlab.com/MrMinimal/GodotWater)
[Wind Waker Ocean Graphics Analysis](https://medium.com/@gordonnl/the-ocean-170fdfd659f1)
[Old Godot community asset pack discussion](https://godotdevelopers.org/forum/discussion/14458/community-asset-pack)
