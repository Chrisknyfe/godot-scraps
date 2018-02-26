extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var hit = false
var time_since_last_update = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$LoseMenu.hide()


func update_gui():
	var speed = $'AimlessCube'.speed
	var limit_speed = $'AimlessCube'.limit_speed
	$'SpeedLabel'.text = "Speed: " + str(speed)
	$'SpeedProgress'.value = round(100 * speed / limit_speed)
	$ClicksLabel.text = "Clicks: " + str($AimlessCube.clicks)
	

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if !$AimlessCube.hit == true and hit == true:
		print("You lose.")
		$AimlessCube.lose = true
		$LoseMenu.show()
	$AimlessCube.hit = false
	hit = false
	
	time_since_last_update += delta
	if time_since_last_update >= 0.1:
		update_gui()
		time_since_last_update -= 0.1


func _on_MissArea_input_event( camera, event, click_position, click_normal, shape_idx ):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		hit = true
		

func _on_QuitButton_pressed():
	get_tree().quit()


func _on_TryAgainButton_pressed():
	$LoseMenu.hide()
	hit = false
	$AimlessCube.reset()
	