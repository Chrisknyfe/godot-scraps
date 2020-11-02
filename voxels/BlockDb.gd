extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var blocks = {}

# safe func for getting a block
func getBlock(coord: Vector3):
	if coord in blocks:
		return blocks[coord]
	else:
		return 0
		
func isBlockSolid(coord: Vector3):
	if coord in blocks:
		if blocks[coord] != 0:
			return true
	return false
		
func setBlocks(newblocks):
	for coord in newblocks:
		blocks[coord] = newblocks[coord]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
