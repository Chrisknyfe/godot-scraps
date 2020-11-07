extends Viewport

export (NodePath) var path_to_viewport_viewer;
var viewport_viewer;

func _ready():
	var root_viewport = get_tree().root;
	root_viewport.transparent_bg = true;
	size = root_viewport.size;
	
	root_viewport.connect("size_changed", self, "_on_root_viewport_size_changed");
	
	viewport_viewer = get_node(path_to_viewport_viewer);
	viewport_viewer.material.set_shader_param("viewport_texture", get_texture());


func _on_root_viewport_size_changed():
	size = get_tree().root.size;
