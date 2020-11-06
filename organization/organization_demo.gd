extends Spatial


# when instancing a scene, it must be preloaded,
# or loaded but with the `add_child` call deferred.
onready var abox_scene = preload("res://abox.tscn")

# Instancing a custom non-node class
var counter = CustomCounter.new()
var anglecounter = DoubleCounter.new()

func makebox():
	var count = counter.get_count()
	var y : float = count / 5.0
	var theta : float = anglecounter.get_count() / 5.0
	
	# Instancing a packed scene (or a subscene, whatever you wanna call it)
	var newbox = abox_scene.instance()
	newbox.serial_num = count
	print("New box: ", newbox.serial_num)
	
	newbox.translate(Vector3(0,y,0))
	newbox.rotate(Vector3(0,1,0), theta)
	self.add_child(newbox)
	Global.push_box_to_ledger(newbox)
	
	counter.increment()
	anglecounter.increment()
	
func delbox():
	var box = Global.pop_box_from_ledger()
	if box:
		box.queue_free()
		print("Freeing box: ", box.serial_num)
	
	if Global.get_ledger_size() == 0:
		counter.reset()
		anglecounter.reset()

func _process(delta):
	if Input.is_action_just_pressed("makebox"):
		makebox()
		# Get something from the global autoload singleton
		print("Global ledger size:", Global.get_ledger_size())
	if Input.is_action_just_pressed("delbox"):
		delbox()
		print("Global ledger size:", Global.get_ledger_size())
