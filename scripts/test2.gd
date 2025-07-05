extends Node2D

var a: String = '100'
var b: String = '0'

func _on_button_pressed() -> void:
	var test: Label = Utils.create_label()
	
	test.text = 'IN'
	test.resized.connect(
		func():
			print(test.size)
	)
	
	$Control.add_child(test)
