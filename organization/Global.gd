extends Node

# An autoload singleton. Must extend Node since it will be added to the scene

var foo: int = 666

var ledger: Array = []

func push_box_to_ledger(box: Spatial) -> void:
	ledger.push_back(box)
	
func pop_box_from_ledger() -> Spatial:
	return ledger.pop_front()

func get_ledger_size() -> int:
	return len(ledger)
