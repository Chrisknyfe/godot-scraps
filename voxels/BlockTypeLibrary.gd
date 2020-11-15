extends Node

const BLOCK_TEXTURE_WIDTH_PX = 32
const TEXMAP_WIDTH_COLS = 8
const TEXMAP_TOTAL_BLOCKS = TEXMAP_WIDTH_COLS * TEXMAP_WIDTH_COLS

var id_count = 0
var by_name = {}
var by_id = {}

# TODO: only 256 textures supported so far on one material
var texmap
var material

func make_texmap():
	var texmapwidth = BLOCK_TEXTURE_WIDTH_PX * TEXMAP_WIDTH_COLS
	texmap = Image.new()
	texmap.create(texmapwidth, texmapwidth, false, Image.FORMAT_RGBA8)
	
	# fill texture map with dev textures (for debugging)
	var img = Image.new()
	img.load("res://dev.png")
	for i in range(TEXMAP_TOTAL_BLOCKS):
		var col: int = i % TEXMAP_WIDTH_COLS
		var row: int = i / TEXMAP_WIDTH_COLS
		var srcrect = Rect2(Vector2.ZERO, img.get_size())
		var destrect = Vector2(col, row) * BLOCK_TEXTURE_WIDTH_PX
		texmap.blit_rect(img, srcrect, destrect)
	return texmap
	

func blit_texture_map():
	texmap = make_texmap()

	for i in range(id_count):
		var col: int = i % TEXMAP_WIDTH_COLS
		var row: int = i / TEXMAP_WIDTH_COLS
		var blocktype = by_id[i]
		var img = Image.new()
		img.load(blocktype.texture_path)
		if img.get_size() != Vector2(32,32):
			push_error("Unsupported image size: " + img.get_size() + " size must be 32x32")
		var srcrect = Rect2(Vector2.ZERO, img.get_size())
		var dest = Vector2(col, row) * BLOCK_TEXTURE_WIDTH_PX
		texmap.blit_rect(img, srcrect, dest)
		blocktype.uv = Rect2(Vector2(col, row) / TEXMAP_WIDTH_COLS, Vector2.ONE / TEXMAP_WIDTH_COLS)
	
	texmap.save_png("user://texmap.png")
	var imgtex = ImageTexture.new()
	imgtex.create_from_image(texmap, ImageTexture.FLAG_REPEAT )
	material = SpatialMaterial.new()
	material.albedo_texture = imgtex

func _ready():
	var air = add_block_type("air")
	air.solid = false
	air.visible = false
	var wood = add_block_type("wood")
	wood.texture_path = "res://wood.png"
	var stone = add_block_type("stone")
	stone.texture_path = "res://lappedstone.png"
	
	blit_texture_map()
	print("BlockTypeLibrary _ready")
	
func add_block_type(name: String):
	if id_count >= 256:
		push_error("Can't add more than 256 BlockTypes so far. Go bug a developer.")
		return null
	var bt = BlockType.new(name, id_count)
	id_count += 1
	if bt.name in by_name:
		push_error("Cannot add BlockType, name " + bt.name + " already in use!")
		return null
	by_name[bt.name] = bt
	by_id[bt.id] = bt
	return bt
	
func get_block_type_by_name(name: String):
	return by_name[name]
	
func get_block_type_by_id(id: int):
	return by_id[id]
	
	
