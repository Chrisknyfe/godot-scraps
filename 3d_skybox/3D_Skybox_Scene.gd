extends Spatial

export (NodePath) var target_camera_path
export (float) var skybox_scale = 1.0
var target_camera;
var skybox_camera;

func _ready():
	skybox_camera = get_node("Skybox_Camera");
	target_camera = get_node(target_camera_path);


func _process(_delta):
	# Skybox cam matches target cam, but with a scaling factor.
	skybox_camera.translation = target_camera.translation / skybox_scale
	skybox_camera.rotation = target_camera.rotation
	skybox_camera.scale = target_camera.scale / skybox_scale
