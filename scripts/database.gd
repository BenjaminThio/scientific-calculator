extends Node

var save_path: String = "user://settings.save"
var default_data: Dictionary = {
	previous_result = 0
}
var data: Dictionary = default_data.duplicate(true)

func _ready() -> void:
	#print(load_data())
	pass

func load_data() -> Dictionary:
	if FileAccess.file_exists(save_path):
		var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	
		data = file.get_var(true)
	else:
		save_data()
	
	return data

func save_data() -> void:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	
	file.store_var(data, true)
