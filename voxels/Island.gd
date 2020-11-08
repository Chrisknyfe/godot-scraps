extends Area

class_name Island

enum SIDE {LEFT, RIGHT, TOP, BOTTOM, FRONT, BACK}

enum BLOCKTYPE {AIR, WOOD}

export var material : Material
export var cull_backfaces : bool = true

var _thread

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _add_mesh_face(st, side: int, offset: Vector3):
	var vertslut = {
		SIDE.LEFT: [
			Vector3(0.5, -0.5, -0.5),
			Vector3(0.5, -0.5, 0.5),
			Vector3(0.5, 0.5, -0.5),
			Vector3(0.5, 0.5, 0.5),
		],
		SIDE.RIGHT: [
			Vector3(-0.5, -0.5, 0.5),
			Vector3(-0.5, -0.5, -0.5),
			Vector3(-0.5, 0.5, 0.5),
			Vector3(-0.5, 0.5, -0.5),
		],
		SIDE.TOP: [
			Vector3(-0.5, 0.5, 0.5),
			Vector3(-0.5, 0.5, -0.5),
			Vector3(0.5, 0.5, 0.5),
			Vector3(0.5, 0.5, -0.5),
		],
		SIDE.BOTTOM: [
			Vector3(-0.5, -0.5, -0.5),
			Vector3(-0.5, -0.5, 0.5),
			Vector3(0.5, -0.5, -0.5),
			Vector3(0.5, -0.5, 0.5),
		],
		SIDE.FRONT: [
			Vector3(0.5, 0.5, 0.5),
			Vector3(0.5, -0.5, 0.5),
			Vector3(-0.5, 0.5, 0.5),
			Vector3(-0.5, -0.5, 0.5),
		],
		SIDE.BACK: [
			Vector3(0.5, -0.5, -0.5),
			Vector3(0.5, 0.5, -0.5),
			Vector3(-0.5, -0.5, -0.5),
			Vector3(-0.5, 0.5, -0.5),
		],
	}
	
	var verts = vertslut[side]
	
	st.add_vertex(verts[0] + offset)
	st.add_vertex(verts[1] + offset)
	st.add_vertex(verts[2] + offset)
	
	st.add_vertex(verts[1] + offset)
	st.add_vertex(verts[3] + offset)
	st.add_vertex(verts[2] + offset)

func _make_viewmodel(dummy_arg):
	
	var start_time = OS.get_ticks_msec()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	#var offset = Vector3(0,0,0)
	
	for coord in $BlockDb.blocks:
		if $BlockDb.isBlockSolid(coord):
			if self.cull_backfaces:
				if !$BlockDb.isBlockSolid(coord + Vector3(1, 0, 0)):
					_add_mesh_face(st, SIDE.LEFT, coord)
				if !$BlockDb.isBlockSolid(coord + Vector3(-1, 0, 0)):
					_add_mesh_face(st, SIDE.RIGHT, coord)
				if !$BlockDb.isBlockSolid(coord + Vector3(0, 1, 0)):
					_add_mesh_face(st, SIDE.TOP, coord)
				if !$BlockDb.isBlockSolid(coord + Vector3(0, -1, 0)):
					_add_mesh_face(st, SIDE.BOTTOM, coord)
				if !$BlockDb.isBlockSolid(coord + Vector3(0, 0, 1)):
					_add_mesh_face(st, SIDE.FRONT, coord)
				if !$BlockDb.isBlockSolid(coord + Vector3(0, 0, -1)):
					_add_mesh_face(st, SIDE.BACK, coord)
			else:
				_add_mesh_face(st, SIDE.LEFT, coord)
				_add_mesh_face(st, SIDE.RIGHT, coord)
				_add_mesh_face(st, SIDE.TOP, coord)
				_add_mesh_face(st, SIDE.BOTTOM, coord)
				_add_mesh_face(st, SIDE.FRONT, coord)
				_add_mesh_face(st, SIDE.BACK, coord)
	
	st.generate_normals()
	st.generate_tangents()
	
	var mesh = st.commit()
	var mi = MeshInstance.new()
	mi.name = "IslandMesh"
	mi.mesh = mesh
	
	var oldnode = $IslandMesh
	remove_child(oldnode)
	oldnode.queue_free()
	
	add_child(mi)
	
	
	var elapsed_time = OS.get_ticks_msec() - start_time
	print("_make_viewmodel took ", elapsed_time, " ms for ", $BlockDb.size(), " blocks")
	
func _make_viewmodel_threaded():
	_thread = Thread.new()
	_thread.start(self, "_make_viewmodel")
	
func _add_phys_block(center, extents=Vector3.ONE/2):
	var collider = CollisionShape.new()
	collider.shape = BoxShape.new()
	collider.shape.extents = extents
	collider.transform.origin = center
	add_child(collider)
	
func _get_optimal_phys_shapes():
	# dict of all physical blocks, to be consumed
	var physblocks = {}
	for coord in $BlockDb.blocks:
		if $BlockDb.isBlockSolid(coord):
			physblocks[coord] = 1
	# list of all physical blocks, to be iterated over
	var physlist = physblocks.keys()
	
	# final list of spans, to be converted to collision shapes
	var shapes = []
	for coord in physlist:
		if coord in physblocks:
			var span = [coord, coord]
			physblocks.erase(coord)
			# expand positive x
			while true:
				var next = span[1] + Vector3.RIGHT
				if next in physblocks:
					span[1] = next
					physblocks.erase(next)
				else:
					break
			# expand negative x
			while true:
				var next = span[0] + Vector3.LEFT
				if next in physblocks:
					span[0] = next
					physblocks.erase(next)
				else:
					break
			
			# expand positive y
			while true:
				var next = span[1] + Vector3.UP
				
				var can_expand = true
				for x in range(span[0].x, next.x + 1):
					var cur = Vector3(x, next.y, next.z)
					if not cur in physblocks:
						can_expand = false
				
				if can_expand:
					span[1] = next
					for x in range(span[0].x, next.x + 1):
						var cur = Vector3(x, next.y, next.z)
						physblocks.erase(cur)
				else:
					break
					
			# expand negative y
			while true:
				var next = span[0] + Vector3.DOWN
				
				var can_expand = true
				for x in range(next.x, span[1].x + 1):
					var cur = Vector3(x, next.y, next.z)
					if not cur in physblocks:
						can_expand = false
				
				if can_expand:
					span[0] = next
					for x in range(next.x, span[1].x + 1):
						var cur = Vector3(x, next.y, next.z)
						physblocks.erase(cur)
				else:
					break
					
			# expand positive z
			while true:
				var next = span[1] + Vector3.BACK
				
				var can_expand = true
				for x in range(span[0].x, next.x + 1):
					for y in range(span[0].y, next.y + 1):
						var cur = Vector3(x, y, next.z)
						if not cur in physblocks:
							can_expand = false
				
				if can_expand:
					span[1] = next
					for x in range(span[0].x, next.x + 1):
						for y in range(span[0].y, next.y + 1):
							var cur = Vector3(x, y, next.z)
							physblocks.erase(cur)
				else:
					break
			
			# expand positive z
			while true:
				var next = span[0] + Vector3.FORWARD
				
				var can_expand = true
				for x in range(next.x, span[1].x + 1):
					for y in range(next.y, span[1].y + 1):
						var cur = Vector3(x, y, next.z)
						if not cur in physblocks:
							can_expand = false
				
				if can_expand:
					span[0] = next
					for x in range(next.x, span[1].x + 1):
						for y in range(next.y, span[1].y + 1):
							var cur = Vector3(x, y, next.z)
							physblocks.erase(cur)
				else:
					break
					
			# shape: [0]: center [1]: extents
			var shape = [(span[1] + span[0]) / 2, (Vector3.ONE + span[1] - span[0]) / 2]
			shapes.append(shape)
	return shapes
	
func _make_physmodel():
	var start_time = OS.get_ticks_msec()
	if $BlockDb.size() == 0:
		print("empty island")
		_add_phys_block(Vector3.ZERO)
	else:
		var shapes = _get_optimal_phys_shapes()
					
		var algo_time = OS.get_ticks_msec() - start_time
		print("algo took ", algo_time, " ms")
		
		for shape in shapes:
			_add_phys_block(shape[0], shape[1])
		
	var elapsed_time = OS.get_ticks_msec() - start_time
	print("_make_physmodel took ", elapsed_time, " ms for ", $BlockDb.size(), " blocks")
		
func _clear_phymodel():
	for c in get_children():
		if c is CollisionShape:
			remove_child(c)
			c.queue_free()
	
	
func _generate_blocks():
	var blocks = {
		Vector3(0,0,0): BLOCKTYPE.WOOD,
	}
	var radius = 8
	for x in range(-radius,radius):
		for y in range(-radius,radius):
			for z in range(-radius,radius):
				blocks[Vector3(x,y,z)] = BLOCKTYPE.WOOD
	
	$BlockDb.blocks = blocks
	
# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_blocks()
	_make_viewmodel(0)
	_clear_phymodel()
	_make_physmodel()
	print("LEFT: ", Vector3.LEFT)
	print("RIGHT: ", Vector3.RIGHT)
	print("UP: ", Vector3.UP)
	print("DOWN: ", Vector3.DOWN)
	print("FORWARD: ", Vector3.FORWARD)
	print("BACK: ", Vector3.BACK)
	
func get_block_position_at(global_coord):
	return (self.to_local(global_coord)).round()

func set_block(coord, blocktype):
	$BlockDb.setBlock(coord, blocktype)
	_make_viewmodel_threaded()
	_clear_phymodel()
	_make_physmodel()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotate(Vector3.RIGHT, 0.05*delta)
	self.translate(Vector3.RIGHT * 0.25 * delta)


func _on_Island_input_event(camera, event, click_position, click_normal, shape_idx):
	pass # Replace with function body.
