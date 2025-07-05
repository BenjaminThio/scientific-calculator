extends VBoxContainer

var is_shifted: bool = false
var entries: Entry = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.PLAIN_PLACEHOLDER)])
var previous_result: float = 0
var input_cursor_position: int = 1

@onready var entries_line: HBoxContainer = $Display/EntriesLine
@onready var result_line: Label = $Display/ResultLine
@onready var keyboard_container: VBoxContainer = $Keyboard

func _ready() -> void:
	display()
	construct_calculator(Global.KEYBOARD)

func calculator_callback(option: Global.OPTIONS) -> void:
	if option >= 0 && option <= 9:
		create_number_entry(str(option))
	else:
		match option:
			Global.OPTIONS.SHIFT:
				is_shifted = not is_shifted
				
				refresh_keyboard()
				
				if is_shifted:
					construct_calculator(Global.SHIFTED_KEYBOARD)
				else:
					construct_calculator(Global.KEYBOARD)
			Global.OPTIONS.ALPHA:
				pass
			Global.OPTIONS.UP:
				pass
			Global.OPTIONS.MENU:
				pass
			Global.OPTIONS.ON:
				pass
			Global.OPTIONS.OPTION:
				pass
			Global.OPTIONS.CALCULATE:
				pass
			Global.OPTIONS.LEFT:
				if input_cursor_position - 1 > 0:
					input_cursor_position -= 1
				else:
					input_cursor_position = Utils.count_entries(entries)
			Global.OPTIONS.RIGHT:
				if input_cursor_position + 1 <= Utils.count_entries(entries):
					input_cursor_position += 1
				else:
					input_cursor_position = 1
			Global.OPTIONS.ALGEBRA:
				pass
			Global.OPTIONS.DOWN:
				pass
			Global.OPTIONS.FRACTION:
				entries.value.append(Entry.new(Global.TYPE.FRACTION, {numerator = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.PLACEHOLDER)]), denominator = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.PLACEHOLDER)])}))
				input_cursor_position += 1
			Global.OPTIONS.SQUARE_ROOT:
				entries.value.append(Entry.new(Global.TYPE.SQUARE_ROOT, {index = Entry.new(Global.TYPE.NUMBER, '2'), radicand = [Entry.new(Global.TYPE.NUMBER, '25')]}))
			Global.OPTIONS.POWER_OF_TWO:
				create_power_entry('2')
			Global.OPTIONS.POWER:
				create_power_entry('')
			Global.OPTIONS.LOGARITHMS:
				entries.value.append(Entry.new(Global.TYPE.LOGARITHM, {
					base = Entry.new(Global.TYPE.ENTRIES, [Entry.new()]),
					argument = Entry.new(Global.TYPE.ENTRIES, [Entry.new()])
				}))
			Global.OPTIONS.NATURAL_LOGARITHM:
				create_common_entry(Global.TYPE.FUNCTION, 'ln(')
			Global.OPTIONS.POWER_OF_NEGATIVE_ONE:
				create_power_entry('-1')
			Global.OPTIONS.SINE:
				create_common_entry(Global.TYPE.FUNCTION, 'sin(')
			Global.OPTIONS.COSINE:
				create_common_entry(Global.TYPE.FUNCTION, 'cos(')
			Global.OPTIONS.TANGENT:
				create_common_entry(Global.TYPE.FUNCTION, 'tan(')
			Global.OPTIONS.LEFT_PARENTHESIS:
				create_common_entry(Global.TYPE.OPERATOR, '(')
			Global.OPTIONS.RIGHT_PARENTHESIS:
				create_common_entry(Global.TYPE.OPERATOR, ')')
			Global.OPTIONS.DELETE:
				if entries.value.size() > 0:
					var last_entry: Entry = entries.value[entries.value.size() - 1]
					
					match last_entry.type:
						Global.TYPE.NUMBER:
							if last_entry.value.length() > 1:
								entries.value[entries.value.size() - 1].value = Utils.backspace(last_entry.value)
							else:
								entries.value.pop_back()
						_:
							entries.value.pop_back()
			Global.OPTIONS.ALL_CLEAR:
				entries.value.clear()
			Global.OPTIONS.MULTIPLY:
				create_common_entry(Global.TYPE.OPERATOR, '×')
			Global.OPTIONS.DIVIDE:
				create_common_entry(Global.TYPE.OPERATOR, '÷')
			Global.OPTIONS.PLUS:
				create_common_entry(Global.TYPE.OPERATOR, '+')
			Global.OPTIONS.MINUS:
				create_common_entry(Global.TYPE.OPERATOR, '-')
			Global.OPTIONS.DOT:
				create_number_entry('.')
			Global.OPTIONS.ANSWER:
				create_common_entry(Global.TYPE.VARIABLE, 'ANS')
			Global.OPTIONS.EQUAL:
				#print(compile_expression(entries))
				var result = Utils.evaluate(compile_expression(entries), ['ANS'], [previous_result])
				
				if result != null:
					previous_result = result
				result_line.text = str(result)
			Global.OPTIONS.OFF:
				get_tree().quit()
			Global.OPTIONS.ARCSINE:
				entries.value.append(Entry.new(Global.TYPE.FUNCTION, 'asin('))
			Global.OPTIONS.ARCCOSINE:
				entries.value.append(Entry.new(Global.TYPE.FUNCTION, 'acos('))
			Global.OPTIONS.ARCTANGENT:
				entries.value.append(Entry.new(Global.TYPE.FUNCTION, 'atan('))
			Global.OPTIONS.RANDOM:
				entries.value.append(Entry.new(Global.TYPE.FUNCTION, 'randf()'))
			Global.OPTIONS.RANDOM_INTEGER:
				entries.value.append(Entry.new(Global.TYPE.FUNCTION, 'randi_range('))
			Global.OPTIONS.COMMA:
				entries.value.append(Entry.new(Global.TYPE.OPERATOR, ','))
			Global.OPTIONS.PI:
				entries.value.append(Entry.new(Global.TYPE.CONSTANT, 'PI'))
			Global.OPTIONS.POWER_OF_THREE:
				entries.value.append(Entry.new(Global.TYPE.POWER, {
					base = Entry.new(Global.TYPE.ENTRIES, [Entry.new()]),
					exponent = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.NUMBER, '3')])
				}))
			Global.OPTIONS.ABSOLUTE:
				entries.value.append(Entry.new(Global.TYPE.MODULUS, Entry.new()))
			Global.OPTIONS.FACTORIAL:
				if entries.value.size() > 1:
					var last_entry: Entry = entries[entries.value.size() - 1]
					
					entries.value.pop_back()
					entries.value.append(Entry.new(Global.TYPE.FACTORIAL, [last_entry]))
				else:
					entries.value.append(Entry.new(Global.TYPE.FACTORIAL, Entry.new(Global.TYPE.ENTRIES, [Entry.new()])))
			Global.OPTIONS.LOG:
				entries.value.append(Entry.new(Global.TYPE.FUNCTION, 'log_with_base(10,'))
			Global.OPTIONS.PERMUTATION, Global.OPTIONS.COMBINATION:
				var entry_type: Global.TYPE = Global.TYPE.PERMUTATION
				
				match option:
					Global.OPTIONS.COMBINATION:
						entry_type = Global.TYPE.COMBINATION
				
				if entries.value.size() > 0:
					var last_entry: Entry = entries.value[entries.value.size() - 1]
					
					entries.value.pop_back()
					entries.value.append(Entry.new(entry_type, {n = Entry.new(Global.TYPE.ENTRIES, [last_entry]), r = Entry.new(Global.TYPE.ENTRIES, [Entry.new()])}))
				else:
					entries.value.append(Entry.new(entry_type, {n = Entry.new(Global.TYPE.ENTRIES, [Entry.new()]), r = Entry.new(Global.TYPE.ENTRIES, [Entry.new()])}))
	
	refresh()
	display()
	#print(Utils.json(entries))

func refresh_keyboard() -> void:
	if keyboard_container.get_child_count() > 0:
		for child in keyboard_container.get_children():
			keyboard_container.remove_child(child)
			child.queue_free()
			#child.free()

func get_current_entry() -> Entry:
	var input_cursor_coords: Array = Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries)
	var current_entry: Entry = null
	
	if input_cursor_coords.size() > 0:
		for input_cursor_coord in input_cursor_coords:
			if current_entry == null:
				current_entry = entries.value[input_cursor_coord]
			else:
				match current_entry.type:
					Global.TYPE.NUMBER:
						pass
					_:
						current_entry = current_entry.value[input_cursor_coord]
	
	return current_entry

func create_common_entry(type: Global.TYPE, value: String) -> void:
	if entries.value.size() > 1:
		var current_entry: Entry = get_current_entry()
		var input_cursor_coords: Array = Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries)
		var outer_entry: Entry = null
		var slice_position = input_cursor_coords.pop_back() # int, String
		
		for input_cursor_coord in input_cursor_coords:
			if outer_entry == null:
				outer_entry = entries.value[input_cursor_coord]
			else:
				outer_entry = outer_entry.value[input_cursor_coord]
		
		#print(current_entry)
		match current_entry.type:
			Global.TYPE.NUMBER:
				var slice_target = outer_entry.value
				
				match typeof(slice_target):
					TYPE_ARRAY:
						slice_target = outer_entry.value[0].value
				
				var sliced_text: Array[String] = Utils.slice_text(slice_target, slice_position)
				var outer_entries_index = null
				
				if input_cursor_coords.size() > 0:
					outer_entries_index = input_cursor_coords.pop_back()
				
				if input_cursor_coords.size() > 0:
					outer_entry = null
					
					for input_cursor_coord in input_cursor_coords:
						if outer_entry == null:
							outer_entry = entries.value[input_cursor_coord]
						else:
							outer_entry = outer_entry.value[input_cursor_coord]
					
					outer_entry.value.pop_at(outer_entries_index)
					outer_entry.value.insert(outer_entries_index, Entry.new(Global.TYPE.NUMBER, sliced_text[0]))
					outer_entry.value.insert(outer_entries_index + 1, Entry.new(type, value))
					if sliced_text.size() > 1:
						outer_entry.value.insert(outer_entries_index + 2, Entry.new(Global.TYPE.NUMBER, sliced_text[1]))
				else:
					entries.value.pop_at(outer_entries_index)
					entries.value.insert(outer_entries_index, Entry.new(Global.TYPE.NUMBER, sliced_text[0]))
					entries.value.insert(outer_entries_index + 1, Entry.new(type, value))
					if sliced_text.size() > 1:
						entries.value.insert(outer_entries_index + 2, Entry.new(Global.TYPE.NUMBER, sliced_text[1]))
			_:
				if outer_entry == null:
					entries.value.insert(slice_position + 1, Entry.new(type, value))
				else:
					outer_entry.value.insert(slice_position + 1, Entry.new(type, value))
	else:
		entries.value.append(Entry.new(type, value))
	
	input_cursor_position += 1

func create_power_entry(value: String) -> void:
	var current_entry: Entry = get_current_entry()
	var power_entry: Entry = Entry.new(Global.TYPE.NUMBER, value)
	var spacing: int = 0
	
	match value:
		'':
			power_entry = Entry.new()
			spacing = 1
		_:
			spacing = value.length()
	
	if entries.value.size() > 1:
		var outer_entry: Entry = null
		var input_cursor_coords: Array = Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries)
		var slice_position = input_cursor_coords.pop_back() # int, String
		
		for input_cursor_coord in input_cursor_coords:
			if outer_entry == null:
				outer_entry = entries.value[input_cursor_coord]
			else:
				outer_entry = outer_entry.value[input_cursor_coord]
		
		match current_entry.type:
			Global.TYPE.NUMBER:
				var slice_target = outer_entry.value
				
				match typeof(slice_target):
					TYPE_ARRAY:
						slice_target = outer_entry.value[0].value
				
				var sliced_text: Array[String] = Utils.slice_text(slice_target, slice_position)
				var outer_entries_index = null
				
				if input_cursor_coords.size() > 0:
					outer_entries_index = input_cursor_coords.pop_back()
				
				if input_cursor_coords.size() > 0:
					outer_entry = null
					
					for input_cursor_coord in input_cursor_coords:
						if outer_entry == null:
							outer_entry = entries.value[input_cursor_coord]
						else:
							outer_entry = outer_entry.value[input_cursor_coord]
					
					outer_entry.value.pop_at(outer_entries_index)
					outer_entry.value.insert(outer_entries_index, Entry.new(Global.TYPE.POWER, {base = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.NUMBER, sliced_text[0])]), exponent = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.PLAIN_PLACEHOLDER), power_entry])}))
					if sliced_text.size() > 1:
						outer_entry.value.insert(outer_entries_index + 1, Entry.new(Global.TYPE.NUMBER, sliced_text[1]))
						outer_entry.value.insert(outer_entries_index + 2, Entry.new(Global.TYPE.PLAIN_PLACEHOLDER))
					else:
						outer_entry.value.insert(outer_entries_index + 1, Entry.new(Global.TYPE.PLAIN_PLACEHOLDER))
				else:
					entries.value.pop_at(outer_entries_index)
					entries.value.insert(outer_entries_index, Entry.new(Global.TYPE.POWER, {base = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.NUMBER, sliced_text[0])]), exponent = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.PLAIN_PLACEHOLDER), power_entry])}))
					if sliced_text.size() > 1:
						entries.value.insert(outer_entries_index + 1, Entry.new(Global.TYPE.NUMBER, sliced_text[1]))
						entries.value.insert(outer_entries_index + 2, Entry.new(Global.TYPE.PLAIN_PLACEHOLDER))
					else:
						entries.value.insert(outer_entries_index + 1, Entry.new(Global.TYPE.PLAIN_PLACEHOLDER))
				
				input_cursor_position += spacing
			_:
				if input_cursor_coords.size() - 1 > 0:
					outer_entry.value.insert(slice_position + 1, Entry.new(Global.TYPE.POWER, {
						base = Entry.new(Global.TYPE.ENTRIES, [Entry.new()]),
						exponent = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.PLAIN_PLACEHOLDER), power_entry])
					}))
					outer_entry.value.insert(slice_position + 2, Entry.new(Global.TYPE.PLAIN_PLACEHOLDER))
				else:
					entries.value.insert(slice_position + 1, Entry.new(Global.TYPE.POWER, {
						base = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.PLAIN_PLACEHOLDER), Entry.new()]),
						exponent = Entry.new(Global.TYPE.ENTRIES, [power_entry])
					}))
					entries.value.insert(slice_position + 2, Entry.new(Global.TYPE.PLAIN_PLACEHOLDER))
	else:
		entries.value.append(Entry.new(Global.TYPE.POWER, {
			base = Entry.new(Global.TYPE.ENTRIES, [Entry.new()]),
			exponent = Entry.new(Global.TYPE.ENTRIES, [Entry.new(Global.TYPE.PLAIN_PLACEHOLDER), power_entry])
		}))
		input_cursor_position += 1

func create_number_entry(value: String) -> void:
	if entries.value.size() > 1:
		var current_entry: Entry = get_current_entry()
		var input_cursor_coords: Array = Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries)
		
		match current_entry.type:
			Global.TYPE.PLACEHOLDER:
				current_entry.type = Global.TYPE.NUMBER
				current_entry.value = value
			Global.TYPE.NUMBER, _:
				var insert_position: int = input_cursor_coords.pop_back() + 1
				
				match current_entry.type:
					Global.TYPE.NUMBER:
						current_entry.value = current_entry.value.insert(insert_position, value)
					_:
						if input_cursor_coords.size() - 1 > 0:
							var entries_handler: Entry = null
							
							for input_cursor_coord in input_cursor_coords:
								if entries_handler == null:
									entries_handler = entries.value[input_cursor_coord]
								else:
									entries_handler = entries_handler.value[input_cursor_coord]
							
							entries_handler.value.insert(insert_position, Entry.new(Global.TYPE.NUMBER, value))
						else:
							entries.value.insert(insert_position, Entry.new(Global.TYPE.NUMBER, value))
				
				input_cursor_position += 1
	else:
		entries.value.append(Entry.new(Global.TYPE.NUMBER, value))
		input_cursor_position += 1

@onready var calculator_size: Vector2 = size

func construct_calculator(keyboard) -> void:
	for y in range(len(keyboard)):
		var calculator_row: HBoxContainer = HBoxContainer.new()
		
		calculator_row.alignment = BoxContainer.ALIGNMENT_CENTER
		
		for x in range(len(keyboard[y])):
			var calculator_cell: Button = Button.new()
			var font_variation: FontVariation = FontVariation.new()
			
			font_variation.base_font = Global.FONT
			
			calculator_cell.add_theme_font_override('font', font_variation)
			calculator_cell.add_theme_font_size_override('font_size', 20)
			calculator_cell.text = keyboard[y][x][0]
			calculator_cell.custom_minimum_size = Vector2(calculator_size.x / Utils.get_longest_keyboard_row(), calculator_size.x / Utils.get_longest_keyboard_row() / 2)
			calculator_cell.pressed.connect(calculator_callback.bind(keyboard[y][x][1]))
			
			calculator_row.add_child(calculator_cell)
		
		keyboard_container.add_child(calculator_row)

func compile_expression(expression_entries: Entry) -> String:
	var expression: String = ''
	
	for entry in expression_entries.value:
		match entry.type:
			Global.TYPE.OPERATOR:
				match entry.value:
					'×':
						expression += '*'
					'÷':
						expression += '/'
					_:
						expression += entry.value
			Global.TYPE.POWER:
				var base = entry.value.base
				var exponent = entry.value.exponent
				
				expression += 'pow({base}, {exponent})'.format({base = compile_expression(base), exponent = compile_expression(exponent)})
			Global.TYPE.LOGARITHM:
				var base = entry.value.base
				var argument = entry.value.argument
				
				expression += 'log_with_base({base}, {value})'.format({base = compile_expression(base), value = compile_expression(argument)})
			Global.TYPE.NUMBER:
				if '.' not in entry.value:
					expression += entry.value + '.0'
				else:
					expression += entry.value
			Global.TYPE.PERMUTATION, Global.TYPE.COMBINATION:
				var n = entry.value.n
				var r = entry.value.r
				
				match entry.type:
					Global.TYPE.PERMUTATION:
						expression += 'permutation({n}, {r})'.format({n = compile_expression(n), r = compile_expression(r)})
					Global.TYPE.COMBINATION:
						expression += 'combination({n}, {r})'.format({n = compile_expression(n), r = compile_expression(r)})
			Global.TYPE.MODULUS:
				expression += 'abs({arg})'.format({arg = compile_expression(entry)})
			Global.TYPE.FACTORIAL:
				expression += 'factorial({arg})'.format({arg = compile_expression(entry)})
			Global.TYPE.PLAIN_PLACEHOLDER:
				pass
			Global.TYPE.FRACTION:
				var numerator = entry.value.numerator
				var denominator = entry.value.denominator
				
				expression += '{numerator}/{denominator}'.format({numerator = compile_expression(numerator), denominator = compile_expression(denominator)})
			_:
				expression += str(entry.value)
	
	return expression

func refresh() -> void:
	if entries_line.get_child_count() > 0:
		for entry_node in entries_line.get_children():
			entries_line.remove_child(entry_node)
			entry_node.queue_free()
			#entry_node.free()

enum ALIGNMENT {
	BEGIN,
	CENTER,
	END,
}

"""
func blink(node: Node):
	var tween: Tween = create_tween().set_trans(Tween.TRANS_EXPO)
	
	if node != null:
		tween.tween_property(node, "self_modulate", Color.TRANSPARENT, 0.5).finished.connect(
			func():
			var tween2: Tween = create_tween().set_trans(Tween.TRANS_EXPO)
			if node != null:
				tween2.tween_property(node, "self_modulate", Color.WHITE, 0.5).finished.connect(
					func():
						tween.kill()
						tween2.kill()
						blink(node)
				)
			else:
				return
		)
"""

func render_input_cursor(parent: Control, cursor_alignment: ALIGNMENT, input_cursor_position_counter: Ref):
	if input_cursor_position_counter.value == input_cursor_position:
		var input_cursor: ColorRect = ColorRect.new()
		
		#blink(input_cursor)
		
		parent.resized.connect(
			func():
				input_cursor.size = Vector2(2, parent.size.y)
				
				match cursor_alignment:
					ALIGNMENT.BEGIN:
						input_cursor.global_position = Vector2(parent.global_position.x - input_cursor.size.x, 0)
					ALIGNMENT.END:
						input_cursor.global_position = Vector2(parent.global_position.x + parent.size.x, 0)
					ALIGNMENT.CENTER:
						input_cursor.global_position = Vector2(parent.global_position.x + parent.size.x / 2 - 1, 0)
				
				if input_cursor.get_parent() == null:
					parent.add_child(input_cursor)
		)

func primary_display(input_cursor_position_counter: Ref, height: int, cursor_alignment: ALIGNMENT = ALIGNMENT.END, value: String = ''):
	var entry_container: HBoxContainer = HBoxContainer.new()
	var entry_label: Label = Utils.create_label()
	
	match height:
		0:
			entry_label.add_theme_font_size_override('font_size', 30)
		_:
			if height > 0:
				entry_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			else:
				entry_label.size_flags_vertical = Control.SIZE_SHRINK_END
			
			entry_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			entry_container.custom_minimum_size = Vector2(0, abs(height))
			entry_label.add_theme_font_size_override('font_size', 20)
	
	entry_label.text = value
	input_cursor_position_counter.value += 1
	
	entry_container.add_child(entry_label)
	render_input_cursor(entry_label, cursor_alignment, input_cursor_position_counter)
	
	return entry_container

func display():
	var entry_components: Array[Node] = secondary_display(entries)
	
	if entry_components.size() > 0:
		for entry_component in entry_components:
			entries_line.add_child(entry_component)

func secondary_display(expression_entries: Entry, height: int = 0, input_cursor_position_counter: Ref = Ref.new(0)):
	var entry_components: Array[Node] = []
	
	for entry_index in range(expression_entries.value.size()):
		var entry: Entry = expression_entries.value[entry_index]
		
		match entry.type:
			Global.TYPE.PLAIN_PLACEHOLDER:
				entry_components.append(primary_display(input_cursor_position_counter, height, ALIGNMENT.BEGIN))
			Global.TYPE.NUMBER:
				for digit in entry.value:
					entry_components.append(primary_display(input_cursor_position_counter, height, ALIGNMENT.END, digit))
			Global.TYPE.POWER:
				var base: Entry = entry.value.base
				var exponent = entry.value.exponent
				
				match height:
					0:
						entry_components.append_array(secondary_display(base, 0, input_cursor_position_counter))
						entry_components.append_array(secondary_display(exponent, 50, input_cursor_position_counter))
					_:
						entry_components.append_array(secondary_display(base, height, input_cursor_position_counter))
						entry_components.append_array(secondary_display(exponent, height + 20, input_cursor_position_counter))
			Global.TYPE.PLACEHOLDER:
				var placeholder_label: Label = Utils.create_label()
				var placeholder_style: StyleBoxFlat = StyleBoxFlat.new()
				
				placeholder_style.bg_color = Color.TRANSPARENT
				placeholder_style.border_color = Color.WHITE
				placeholder_style.set_border_width_all(2)
				placeholder_style.set_corner_radius_all(3)
				
				match height:
					0:
						placeholder_label.add_theme_font_size_override('font_size', 30)
						entry_components.append(placeholder_label)
					_:
						var horizontal_box_container: HBoxContainer = HBoxContainer.new()
						
						if height > 0:
							placeholder_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
						else: # height < 0
							placeholder_label.size_flags_vertical = Control.SIZE_SHRINK_END
						
						placeholder_label.add_theme_font_size_override('font_size', 20)
						horizontal_box_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
						horizontal_box_container.custom_minimum_size = Vector2(0, abs(height))
						horizontal_box_container.add_child(placeholder_label)
						entry_components.append(horizontal_box_container)
				
				input_cursor_position_counter.value += 1
				placeholder_label.text = ' '
				placeholder_label.add_theme_stylebox_override('normal', placeholder_style)
				
				render_input_cursor(placeholder_label, ALIGNMENT.CENTER, input_cursor_position_counter)
			Global.TYPE.LOGARITHM:
				var base = entry.value.base
				var argument = entry.value.argument
				var log_label: Label = Utils.create_label()
				
				log_label.add_theme_font_size_override('font_size', 30)
				log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				log_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				log_label.text = 'log'
				
				entry_components.append(log_label)
				entry_components.append_array(secondary_display(base, -50, input_cursor_position_counter))
				entry_components.append_array(secondary_display(argument, 0, input_cursor_position_counter))
			Global.TYPE.SQUARE_ROOT:
				var index_label: Label = Utils.create_label()
				
				index_label.text = entry.value.index.value
				entries_line.add_child(index_label)
				index_label.draw_polyline([
					Vector2(size.x, 0),
					Vector2(size.x / 3, size.y),
					Vector2(size.x / 5, size.y * 4 / 5),
					Vector2(0, size.y * 6 / 7)
				], Color.WHITE, 2.0)
			Global.TYPE.FRACTION:
				var fraction_container: VBoxContainer = VBoxContainer.new()
				var fraction_bar: ColorRect = ColorRect.new()
				
				fraction_bar.custom_minimum_size = Vector2(0, 2)
				
				for component_name in entry.value:
					var component_value = entry.value[component_name]
					var component_container: HBoxContainer = HBoxContainer.new()
					
					component_container.add_theme_constant_override('separation', 0)
					
					for component_entry in secondary_display(component_value, 0, input_cursor_position_counter):
						component_container.add_child(component_entry)
					
					fraction_container.add_child(component_container)
					
					if component_name == 'numerator':
						fraction_container.add_child(fraction_bar)
				
				entry_components.append(fraction_container)
			Global.TYPE.FUNCTION, Global.TYPE.CONSTANT:
				var entry_label: Label = Utils.create_label()
				
				match height:
					0:
						entry_label.add_theme_font_size_override('font_size', 30)
					_:
						if height < 0:
							entry_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
						
						entry_label.custom_minimum_size = Vector2(0, abs(height))
						entry_label.add_theme_font_size_override('font_size', 20)
				
				match entry.value:
					'asin(':
						entry_label.text = 'sin⁻¹('
					'acos(':
						entry_label.text = 'cos⁻¹('
					'atan(':
						entry_label.text = 'tan⁻¹('
					'randf()':
						entry_label.text = 'Ran#'
					'randi_range(':
						entry_label.text = 'RandInt#('
					'PI':
						entry_label.text = 'π'
					'log_with_base(10,':
						entry_label.text = 'log('
					_:
						entry_label.text = entry.value
				
				input_cursor_position_counter.value += 1
				render_input_cursor(entry_label, ALIGNMENT.END, input_cursor_position_counter)
				entry_components.append(entry_label)
			Global.TYPE.PERMUTATION, Global.TYPE.COMBINATION:
				var n = entry.value.n
				var r = entry.value.r
				
				secondary_display(n, 50, input_cursor_position_counter)
				
				var label: Label = Utils.create_label()
				
				label.add_theme_font_size_override('font_size', 30)
				
				match entry.type:
					Global.TYPE.PERMUTATION:
						label.text = 'P'
					Global.TYPE.COMBINATION:
						label.text = 'C'
				
				entries_line.add_child(label)
				
				secondary_display(r, -50, input_cursor_position_counter)
			Global.TYPE.MODULUS:
				var line: ColorRect = ColorRect.new()
				
				line.custom_minimum_size = Vector2(2, 0)
				
				entries_line.add_child(line)
				
				secondary_display(entry.value, input_cursor_position_counter.value, input_cursor_position_counter)
				
				entries_line.add_child(line.duplicate())
			Global.TYPE.FACTORIAL:
				var exclamation_mark_label: Label = Utils.create_label()
				
				exclamation_mark_label.text = '!'
				exclamation_mark_label.add_theme_font_size_override('font_size', 30)
				secondary_display(entry.value, input_cursor_position_counter.value, input_cursor_position_counter)
				
				entries_line.add_child(exclamation_mark_label)
			_:
				entry_components.append(primary_display(input_cursor_position_counter, height, ALIGNMENT.END, entry.value))
	
	return entry_components
