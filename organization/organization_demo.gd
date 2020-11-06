extends Spatial


# when instancing a scene, it must be preloaded,
# or loaded but with the `add_child` call deferred.
onready var abox_scene = preload("res://abox.tscn")

# Instancing a custom non-node class
var counter = CustomCounter.new()

func makebox():
	# Instancing a packed scene (or a subscene, whatever you wanna call it)
	var newbox = abox_scene.instance()
	var c : float = counter.get_count()
	newbox.translate(Vector3(0,float(c)/5.0,0))
	newbox.rotate(Vector3(0,1,0), float(c)/5.0)
	self.add_child(newbox)
	counter.increment()

func _process(delta):
	if Input.is_action_just_pressed("makebox"):
		makebox()
