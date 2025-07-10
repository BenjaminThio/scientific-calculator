extends HBoxContainer

@onready var index_container: HBoxContainer = $IndexContainer
@onready var radical_side: Control = $RadicalSide
@onready var radicand_container: HBoxContainer = $RadicalContainer/RadicandContainer

func _ready():
	#set_index('3')
	pass

func _draw() -> void:
	draw_lines([
		Vector2(index_container.size.x + radical_side.size.x, 0),
		Vector2(index_container.size.x + radical_side.size.x / 3.0, radical_side.size.y),
		Vector2(index_container.size.x + radical_side.size.x / 6.0, radical_side.size.y - 12.0),
		Vector2(index_container.size.x, radical_side.size.y - 8.0)
	], Color.WHITE, 1.5, true)

func draw_lines(points: PackedVector2Array, color: Color, width: float, antialiased: bool = false):
	var previous_point: Vector2
	
	for point_index in range(points.size()):
		var point = points[point_index]
		
		if point_index > 0:
			draw_line(previous_point, point, color, width, antialiased)
		
		previous_point = point

func _on_resized() -> void:
	queue_redraw()

func add_index_nodes(index_nodes: Array[Node]) -> void:
	for index_node in index_nodes:
		index_container.add_child(index_node)

func add_radicand_nodes(radicand_nodes: Array[Node]) -> void:
	for radicand_node in radicand_nodes:
		radicand_container.add_child(radicand_node)
