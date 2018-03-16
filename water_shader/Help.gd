extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var strbuf = "Controls\n--------\n"
	var actions = InputMap.get_actions()
	actions.sort()
	for action in actions:
		if not action.begins_with("ui_"):
			strbuf += "%s: " % action
			var action_list = PoolStringArray()
			for bind in InputMap.get_action_list(action):
				action_list.append(bind.as_text())
			strbuf += action_list.join(", ")
			strbuf += "\n"
	text = strbuf
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
