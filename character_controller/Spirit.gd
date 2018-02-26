extends Spatial

signal update_angle

const FLY_SPEED = 20
const PRINT_DELAY = 0.1

var host = null
var pos_target = Vector3(0,0,0)
var rot_target = Vector3(0,0,0)
var velocity_target = Vector3(0,0,0)

var last_print_time = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	rot_target = Vector3(rotation)

func posess(entity):
	if entity != null:
		host = weakref(entity)
	else:
		host = null;
		
func get_host():
	if host != null and host.get_ref():
		return host.get_ref()
	return null

func is_posessing():
	return host != null and host.get_ref()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _input(event):
	# Mouse movement changes rotation target
	if event is InputEventMouseMotion:
		rot_target.y -= deg2rad(event.relative.x)/3
		rot_target.x -= deg2rad(event.relative.y)/3

		# clamp vertical mouselook
		rot_target.x = max(rot_target.x, -PI/2.0)
		rot_target.x = min(rot_target.x, PI/2.0)

		# wrap horizontal mouselook
		if rot_target.y > PI:
			rot_target.y -= 2*PI
		if rot_target.y < -PI:
			rot_target.y += 2*PI

func time_to_print():
	var curr_time = OS.get_ticks_msec () / 1000.0
	if curr_time > (last_print_time + PRINT_DELAY):
		last_print_time = curr_time
		return true
	return false

func _physics_process(delta):

	# Horizontal movement based on WASD
	var direction_target = Vector3(0, 0, 0)
	if Input.is_action_pressed("ui_left"):
		direction_target += Vector3(-1, 0, 0).rotated(Vector3(0, 1, 0), rot_target.y)
	if Input.is_action_pressed("ui_right"):
		direction_target += Vector3(1, 0, 0).rotated(Vector3(0, 1, 0), rot_target.y)
	if Input.is_action_pressed("ui_up"):
		direction_target += Vector3(0, 0, -1).rotated(Vector3(1, 0, 0), rot_target.x).rotated(Vector3(0, 1, 0), rot_target.y)
	if Input.is_action_pressed("ui_down"):
		direction_target += Vector3(0, 0, 1).rotated(Vector3(1, 0, 0), rot_target.x).rotated(Vector3(0, 1, 0), rot_target.y)
	direction_target = direction_target.normalized()

	if is_posessing():
		var h = get_host()
		h.direction = direction_target
		# Make the camera follow the player
		translation = h.translation
#		rotation = rot_target
		
	else:
		# Move based on our own desired velocity
		direction_target = direction_target * FLY_SPEED * delta
		velocity_target = velocity_target.linear_interpolate(direction_target, 0.5)
		global_translate(velocity_target)
	
	# rotate interpolated
#	rotation = rot_target
	var target = Transform()
	target = target.rotated(Vector3(1,0,0), rot_target.x)
	target = target.rotated(Vector3(0,1,0), rot_target.y)
	target = target.rotated(Vector3(0,0,1), rot_target.z)
	target.origin = global_transform.origin
	global_transform = global_transform.interpolate_with(target, 0.5)

	if time_to_print():
		print("rot: ", rot_target, "dir: ", direction_target)

#	emit_signal("update_angle", rotation.y)
