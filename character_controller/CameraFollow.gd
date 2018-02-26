extends Spatial

signal update_angle

var pos_target = Vector3(0,0,0)
var rot_target = Vector3(0,0,0)

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	rot_target = Vector3(rotation)
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _input(event):
	if event is InputEventMouseMotion:
		rot_target.y -= deg2rad(event.relative.x)/3
		rot_target.x -= deg2rad(event.relative.y)/3
		
		# clamp vertical mouselook
		rot_target.x = max(rot_target.x, -PI/2.0)
		rot_target.x = min(rot_target.x, PI/2.0)
		

func _physics_process(delta):
	
	# Make the camera follow the player
	translation = translation.linear_interpolate(pos_target, 0.3)
	
	rotation = rotation.linear_interpolate(rot_target, 0.3)
	
	emit_signal("update_angle", rotation.y)
