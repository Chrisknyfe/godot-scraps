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
		
func isBlockVisible(coord: Vector3):
	return isBlockSolid(coord)
		
func isBlockSolid(coord: Vector3):
	if coord in blocks:
		if blocks[coord] != 0:
			return true
	return false
		
func setBlocks(newblocks):
	for coord in newblocks:
		blocks[coord] = newblocks[coord]
		
func setBlock(coord, blocktype):
	blocks[coord] = blocktype
		
func size():
	return blocks.size()

