extends Node

var blocks = {}

const AIR_ID = 0

# safe func for getting a block
func getBlock(coord: Vector3):
	if coord in blocks:
		return blocks[coord]
	else:
		return AIR_ID
		
func isBlockVisible(coord: Vector3):
	return isBlockSolid(coord)
		
func isBlockSolid(coord: Vector3):
	if coord in blocks:
		var blocktype = BlockTypeLibrary.get_block_type_by_id(blocks[coord])
		return blocktype.solid
	return false
		
func setBlocks(newblocks):
	for coord in newblocks:
		blocks[coord] = newblocks[coord]
		
func setBlock(coord, blockid):
	if blockid == AIR_ID:
		blocks.erase(coord)
	else:
		blocks[coord] = blockid
		
func size():
	return blocks.size()

