tool 
extends MeshInstance

export(int)			var resolution = 100
export(float) 		var scaleFactor = 0.10
export(float)		var quadraticFactor = 0.09
export(float)		var matScaleFactor = 1.0
export(bool)		var follow_camera = true
#export(float)		var follow_accel = 0.5
export(bool)		var refresh_editor_mesh = false

func quadratic_increase(x):
	var y = quadraticFactor*x*x + (1.0-quadraticFactor)*abs(x)
	if x < 0:
		y = -y
	return y
	

# Due to the "tool" keyword at the top of this file
# this function already executes in the editor
func _ready():
	build_mesh()
	
func build_mesh():
	
	var mat = get_surface_material(0)
	var surfTool = SurfaceTool.new()
	var mesh = Mesh.new()
	  
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in range(-resolution/2, resolution/2):
		for x in range(-resolution/2, resolution/2):
			# +x is right, +z is down
			
			var f_width = float(resolution)
			
			# Transform vertex coords to get more sparse farther from the player
			var coord_ul = Vector2(quadratic_increase(x),quadratic_increase(z))
			var coord_ur = Vector2(quadratic_increase(x+1),quadratic_increase(z))
			var coord_lr = Vector2(quadratic_increase(x+1), quadratic_increase(z+1))
			var coord_ll = Vector2(quadratic_increase(x),quadratic_increase(z+1))
			
			var uv_ul = (coord_ul / f_width + Vector2(0.5, 0.5)) * matScaleFactor
			var vert_ul = Vector3(coord_ul.x, 0, coord_ul.y) * scaleFactor
			
			var uv_ur = (coord_ur / f_width + Vector2(0.5, 0.5)) * matScaleFactor
			var vert_ur = Vector3(coord_ur.x, 0, coord_ur.y) * scaleFactor
			
			var uv_lr = (coord_lr / f_width + Vector2(0.5, 0.5)) * matScaleFactor
			var vert_lr = Vector3(coord_lr.x, 0, coord_lr.y) * scaleFactor
			
			var uv_ll = (coord_ll / f_width + Vector2(0.5, 0.5)) * matScaleFactor
			var vert_ll = Vector3(coord_ll.x, 0, coord_ll.y) * scaleFactor
			
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

func _physics_process(delta):
	if !Engine.is_editor_hint() and follow_camera:
		var camera = $'../Camera'
		if camera:
			var camera_pos = camera.translation
			translation.x = camera_pos.x 
			translation.z = camera_pos.z
			
	#		var target_pos = translation
	#		target_pos = target_pos.linear_interpolate(camera_pos, follow_accel * delta)
	#		translation.x = target_pos.x 
	#		translation.z = target_pos.z
	elif refresh_editor_mesh:
		refresh_editor_mesh = false
		print("Rebuilding ocean mesh!")		
		build_mesh()
