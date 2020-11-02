extends Spatial

enum SIDE {LEFT, RIGHT, TOP, BOTTOM, FRONT, BACK}

enum SIDEAXIS {POS_X, NEG_X, POS_Y, NEG_Y, POS_Z, NEG_Z}

enum BLOCKTYPE {AIR, WOOD}

export var material : Material

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func add_face(st, side: int, offset: Vector3):
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
	
	print(verts[0] + offset)
	
	st.add_vertex(verts[0] + offset)
	st.add_vertex(verts[1] + offset)
	st.add_vertex(verts[2] + offset)
	
	st.add_vertex(verts[1] + offset)
	st.add_vertex(verts[3] + offset)
	st.add_vertex(verts[2] + offset)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var cull_backfaces: bool = true
	
	var blocks = {
		Vector3(0,0,0): 1,
		Vector3(1,0,0): 1,
		Vector3(0,1,0): 1,
		Vector3(0,0,1): 1,
		Vector3(1,1,1): 1,
	}
	$BlockDb.blocks = blocks
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	#var offset = Vector3(0,0,0)
	
	
	for coord in $BlockDb.blocks:
		print(coord, ":", $BlockDb.getBlock(coord))
		var offset = coord
		if cull_backfaces:
			if !$BlockDb.isBlockSolid(coord + Vector3(1, 0, 0)):
				add_face(st, SIDE.LEFT, offset)
			if !$BlockDb.isBlockSolid(coord + Vector3(-1, 0, 0)):
				add_face(st, SIDE.RIGHT, offset)
			if !$BlockDb.isBlockSolid(coord + Vector3(0, 1, 0)):
				add_face(st, SIDE.TOP, offset)
			if !$BlockDb.isBlockSolid(coord + Vector3(0, -1, 0)):
				add_face(st, SIDE.BOTTOM, offset)
			if !$BlockDb.isBlockSolid(coord + Vector3(0, 0, 1)):
				add_face(st, SIDE.FRONT, offset)
			if !$BlockDb.isBlockSolid(coord + Vector3(0, 0, -1)):
				add_face(st, SIDE.BACK, offset)
		else:
			add_face(st, SIDE.LEFT, offset)
			add_face(st, SIDE.RIGHT, offset)
			add_face(st, SIDE.TOP, offset)
			add_face(st, SIDE.BOTTOM, offset)
			add_face(st, SIDE.FRONT, offset)
			add_face(st, SIDE.BACK, offset)
	
	st.generate_normals()
	st.generate_tangents()
	
	$IslandMesh.mesh = st.commit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
