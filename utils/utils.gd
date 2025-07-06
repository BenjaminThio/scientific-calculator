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
			Global.TYPE.NUMBER:
				entries_structure.append({type = Global.TYPE.keys()[entry.type].to_lower(), value = entry.value})
			Global.TYPE.POWER, Global.TYPE.LOGARITHM, Global.TYPE.SQUARE_ROOT, Global.TYPE.PERMUTATION, Global.TYPE.COMBINATION, Global.TYPE.FRACTION:
				entries_structure.append({type = Global.TYPE.keys()[entry.type].to_lower()})
				
				for component in entry.value:
					#print(entry.value[component])
					match entry.value[component].type:
						Global.TYPE.PLACEHOLDER:
							entries_structure[entries_structure.size() - 1][component] = null
						Global.TYPE.NUMBER:
							entries_structure[entries_structure.size() - 1][component] = {type = Global.TYPE.keys()[entry.type].to_lower(), value = entry.value[component].value}
						Global.TYPE.ENTRIES:
							entries_structure[entries_structure.size() - 1][component] = json(entry.value[component])
						_:
							printerr('1. ???')
			Global.TYPE.MODULUS, Global.TYPE.FACTORIAL:
				entries_structure.append({type = Global.TYPE.keys()[entry.type].to_lower()})
				
				match entry.value.type:
					Global.TYPE.PLACEHOLDER:
						entries_structure[entries_structure.size() - 1].arg = null
					Global.TYPE.ENTRIES:
						entries_structure[entries_structure.size() - 1].arg = json(entry)
					_:
						printerr('2. ???')
			_:
				entries_structure.append({type = Global.TYPE.keys()[entry.type].to_lower(), value = entry.value})
	
	return entries_structure

func count_entries(entries: Entry) -> int:
	var max_position: int = 0
	
	for entry_index in range(entries.value.size()):
		var entry: Entry = entries.value[entry_index]
		
		match entry.type:
			Global.TYPE.NUMBER:
				max_position += entry.value.length()
			Global.TYPE.POWER, Global.TYPE.LOGARITHM, Global.TYPE.SQUARE_ROOT, Global.TYPE.PERMUTATION, Global.TYPE.COMBINATION, Global.TYPE.FRACTION:
				for component in entry.value:
					match entry.value[component].type:
						Global.TYPE.PLACEHOLDER:
							max_position += 1
						Global.TYPE.NUMBER:
							max_position += entry.value[component].value.length()
						Global.TYPE.ENTRIES:
							max_position += count_entries(entry.value[component])
						_:
							printerr('1. ???')
			Global.TYPE.MODULUS, Global.TYPE.FACTORIAL:
					match entry.value.type:
						Global.TYPE.PLACEHOLDER:
							max_position += 1
						Global.TYPE.ENTRIES:
							max_position += count_entries(entry.value)
						_:
							printerr('2. ???')
			_:
				max_position += 1
	
	return max_position

func ln(argument: float) -> float:
	return log_with_base(Global.EULER_NUMBER, argument)

func evaluate(command: String, variable_names: PackedStringArray = [], variable_values: Array = []):
	var expression: Expression = Expression.new()
	var error: Error = expression.parse(command, variable_names)
	
	if error != OK:
		#printerr(expression.get_error_text())
		return null
	
	var result = expression.execute(variable_values, self)
	
	if not expression.has_execute_failed():
		var stringified_result: String = str(result)
		
		if stringified_result.ends_with('.0'):
			return int(result)
		else:
			match Global.output_type:
				Global.OUTPUT_TYPE.FRACTION:
					if '.' in stringified_result:
						var split_dot: PackedStringArray = stringified_result.split('.')
						var test: float = pow(10, split_dot[split_dot.size() - 1].length())
						
						print('Fraction: ' + str(result * test) + '/' + str(test))
						return result
					else:
						return result
				Global.OUTPUT_TYPE.DECIMAL:
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
	
	font_variation.base_font = Global.FONT
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
		
		#printt(input_cursor_position_ref.value, entry.value, Global.TYPE.keys()[entry.type])
		
		match entry.type:
			Global.TYPE.NUMBER:
				var digit_index: int = input_cursor_position_ref.value - 1
				
				input_cursor_position_ref.value -= entry.value.length()
				
				if input_cursor_position_ref.value <= 0:
					return [entry_index, digit_index]
			Global.TYPE.POWER, Global.TYPE.LOGARITHM, Global.TYPE.FRACTION, Global.TYPE.SQUARE_ROOT:
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
