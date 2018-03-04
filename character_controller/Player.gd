extends KinematicBody

# Constants
const GRAVITY = 9.8 * 3
const WALK_SPEED = 10
const SPRINT_SPEED = 20
const SNEAK_SPEED = 5
const ACCEL = 4
const DEACCEL = 8
const JUMP_HEIGHT = 15
const FLY_SPEED = 20
const FLY_ACCEL = 4
const CLIMB_SPEED = 6
const MAX_SLOPE_ANGLE = 35 # degrees
const MAX_STAIR_SLOPE = 20
const STAIR_JUMP_VEL = 0.2
const STAIR_JUMP_STEP = 0.2 # proportional to stair height

# externally controllable vars
var move_direction = Vector3()
var look_direction = Vector3()
var climbing = false
var flying = false
var sprinting = false
var jumping = false
var crouching = false

# internal vars
var velocity  = Vector3() # smoothed velocity
var has_ground_contact = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

	

func _physics_process(delta):
	aim(delta)
	if flying:
		fly(delta, FLY_SPEED)
	elif climbing:
		climb(delta, CLIMB_SPEED)
	elif crouching:
		walk(delta, SNEAK_SPEED)
	elif sprinting:
		walk(delta, SPRINT_SPEED)
	else:
		walk(delta, WALK_SPEED)
			
func aim(delta):
	$Head.rotation = look_direction
	
func climb(delta, speed):
	has_ground_contact = false
	var temp_direction = move_direction
	
	# jump/crouch to go up and down the ladder
	if jumping:
		temp_direction += Vector3(0, 1, 0)
	if crouching:
		temp_direction += Vector3(0, -1, 0)
	
	# Orient the ClimbUpper
	var cu_dir = temp_direction
	cu_dir.y = 0
	cu_dir = cu_dir.normalized() * 0.45 # fixed positioning based on body size
	$ClimbUpper.translation.x = cu_dir.x
	$ClimbUpper.translation.z = cu_dir.z
	$ClimbUpper.cast_to = cu_dir.normalized() * 0.2 # fixed distance from body
	
	# Go up if we're pushing up against something while climbing
	if (cu_dir.length() > 0) and $ClimbUpper.is_colliding():
		print("Pushing up the ladder!")
		temp_direction += Vector3(0, 1, 0)

	# normalize to player's fly speed
	temp_direction = temp_direction.normalized()
	temp_direction = temp_direction * speed
	
	velocity = velocity.linear_interpolate(temp_direction, FLY_ACCEL * delta)
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
func fly(delta, speed):
	has_ground_contact = false
	var temp_direction = move_direction
	# space to go up a bit
	if jumping:
		temp_direction += Vector3(0, 1, 0)
	if crouching:
		temp_direction += Vector3(0, -1, 0)
	# normalize to player's fly speed
	temp_direction = temp_direction.normalized()
	temp_direction = temp_direction * speed
	
	velocity = velocity.linear_interpolate(temp_direction, FLY_ACCEL * delta)
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
func walk(delta, speed):
	# Clip y direction and normalize to player's walk speed
	var temp_direction = move_direction
	temp_direction.y = 0
	temp_direction = temp_direction.normalized()
	temp_direction = temp_direction * speed
	# Maintain gravity
	temp_direction.y = velocity.y
	
	# Determine ground contact using our tail
	if is_on_floor():
		has_ground_contact = true
	elif !$Tail.is_colliding():
		has_ground_contact = false
	
	# decelerate faster
	var accel = ACCEL
	if temp_direction.dot(velocity) > 0:
		accel = DEACCEL
	
	velocity = velocity.linear_interpolate(temp_direction, accel * delta)
	
	# apply gravity; on slopes, only apply gravity if we can slide down the slope.
	if has_ground_contact:
		var cn = $Tail.get_collision_normal()
		var floor_angle = rad2deg(acos(cn.dot(Vector3(0,1,0))))
		if floor_angle > MAX_SLOPE_ANGLE:
			velocity.y -= GRAVITY * delta
	else:
		velocity.y -= GRAVITY * delta
	
	# Step up on stairs.
	# They must be of a certain angle and height.
	# The player will step up a fixed amount based on stair size.
	var sc_dir = temp_direction
	sc_dir.y = 0
	sc_dir = sc_dir.normalized() * 0.55
	$StairCatcher.translation.x = sc_dir.x
	$StairCatcher.translation.z = sc_dir.z
	if (sc_dir.length() > 0) and $StairCatcher.is_colliding():
		var stair_normal = $StairCatcher.get_collision_normal()
		var stair_angle = rad2deg(acos(stair_normal.dot(Vector3(0,1,0))))
		if stair_angle < MAX_STAIR_SLOPE:
			if velocity.y < 0:
				velocity.y = 0
			velocity.y += STAIR_JUMP_VEL
			var stairheight = 1.5 - (get_global_transform().origin.y - $StairCatcher.get_collision_point().y)
			print("Hit stair of height: ", stairheight)
			move_and_collide(Vector3(0, stairheight * (1+STAIR_JUMP_STEP), 0))
			has_ground_contact = false
	
	# Perform jumping
	if has_ground_contact and jumping:
		velocity.y = JUMP_HEIGHT
		has_ground_contact = false
	
	# Stick to floor a bit stronger if we're close but hit a bump or a slope
	if has_ground_contact and !is_on_floor():
		move_and_collide(Vector3(0, -1, 0))
		
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
#
	
			
			