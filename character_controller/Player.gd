extends KinematicBody

# Constants
const GRAVITY = 9.8 * 3
const WALK_SPEED = 10
const SPRINT_SPEED = 40
const ACCEL = 4
const DEACCEL = 8
const JUMP_HEIGHT = 15
const FLY_SPEED = 20
const FLY_ACCEL = 4

# externally controllable vars
var direction = Vector3()
var flying = false
var sprinting = false
var jumping = false

# internal vars
var velocity  = Vector3() # smoothed velocity


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

	

func _physics_process(delta):
	if flying:
		fly(delta)
	else:
		if sprinting:
			walk(delta, SPRINT_SPEED)
		else:
			walk(delta, WALK_SPEED)
	
func fly(delta):
	var temp_direction = direction
	# space to go up a bit
	if Input.is_key_pressed(KEY_SPACE):
		temp_direction += Vector3(0, 1, 0)
	# normalize to player's fly speed
	temp_direction = temp_direction.normalized()
	temp_direction = temp_direction * FLY_SPEED
	
	velocity = velocity.linear_interpolate(temp_direction, FLY_ACCEL * delta)
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
func walk(delta, speed):
	var temp_direction = direction
	# Clip y direction and normalize to player's walk speed
	temp_direction.y = 0
	temp_direction = temp_direction.normalized()
	temp_direction = temp_direction * speed
	
	temp_direction.y = velocity.y
	
	# decelerate faster
	var accel = ACCEL
	if temp_direction.dot(velocity) > 0:
		accel = DEACCEL
	
	velocity = velocity.linear_interpolate(temp_direction, accel * delta)
	
	velocity.y -= GRAVITY * delta
	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
		velocity.y = JUMP_HEIGHT
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
#
	
			
			