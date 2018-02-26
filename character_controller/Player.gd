extends KinematicBody

signal update_position

var speed = 600
var direction = Vector3() # directed by posessing spirit
var gravity = -9.8
var velocity  = Vector3()
var look_angle_target = 0


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

	

func _physics_process(delta):
	# Clip y direction and normalize to player's speed
	direction.y = 0
	direction = direction.normalized()
	direction = direction * speed * delta
	
	
#	velocity = velocity.linear_interpolate(direction, 0.5)
#
#	if velocity.y > 0:
#		gravity = -20
#	else:
#		gravity = -30
	
	velocity.y += gravity * delta
	velocity.x = direction.x
	velocity.z = direction.z
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
#
#	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
#		velocity.y = 10
	
	emit_signal("update_position", translation)
	
#	var hitcount = get_slide_count()
#	if hitcount > 0:
#		var collision = get_slide_collision(0)
#		if collision.collider is RigidBody:
#			collision.collider.apply_impulse(collision.position, -collision.normal)
			
			
			