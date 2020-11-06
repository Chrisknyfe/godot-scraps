extends Spatial


# when instancing a scene, it must be preloaded,
# or loaded but with the `add_child` call deferred.
onready var abox_scene = preload("res://abox.tscn")

# Instancing a custom non-node class
var counter = CustomCounter.new()
var anglecounter = DoubleCounter.new()

func makebox():
	# Instancing a packed scene (or a subscene, whatever you wanna call it)
	var newbox = abox_scene.instance()
	var y : float = counter.get_count() / 5.0
	var theta : float = anglecounter.get_count() / 5.0
	newbox.translate(Vector3(0,y,0))
	newbox.rotate(Vector3(0,1,0), theta)
	self.add_child(newbox)
	counter.increment()
	anglecounter.increment()

func _process(delta):
	if Input.is_action_just_pressed("makebox"):
		makebox()
		# Get something from the global autoload singleton
		print("Global.foo:", Global.foo)
