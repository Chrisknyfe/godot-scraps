extends Area

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var speed = 1
var direction = Vector3()
var spin = Vector3()
var limit_distance = 2.0
var limit_speed = 20
var hit = false
var lose = false
var clicks = 0

func new_random_vector3(width):
	var newvec = Vector3()
	newvec.x = rand_range(-width,width)
	newvec.y = rand_range(-width,width)
	newvec.z = rand_range(-width,width)
	return newvec

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	reset()
	

func reset_speed():
	direction = new_random_vector3(1)
	direction = direction.normalized()
	spin = new_random_vector3(10)
	speed = 1
	translation = Vector3(0,0,0)
	
func reset():
	reset_speed()
	hit = false
	lose = false
	clicks = 0
	
func collide_common(delta):
	direction += new_random_vector3(0.1)
	direction = direction.normalized()
	spin = new_random_vector3(speed * 15)
	speed += 0.05
	if speed > limit_speed:
		reset_speed()

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	translation += direction * speed * delta
	rotation_degrees += spin * delta
	if translation.x >= limit_distance:
		direction.x = -direction.x
		translation.x = limit_distance
		collide_common(delta)
	if translation.x <= -limit_distance:
		direction.x = -direction.x
		translation.x = -limit_distance
		collide_common(delta)
	if translation.y >= limit_distance:
		direction.y = -direction.y
		translation.y = limit_distance
		collide_common(delta)
	if translation.y <= -limit_distance:
		direction.y = -direction.y
		translation.y = -limit_distance
		collide_common(delta)
	if translation.z >= limit_distance:
		direction.z = -direction.z
		translation.z = limit_distance
		collide_common(delta)
	if translation.z <= -limit_distance:
		direction.z = -direction.z
		translation.z = -limit_distance
		collide_common(delta)


func _on_AimlessCube_input_event( camera, event, click_position, click_normal, shape_idx ):
	if lose:
		return
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		direction = new_random_vector3(1)
		direction = direction.normalized()
		translation = new_random_vector3(limit_distance)
		speed += 0.1
		hit = true
		$HitSound.play()
		clicks += 1
