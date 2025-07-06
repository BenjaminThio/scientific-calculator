extends Node2D

@onready var radical_symbol: Label = $RadicalSymbol

func _on_button_pressed() -> void:
	radical_symbol.size = Vector2(radical_symbol.size.x, radical_symbol.size.y + 10)
