extends Area

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	rotate_x(deg2rad(30 * delta))
	rotate_y(deg2rad(30 * delta))

func _on_Box_body_entered( body ):
	if body is KinematicBody:
		queue_free()