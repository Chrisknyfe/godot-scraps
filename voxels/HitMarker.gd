extends Spatial

func set_color(color):
	$Sprite3D.modulate = color
	
func _on_Timer_timeout():
	self.queue_free()
