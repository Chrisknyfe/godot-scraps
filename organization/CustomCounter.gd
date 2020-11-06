extends Reference

class_name CustomCounter

# This is a custom class. You can instantiate this with CustomCounter.new()

var count = 0

func increment():
	self.count += 1.0
	
func get_count():
	return self.count

func reset():
	self.count = 0
