extends Reference

class_name BlockType

var name: String = "unknown"
var id: int = 0
var solid: bool = true
var visible: bool = true
var texture_path: String = "res://dev.png" 
var uv: Rect2 = Rect2(Vector2.ZERO, Vector2.ONE)

func _init(name: String, id: int):
	self.name = name
	self.id = id
