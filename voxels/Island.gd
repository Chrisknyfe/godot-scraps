extends KinematicBody

class_name Island

enum SIDE {LEFT, RIGHT, UP, DOWN, FORWARD, BACK}

export var material : Material
export var cull_backfaces : bool = true

var _threads = []

var target_point : Vector3 = Vector3.ZERO
var target_rot : Vector3 = Vector3.ZERO
var speed_slide_max = 10.0
var speed_slide_min = 1.0
var speed_rot : int = 1

func _add_mesh_face(st, side: int, offset: Vector3, uv: Rect2):
	var normlut = {
		SIDE.RIGHT: Vector3.RIGHT,
		SIDE.LEFT: Vector3.LEFT,
		SIDE.UP: Vector3.UP,
		SIDE.DOWN: Vector3.DOWN,
		SIDE.BACK: Vector3.BACK,
		SIDE.FORWARD: Vector3.FORWARD,
	}
	var uvlut = {
		SIDE.RIGHT: [
			Vector2(1.0, 1.0),
			Vector2(0.0, 1.0),
			Vector2(1.0, 0.0),
			Vector2(0.0, 0.0),
		],
		SIDE.LEFT: [
			Vector2(1.0, 1.0),
			Vector2(0.0, 1.0),
			Vector2(1.0, 0.0),
			Vector2(0.0, 0.0),
		],
		SIDE.UP: [
			Vector2(0.0, 1.0),
			Vector2(0.0, 0.0),
			Vector2(1.0, 1.0),
			Vector2(1.0, 0.0),
		],
		SIDE.DOWN: [
			Vector2(1.0, 0.0),
			Vector2(1.0, 1.0),
			Vector2(0.0, 0.0),
			Vector2(0.0, 1.0),
		],
		SIDE.BACK: [
			Vector2(1.0, 0.0),
			Vector2(1.0, 1.0),
			Vector2(0.0, 0.0),
			Vector2(0.0, 1.0),
		],
		SIDE.FORWARD: [
			Vector2(0.0, 1.0),
			Vector2(0.0, 0.0),
			Vector2(1.0, 1.0),
			Vector2(1.0, 0.0),
		],
	}
	var vertslut = {
		SIDE.RIGHT: [
			Vector3(0.5, -0.5, -0.5),
			Vector3(0.5, -0.5, 0.5),
			Vector3(0.5, 0.5, -0.5),
			Vector3(0.5, 0.5, 0.5),
		],
		SIDE.LEFT: [
			Vector3(-0.5, -0.5, 0.5),
			Vector3(-0.5, -0.5, -0.5),
			Vector3(-0.5, 0.5, 0.5),
			Vector3(-0.5, 0.5, -0.5),
		],
		SIDE.UP: [
			Vector3(-0.5, 0.5, 0.5),
			Vector3(-0.5, 0.5, -0.5),
			Vector3(0.5, 0.5, 0.5),
			Vector3(0.5, 0.5, -0.5),
		],
		SIDE.DOWN: [
			Vector3(-0.5, -0.5, -0.5),
			Vector3(-0.5, -0.5, 0.5),
			Vector3(0.5, -0.5, -0.5),
			Vector3(0.5, -0.5, 0.5),
		],
		SIDE.BACK: [
			Vector3(0.5, 0.5, 0.5),
			Vector3(0.5, -0.5, 0.5),
			Vector3(-0.5, 0.5, 0.5),
			Vector3(-0.5, -0.5, 0.5),
		],
		SIDE.FORWARD: [
			Vector3(0.5, -0.5, -0.5),
			Vector3(0.5, 0.5, -0.5),
			Vector3(-0.5, -0.5, -0.5),
			Vector3(-0.5, 0.5, -0.5),
		],
	}
	
	var verts = vertslut[side]
	var uvs = uvlut[side]
	var norm = normlut[side]
	
	st.add_uv((uvs[0] * uv.size) + uv.position)
	st.add_vertex(verts[0] + offset)
	st.add_uv((uvs[1] * uv.size) + uv.position)
	st.add_vertex(verts[1] + offset)
	st.add_uv((uvs[2] * uv.size) + uv.position)
	st.add_vertex(verts[2] + offset)
	
	st.add_uv((uvs[1] * uv.size) + uv.position)
	st.add_vertex(verts[1] + offset)
	st.add_uv((uvs[3] * uv.size) + uv.position)
	st.add_vertex(verts[3] + offset)
	st.add_uv((uvs[2] * uv.size) + uv.position)
	st.add_vertex(verts[2] + offset)

func _make_viewmodel(dummy_arg):
	
	var start_time = OS.get_ticks_msec()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(BlockTypeLibrary.material)
	#var offset = Vector3(0,0,0)
	
	for coord in $BlockDb.blocks:
		var block_id = $BlockDb.blocks[coord]
		var blocktype = BlockTypeLibrary.get_block_type_by_id(block_id)
		if $BlockDb.isBlockSolid(coord):
			var uv: Rect2 = blocktype.uv
			if self.cull_backfaces:
				if !$BlockDb.isBlockSolid(coord + Vector3.LEFT):
					_add_mesh_face(st, SIDE.LEFT, coord, uv)
				if !$BlockDb.isBlockSolid(coord + Vector3.RIGHT):
					_add_mesh_face(st, SIDE.RIGHT, coord, uv)
				if !$BlockDb.isBlockSolid(coord + Vector3.UP):
					_add_mesh_face(st, SIDE.UP, coord, uv)
				if !$BlockDb.isBlockSolid(coord + Vector3.DOWN):
					_add_mesh_face(st, SIDE.DOWN, coord, uv)
				if !$BlockDb.isBlockSolid(coord + Vector3.FORWARD):
					_add_mesh_face(st, SIDE.FORWARD, coord, uv)
				if !$BlockDb.isBlockSolid(coord + Vector3.BACK):
					_add_mesh_face(st, SIDE.BACK, coord, uv)
			else:
				_add_mesh_face(st, SIDE.LEFT, coord, uv)
				_add_mesh_face(st, SIDE.RIGHT, coord, uv)
				_add_mesh_face(st, SIDE.UP, coord, uv)
				_add_mesh_face(st, SIDE.DOWN, coord, uv)
				_add_mesh_face(st, SIDE.FORWARD, coord, uv)
				_add_mesh_face(st, SIDE.BACK, coord, uv)
	
	st.generate_normals()
	st.generate_tangents()
	
	# make new mesh
	var mesh = st.commit()
	var mi = MeshInstance.new()
	mi.name = "IslandMesh_new"
	mi.mesh = mesh
	
	# Add new then remove old to prevent model flashing
	add_child(mi)
	
	var oldnode = $IslandMesh
	remove_child(oldnode)
	oldnode.queue_free()
	
	mi.name = "IslandMesh"
	
	
	
	var elapsed_time = OS.get_ticks_msec() - start_time
	print("_make_viewmodel took ", elapsed_time, " ms for ", $BlockDb.size(), " blocks")
	
func _make_viewmodel_threaded():
	var thread = Thread.new()
	thread.start(self, "_make_viewmodel")
	_threads.append(thread)
	
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
		print("shape optimization algo took ", algo_time, " ms")
		
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
	var wood_id: int = BlockTypeLibrary.get_block_type_by_name("wood").id
	var stone_id: int = BlockTypeLibrary.get_block_type_by_name("stone").id
	var blocks = {
		Vector3(0,0,0): wood_id,
	}
	var radius = 3
	for x in range(-radius,radius+1):
		for z in range(-radius,radius+1):
			for y in range(-radius,0):
				blocks[Vector3(x,y,z)] = wood_id
			for y in range(0,radius+1):
				blocks[Vector3(x,y,z)] = stone_id
	
	$BlockDb.blocks = blocks
	
# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_blocks()
	_make_viewmodel(0)
	_clear_phymodel()
	_make_physmodel()
	
	target_point = self.translation
	target_rot = self.rotation
	
func get_block_position_at(global_coord):
	return (self.to_local(global_coord)).round()

func set_block(coord, blocktype):
	$BlockDb.setBlock(coord, blocktype)
	_make_viewmodel_threaded()
	_clear_phymodel()
	_make_physmodel()


func move_to(coord):
	target_point = coord.round()

func _physics_process(delta):
	var curpos = self.translation
	var currot = self.rotation
	var delta_pos = target_point - curpos
	var delta_length = delta_pos.length()
	var delta_normal = delta_pos.normalized()
	if delta_length > 0.125:
		var speed = max(min(speed_slide_max, delta_length), speed_slide_min)
		var move_by = delta_normal * speed
		print("move by: ", move_by, " delta_normal: ", delta_normal)
		move_and_slide(move_by)
	elif delta_length > 0:
		print("Just snap to ", target_point)
		self.translation = target_point


func _on_Island_input_event(camera, event, click_position, click_normal, shape_idx):
	pass # Replace with function body.

