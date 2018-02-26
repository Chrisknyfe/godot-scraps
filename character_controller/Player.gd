extends KinematicBody


var gravity = 9.8 * 3
const WALK_SPEED = 20
const WALK_ACCEL = 4
const JUMP_HEIGHT = 15

var speed = 600
var direction = Vector3() # directed by posessing spirit
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
	walk(delta)
	
func walk(delta):
	# Clip y direction and normalize to player's speed
	direction.y = 0
	direction = direction.normalized()
	direction = direction * WALK_SPEED
	
	direction.y = velocity.y
	velocity = velocity.linear_interpolate(direction, WALK_ACCEL * delta)
	velocity.y -= gravity * delta
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
#
#	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
#		velocity.y = 10
	
			
			