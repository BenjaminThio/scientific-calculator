class_name Entry extends Node

var type: Global.TYPE
var value = null

func _init(init_type: Global.TYPE = Global.TYPE.PLACEHOLDER, init_value = null) -> void:
	type = init_type
	value = init_value
