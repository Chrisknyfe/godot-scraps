extends MeshInstance

func set_color(color):
	var mat = SpatialMaterial.new()
	mat.albedo_color = color
	self.set_surface_material(0, mat)
	
func _on_Timer_timeout():
	print("A marker was deleted")
	self.queue_free()
