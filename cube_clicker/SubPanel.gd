extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var arr = [1,2,3]
var arr2

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
#	arr2 = Array()
#	for item in arr:
#		arr2.append(item)
	arr2 = [] + arr
	$Label.text = "arr: " + str(arr2)
	

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	$Label.text = "arr: " + str(arr2)


func _on_Button_pressed():
	arr2.append(0)
	$Label.text = "arr: " + str(arr2)