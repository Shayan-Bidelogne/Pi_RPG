class_name Attack


var source: Node
var damage: float
var payload: Dictionary


func _init(_source: Node, _damage: float = 0.0) -> void:
	source = _source
	damage = _damage
