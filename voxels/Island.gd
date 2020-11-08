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
	
	$IslandMesh.mesh = st.commit()
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
	
func _make_physmodel():
	var start_time = OS.get_ticks_msec()
	var physblocks = {}
	if $BlockDb.size() == 0:
		print("empty island")
		physblocks[Vector3.ZERO] = 1
	for coord in $BlockDb.blocks:
		if $BlockDb.isBlockSolid(coord):
			# only place block if it's an exterior block
			if  !$BlockDb.isBlockSolid(coord + Vector3(1, 0, 0)) or \
				!$BlockDb.isBlockSolid(coord + Vector3(-1, 0, 0)) or \
				!$BlockDb.isBlockSolid(coord + Vector3(0, 1, 0)) or \
				!$BlockDb.isBlockSolid(coord + Vector3(0, -1, 0)) or \
				!$BlockDb.isBlockSolid(coord + Vector3(0, 0, 1)) or \
				!$BlockDb.isBlockSolid(coord + Vector3(0, 0, -1)):
				physblocks[coord] = 1
				
	var algo_time = OS.get_ticks_msec() - start_time
	print("algo took ", algo_time, " ms")
	for coord in physblocks:
		_add_phys_block(coord)
		
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
		Vector3(1,0,0): BLOCKTYPE.WOOD,
		Vector3(0,1,0): BLOCKTYPE.WOOD,
		Vector3(0,0,1): BLOCKTYPE.WOOD,
		Vector3(1,1,1): BLOCKTYPE.WOOD,
	}
	for x in range(0,8):
		for y in range(0,8):
			for z in range(0,8):
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
	return (global_coord - self.translation).round()

func set_block(coord, blocktype):
	$BlockDb.setBlock(coord, blocktype)
	_make_viewmodel_threaded()
	_clear_phymodel()
	_make_physmodel()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Island_input_event(camera, event, click_position, click_normal, shape_idx):
	pass # Replace with function body.
