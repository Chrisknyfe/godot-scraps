# Copyright © 2017 Hugo Locurcio and contributors - MIT license
# See LICENSE.md included in the source distribution for more information.

extends Camera

const MOVE_SPEED = 2
const MOUSE_SENSITIVITY = 0.002

onready var speed = 1
onready var velocity = Vector3()
onready var initial_rotation = PI/2

onready var raycast = $RayCast
onready var hitmarker_scene = preload("res://HitMarker.tscn")

var rot_target = Vector3(0,0,0)

func _enter_tree():
	# Capture the mouse (can be toggled by pressing F10)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _ready():
#	OS.set_window_maximized(true)
	OS.set_window_fullscreen(true)

func slerp_euler_no_z(initial_rot, target_rot, weight):
	var init_trans = Transform(Basis(initial_rot), Vector3(0,0,0))
	var target_trans = Transform(Basis(target_rot), Vector3(0,0,0))
	
	var final_trans = init_trans.interpolate_with(target_trans, weight)
	var final_rot = final_trans.basis.get_euler()
	final_rot.z = 0
	return final_rot
	
func _input(event):
	# Horizontal mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rot_target.y -= event.relative.x*MOUSE_SENSITIVITY
		
		# wrap horizontal mouselook
		if rot_target.y > PI:
			rot_target.y -= 2*PI
		if rot_target.y < -PI:
			rot_target.y += 2*PI

	# Vertical mouse look, clamped to -90..90 degrees
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rot_target.x = clamp(rot_target.x - event.relative.y*MOUSE_SENSITIVITY, deg2rad(-90), deg2rad(90))
		
	# Toggle HUD
	if event.is_action_pressed("toggle_hud"):
		$"../HUD".visible = !$"../HUD".visible

	# Toggle mouse capture
	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("quit"):
		get_tree().quit()
		
	if event.is_action_pressed("toggle_fullscreen"):
		if OS.window_fullscreen:
			OS.set_window_fullscreen(false)
		else:
			OS.set_window_fullscreen(true)
		

func _physics_process(delta):
	# Apply rotation
	rotation = slerp_euler_no_z(rotation, rot_target, 20 * delta)
	
	# Speed modifier
	if Input.is_action_pressed("move_speed"):
		speed = 4
	else:
		speed = 1

	# Movement

	if Input.is_action_pressed("move_forward"):
		velocity.x -= MOVE_SPEED*speed*delta

	if Input.is_action_pressed("move_backward"):
		velocity.x += MOVE_SPEED*speed*delta

	if Input.is_action_pressed("move_left"):
		velocity.z += MOVE_SPEED*speed*delta

	if Input.is_action_pressed("move_right"):
		velocity.z -= MOVE_SPEED*speed*delta

	if Input.is_action_pressed("move_up"):
		velocity.y += MOVE_SPEED*speed*delta

	if Input.is_action_pressed("move_down"):
		velocity.y -= MOVE_SPEED*speed*delta

	# Friction
	velocity *= 0.875

	# Apply vertical velocity independently
	translation += Vector3(0, velocity.y, 0)
	# Apply horizotal velocity
	translation += Vector3(velocity.x, 0, velocity.z) \
	.rotated(Vector3(0, 1, 0), rotation.y - initial_rotation) \
	.rotated(Vector3(1, 0, 0), cos(rotation.y)*rotation.x) \
	.rotated(Vector3(0, 0, 1), -sin(rotation.y)*rotation.x)
	
# debug code, move to a separate library
func mark(coord, color, parent=null):
	var marker = hitmarker_scene.instance()
	marker.translate(coord)
	marker.set_color(color)
	if not parent:
		var root = get_tree().get_root()  
		root.add_child(marker)
	else:
		parent.add_child(marker)
	
func _process(delta):
	# Block breaking/placing.
	var breaking = Input.is_action_just_pressed("break")
	var placing = Input.is_action_just_pressed("place")
	
	# maybeprod
	if breaking or placing:
		var collider = raycast.get_collider()
		var position = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		if collider and (collider is Island):
			var island: Island = collider
			var nudge = normal * 0.01
			if breaking:
				nudge = -nudge
			var global_pos = (position + nudge)
			mark(position, Color.red)
			#print("Breaking or placing at ", global_pos)
			mark(global_pos, Color.green)
			var island_pos = island.get_block_position_at(global_pos)
			mark(island_pos, Color.blue, island)
			#print("island block pos: ", island_pos)
			
			if breaking:
				island.set_block(island_pos, 0)
			if placing:
				island.set_block(island_pos, 1)
	
	# nonprod for sure
	if Input.is_action_just_pressed("move_island"):
		var collider = raycast.get_collider()
		var position = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		if collider and (collider is Island):
			var island: Island = collider
			var dest = self.translation.round()
			mark(dest, Color.cyan)
			print("Moving island to ", dest)
			island.move_to(dest)


func _exit_tree():
	# Restore the mouse cursor upon quitting
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
