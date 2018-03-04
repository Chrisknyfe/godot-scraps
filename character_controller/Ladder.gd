extends Area

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Ladder_body_entered(body):
#	print("body is: ", body.get_filename())
	# This check could be better with some kind of entity type system. I dunno.
#	if body.get_filename().ends_with("Player.tscn"):
	if body.name == "Player":
		print("A player entered a ladder!")
		body.climbing = true


func _on_Ladder_body_exited(body):
#	print("body is: ", body.get_filename())
#	if body.get_filename().ends_with("Player.tscn"):
	if body.name == "Player":
		print("A player left a ladder!")
		body.climbing = false
