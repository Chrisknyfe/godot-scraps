tool 
extends MeshInstance

export(Material) 	var mat
export(int)			var resolution = 100
export(float) 		var scaleFactor = 0.10
export(float)		var matScaleFactor = 1.0

# Due to the "tool" keyword at the top of this file
# this function already executes in the editor
func _ready():
	var surfTool = SurfaceTool.new()
	var mesh = Mesh.new()
	  
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in range(-resolution/2, resolution/2):
		for x in range(-resolution/2, resolution/2):
			# +x is right, +z is down
			
			var f_width = float(resolution)
			
			var uv_ul = Vector2( x/f_width + 0.5, z/f_width + 0.5 ) * matScaleFactor
			var vert_ul = Vector3(x, 0, z) * scaleFactor
			
			var uv_ur = Vector2( (x+1)/f_width + 0.5, z/f_width + 0.5 ) * matScaleFactor
			var vert_ur = Vector3(x+1, 0, z) * scaleFactor
			
			var uv_lr = Vector2( (x+1)/f_width + 0.5, (z+1)/f_width + 0.5 ) * matScaleFactor
			var vert_lr = Vector3(x+1, 0, z+1) * scaleFactor
			
			var uv_ll = Vector2( x/f_width + 0.5, (z+1)/f_width + 0.5 ) * matScaleFactor
			var vert_ll = Vector3(x, 0, z+1) * scaleFactor
			
#			print("meshp %d,%d: " % [x,z], vert_ul, uv_ul)
			
			surfTool.add_uv(uv_ul)
			surfTool.add_vertex(vert_ul)
			surfTool.add_uv(uv_ur)
			surfTool.add_vertex(vert_ur)
			surfTool.add_uv(uv_lr)
			surfTool.add_vertex(vert_lr)
			
			surfTool.add_uv(uv_lr)
			surfTool.add_vertex(vert_lr)
			surfTool.add_uv(uv_ll)
			surfTool.add_vertex(vert_ll)
			surfTool.add_uv(uv_ul)
			surfTool.add_vertex(vert_ul)
	  
	surfTool.generate_normals()
	surfTool.index()
	  
	surfTool.commit(mesh)
	  
	surfTool.set_material(mat)
	
	self.set_mesh(mesh)
	self.set_surface_material(0, mat)

#func _physics_process(delta):
#	var camera = $'../Camera'
#	if camera:
#		var camera_pos = camera.translation
#		translation.x = camera_pos.x 
#		translation.z = camera_pos.z
