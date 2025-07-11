extends Node

func log_with_base(base: float, value: float) -> float:
	return log(value) / log(base)

func backspace(text: String) -> String:
	var split_text: PackedStringArray = text.split('')
	
	split_text.remove_at(split_text.size() - 1)
	return ''.join(split_text)

func json(entries: Entry) -> Array:
	var entries_structure: Array = []
	
	for entry_index in range(entries.value.size()):
		var entry = entries.value[entry_index]
		
		match entry.type:
			Global.ENTRY_TYPES.NUMBER:
				entries_structure.append({type = Global.ENTRY_TYPES.keys()[entry.type].to_lower(), value = entry.value})
			Global.ENTRY_TYPES.POWER, Global.ENTRY_TYPES.LOGARITHM, Global.ENTRY_TYPES.SQUARE_ROOT, Global.ENTRY_TYPES.PERMUTATION, Global.ENTRY_TYPES.COMBINATION, Global.ENTRY_TYPES.FRACTION, Global.ENTRY_TYPES.MODULUS:
				entries_structure.append({type = Global.ENTRY_TYPES.keys()[entry.type].to_lower()})
				
				for component in entry.value:
					#print(entry.value[component])
					match entry.value[component].type:
						Global.ENTRY_TYPES.PLACEHOLDER:
							entries_structure[entries_structure.size() - 1][component] = null
						Global.ENTRY_TYPES.NUMBER:
							entries_structure[entries_structure.size() - 1][component] = {type = Global.ENTRY_TYPES.keys()[entry.type].to_lower(), value = entry.value[component].value}
						Global.ENTRY_TYPES.ENTRIES:
							entries_structure[entries_structure.size() - 1][component] = json(entry.value[component])
						_:
							printerr('1. ???')
			_:
				entries_structure.append({type = Global.ENTRY_TYPES.keys()[entry.type].to_lower(), value = entry.value})
	
	return entries_structure

func count_entries(entries: Entry) -> int:
	var max_position: int = 0
	
	for entry_index in range(entries.value.size()):
		var entry: Entry = entries.value[entry_index]
		
		match entry.type:
			Global.ENTRY_TYPES.NUMBER:
				max_position += entry.value.length()
			Global.ENTRY_TYPES.POWER, Global.ENTRY_TYPES.LOGARITHM, Global.ENTRY_TYPES.SQUARE_ROOT, Global.ENTRY_TYPES.PERMUTATION, Global.ENTRY_TYPES.COMBINATION, Global.ENTRY_TYPES.FRACTION, Global.ENTRY_TYPES.MODULUS, Global.ENTRY_TYPES.FACTORIAL:
				for component in entry.value:
					match entry.value[component].type:
						Global.ENTRY_TYPES.PLACEHOLDER:
							max_position += 1
						Global.ENTRY_TYPES.NUMBER:
							max_position += entry.value[component].value.length()
						Global.ENTRY_TYPES.ENTRIES:
							max_position += count_entries(entry.value[component])
						_:
							printerr('1. ???')
			_:
				max_position += 1
	
	return max_position

func ln(argument: float) -> float:
	return log_with_base(Global.EULER_NUMBER, argument)

func evaluate(command: String, variable_names: PackedStringArray = [], variable_values: Array = []):
	var expression: Expression = Expression.new()
	var error: Error = expression.parse(command, variable_names)
	
	if error != OK:
		printerr(expression.get_error_text())
		return null
	
	var result = expression.execute(variable_values, self)
	
	if not expression.has_execute_failed():
		var stringified_result: String = str(result)
		
		if stringified_result.ends_with('.0'):
			return int(round(result))
		else:
			match Global.output_type:
				Global.OUTPUT_TYPES.FRACTION:
					if '.' in stringified_result:
						var split_dot: PackedStringArray = stringified_result.split('.')
						var test: float = pow(10, split_dot[split_dot.size() - 1].length())
						
						print('Fraction: ' + str(result * test) + '/' + str(test))
						return result
					else:
						return result
				Global.OUTPUT_TYPES.DECIMAL:
					return result
	else:
		return null

func get_longest_keyboard_row() -> int:
	var length: int = 0
	
	for i in range(len(Global.KEYBOARD)):
		if length < len(Global.KEYBOARD[i]):
			length = len(Global.KEYBOARD[i])
	
	return length

func create_label() -> Label:
	var label: Label = Label.new()
	var font_variation: FontVariation = FontVariation.new()
	
	font_variation.base_font = Global.DEFAULT_FONT
	label.add_theme_font_override('font', font_variation)
	
	return label

func factorial(n: int): # int?
	if n < 0:
		return null
	elif n >= 0 and n <= 1:
		return 1
	else:
		return n * factorial(n - 1)

func permutation(n, r):
	return factorial(n) / factorial(n - r)

func combination(n, r):
	return permutation(n, r) / factorial(r)

func slice_text(value: String, slice_position: int) -> Array[String]:
	var front_split_value = value.substr(0, slice_position + 1)
	var back_split_value = value.substr(slice_position + 1, value.length())
	
	match back_split_value:
		'':
			return [front_split_value]
		_:
			return [front_split_value, back_split_value]

func get_input_cursor_coords(input_cursor_position_ref: Ref, entries: Entry):
	for entry_index in range(entries.value.size()):
		var entry: Entry = entries.value[entry_index]
		
		#printt(input_cursor_position_ref.value, entry.value, Global.ENTRY_TYPES.keys()[entry.type])
		
		match entry.type:
			Global.ENTRY_TYPES.NUMBER:
				var digit_index: int = input_cursor_position_ref.value - 1
				
				input_cursor_position_ref.value -= entry.value.length()
				
				if input_cursor_position_ref.value <= 0:
					return [entry_index, digit_index]
			Global.ENTRY_TYPES.POWER, Global.ENTRY_TYPES.LOGARITHM, Global.ENTRY_TYPES.FRACTION, Global.ENTRY_TYPES.SQUARE_ROOT, Global.ENTRY_TYPES.PERMUTATION, Global.ENTRY_TYPES.COMBINATION, Global.ENTRY_TYPES.MODULUS, Global.ENTRY_TYPES.FACTORIAL:
				for component_name in entry.value:
					var component_value: Entry = entry.value[component_name]
					var default_coords: Array = [entry_index, component_name]
					var inner_entry_coords = get_input_cursor_coords(input_cursor_position_ref, component_value)
					
					if input_cursor_position_ref.value <= 0:
						default_coords.append_array(inner_entry_coords)
						
						return default_coords
			_:
				input_cursor_position_ref.value -= 1
				
				if input_cursor_position_ref.value <= 0:
					return [entry_index]
	
	return []

func get_entry_type_name(type: Global.ENTRY_TYPES):
	return Global.ENTRY_TYPES.keys()[type]

func get_type_name(type: Global.VARIANT_TYPES):
	return Global.Global.VARIANT_TYPES.keys()[type]

func remove_children(node: Node):
	if node.get_child_count() > 0:
		for child in node.get_children():
			node.remove_child(child)
			child.queue_free()
			#child.free()

func group(array: Array, quantity: int) -> Array[Array]:
	var counter: int = 0
	var result: Array[Array] = [[]]
	
	for element in array:
		if counter == quantity:
			result.append([])
			counter = 0
		
		result[result.size() - 1].append(element)
		counter += 1
	
	return result

func dictionary_to_key_value_pairs(dictionary: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for key in dictionary:
		result.append({key = key, value = dictionary[key]})
	
	return result

"""
# json

Global.ENTRY_TYPES.MODULUS, Global.ENTRY_TYPES.FACTORIAL:
	entries_structure.append({type = Global.ENTRY_TYPES.keys()[entry.type].to_lower()})
	
	match entry.value.type:
		Global.ENTRY_TYPES.PLACEHOLDER:
			entries_structure[entries_structure.size() - 1].arg = null
		Global.ENTRY_TYPES.ENTRIES:
			entries_structure[entries_structure.size() - 1].arg = json(entry.value)
		_:
			printerr('2. ???')

# # # # #

# count_entries

Global.ENTRY_TYPES.MODULUS, Global.ENTRY_TYPES.FACTORIAL:
	match entry.value.type:
		Global.ENTRY_TYPES.PLACEHOLDER:
			max_position += 1
		Global.ENTRY_TYPES.ENTRIES:
			max_position += count_entries(entry.value)
		_:
			printerr('2. ???')

# # # # #

# get_input_cursor_coords

Global.ENTRY_TYPES.MODULUS, Global.ENTRY_TYPES.FACTORIAL:
	var default_coords: Array = [entry_index]
	var inner_entry_coords = get_input_cursor_coords(input_cursor_position_ref, entry.value)
		
	if input_cursor_position_ref.value <= 0:
		default_coords.append_array(inner_entry_coords)
		
		return default_coords
"""
