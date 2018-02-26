extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Panel.hide()
	
	$Spirit.posess($Player)

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("ui_quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("ui_focus_next"):
		if $Spirit.is_posessing():
			$Spirit.posess(null)
		else:
			$Spirit.posess($Player)


func _on_Area_body_entered( body ):
	if body is RigidBody:
		print ("You win!")
		$Panel.show()

	
	

#func _on_Player_update_position(pos):
#	$Spirit.pos_target = pos
#	pass # replace with function body


#func _on_CameraFollow_update_angle(angle):
#	$Player.look_angle_target = angle
