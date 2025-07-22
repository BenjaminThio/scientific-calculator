extends VBoxContainer

@onready var calculator: VBoxContainer = owner # Calculator
@onready var entries_line: ScrollContainer = get_parent().get_node('Display/EntriesLine')
@onready var result_line: Label = get_parent().get_node('Display/ResultLine')
@onready var calculator_size: Vector2 = calculator.size

func _ready():
	construct_calculator(Global.KEYBOARD)

func calculator_callback(option: Global.OPTIONS) -> void:
	match calculator.tab:
		Global.TABS.MAIN:
			pass
		Global.TABS.CONSTANT_CATEGORY:
			match option:
				Global.OPTIONS.SHIFT:
					shift()
				Global.OPTIONS.CONSTANT, Global.OPTIONS.ALL_CLEAR:
					calculator.tab = Global.TABS.MAIN
			
			entries_line.display()
			return
		Global.TABS.CONSTANT:
			match option:
				Global.OPTIONS.LEFT:
					calculator.tab = Global.TABS.CONSTANT_CATEGORY
				Global.OPTIONS.ALL_CLEAR:
					calculator.tab = Global.TABS.MAIN
				Global.OPTIONS.SHIFT:
					shift()
			
			entries_line.display()
			return
		_:
			return
	
	if option >= 0 && option <= 9:
		calculator.create_number_entry(str(option))
	else:
		match option:
			Global.OPTIONS.SHIFT:
				calculator.is_shifted = not calculator.is_shifted
				
				refresh_keyboard()
				
				if calculator.is_shifted:
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
				if calculator.input_cursor_position - 1 > 0:
					calculator.input_cursor_position -= 1
				else:
					calculator.input_cursor_position = Utils.count_entries(calculator.entries)
			Global.OPTIONS.RIGHT:
				if calculator.input_cursor_position + 1 <= Utils.count_entries(calculator.entries):
					calculator.input_cursor_position += 1
				else:
					calculator.input_cursor_position = 1
			Global.OPTIONS.ALGEBRA:
				pass
			Global.OPTIONS.DOWN:
				pass
			Global.OPTIONS.FRACTION:
				calculator.create_entries(Entry.new(
					Global.ENTRY_TYPES.FRACTION,
					{
						numerator = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.PLACEHOLDER)]),
						denominator = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.PLACEHOLDER)])
					}
				), Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER))
			Global.OPTIONS.SQUARE_ROOT:
				calculator.create_entries(
						Entry.new(
							Global.ENTRY_TYPES.SQUARE_ROOT,
							{
								index = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER), Entry.new(Global.ENTRY_TYPES.NUMBER, '2')]),
								radicand = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new()])
							}
						),
						Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER)
					)
			Global.OPTIONS.CUBE_ROOT:
				calculator.create_entry(Global.ENTRY_TYPES.SQUARE_ROOT, {index = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER), Entry.new(Global.ENTRY_TYPES.NUMBER, '3')]), radicand = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new()])})
			Global.OPTIONS.ROOT:
				calculator.create_entry(Global.ENTRY_TYPES.SQUARE_ROOT, {index = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new()]), radicand = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new()])})
			Global.OPTIONS.POWER_OF_TWO:
				calculator.create_power_entry('2')
			Global.OPTIONS.POWER:
				calculator.create_power_entry('')
			Global.OPTIONS.LOGARITHMS:
				calculator.create_entries(
					Entry.new(Global.ENTRY_TYPES.LOGARITHM, {
						base = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new()]),
						argument = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new()])
					}),
					Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER)
				)
			Global.OPTIONS.NATURAL_LOGARITHM:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, 'ln(') # log(
			Global.OPTIONS.POWER_OF_NEGATIVE_ONE:
				calculator.create_power_entry('-1')
			Global.OPTIONS.SINE:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, 'sin(')
			Global.OPTIONS.COSINE:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, 'cos(')
			Global.OPTIONS.TANGENT:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, 'tan(')
			Global.OPTIONS.LEFT_PARENTHESIS:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, '(')
			Global.OPTIONS.RIGHT_PARENTHESIS:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, ')')
			Global.OPTIONS.DELETE:
				if calculator.entries.value.size() > 0:
					var last_entry: Entry = calculator.entries.value[calculator.entries.value.size() - 1]
					
					match last_entry.type:
						Global.ENTRY_TYPES.NUMBER:
							if last_entry.value.length() > 1:
								calculator.entries.value[calculator.entries.value.size() - 1].value = Utils.backspace(last_entry.value)
							else:
								calculator.entries.value.pop_back()
						_:
							calculator.entries.value.pop_back()
			Global.OPTIONS.ALL_CLEAR:
				calculator.entries.value.clear()
			Global.OPTIONS.MULTIPLY:
				calculator.create_entry(Global.ENTRY_TYPES.OPERATOR, '×')
			Global.OPTIONS.DIVIDE:
				calculator.create_entry(Global.ENTRY_TYPES.OPERATOR, '÷')
			Global.OPTIONS.PLUS:
				calculator.create_entry(Global.ENTRY_TYPES.OPERATOR, '+')
			Global.OPTIONS.MINUS:
				calculator.create_entry(Global.ENTRY_TYPES.OPERATOR, '-')
			Global.OPTIONS.DOT:
				calculator.create_number_entry('.')
			Global.OPTIONS.ANSWER:
				calculator.create_entry(Global.ENTRY_TYPES.VARIABLE, 'ANS')
			Global.OPTIONS.EQUAL:
				#print(compile_expression(entries))
				var result = Utils.evaluate(compile_expression(calculator.entries), ['ANS'], [Database.data.previous_result])
				
				if result != null:
					Database.data.previous_result = result
					Database.save_data()
				
				result_line.text = str(result)
			Global.OPTIONS.OFF:
				get_tree().quit()
			Global.OPTIONS.ARCSINE:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, 'asin(')
			Global.OPTIONS.ARCCOSINE:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, 'acos(')
			Global.OPTIONS.ARCTANGENT:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, 'atan(')
			Global.OPTIONS.RANDOM:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, 'randf()')
			Global.OPTIONS.RANDOM_INTEGER:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, 'randi_range(')
			Global.OPTIONS.COMMA:
				calculator.create_entry(Global.ENTRY_TYPES.OPERATOR, ',')
			Global.OPTIONS.PI:
				calculator.create_entry(Global.ENTRY_TYPES.CONSTANT, {display = 'π', value = 'PI'})
			Global.OPTIONS.POWER_OF_THREE:
				calculator.create_power_entry('3')
			Global.OPTIONS.ABSOLUTE:
				calculator.create_entries(Entry.new(Global.ENTRY_TYPES.MODULUS, {arg = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.PLACEHOLDER)])}), Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER))
			Global.OPTIONS.FACTORIAL:
				calculator.create_entry(Global.ENTRY_TYPES.FACTORIAL, {arg = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new()])})
			Global.OPTIONS.LOG:
				calculator.create_entry(Global.ENTRY_TYPES.FUNCTION, 'log_with_base(10,')
			Global.OPTIONS.PERMUTATION, Global.OPTIONS.COMBINATION:
				var entry_type: Global.ENTRY_TYPES = Global.ENTRY_TYPES.PERMUTATION
				
				match option:
					Global.OPTIONS.COMBINATION:
						entry_type = Global.ENTRY_TYPES.COMBINATION
				
				if calculator.entries.value.size() > 1:
					var last_entry: Entry = calculator.entries.value[calculator.entries.value.size() - 1]
					
					calculator.entries.value.pop_back()
					calculator.entries.value.append(Entry.new(entry_type, {
						n = Entry.new(Global.ENTRY_TYPES.ENTRIES, [last_entry]),
						r = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new()])
					}))
				else:
					calculator.entries.value.append(Entry.new(entry_type, {
						n = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new()]),
						r = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new()])
					}))
			Global.OPTIONS.CONSTANT:
				calculator.tab = Global.TABS.CONSTANT_CATEGORY
			Global.OPTIONS.EULER_POWER:
				calculator.create_entry(Global.ENTRY_TYPES.POWER, {
					base = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.CONSTANT, {display = 'e', value = Global.EULER_NUMBER})]),
					exponent = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.PLACEHOLDER)])
				})
			Global.OPTIONS.TEN_POWER:
				calculator.create_entry(Global.ENTRY_TYPES.POWER, {
					base = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.NUMBER, '10')]),
					exponent = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.PLACEHOLDER)])
				})
	
	print(Utils.json(calculator.entries))
	#print(Utils.get_input_cursor_coords(Ref.new(calculator.input_cursor_position), calculator.entries))
	entries_line.display()

func shift() -> void:
	calculator.is_shifted = not calculator.is_shifted
	
	refresh_keyboard()
	
	if calculator.is_shifted:
		construct_calculator(Global.SHIFTED_KEYBOARD)
	else:
		construct_calculator(Global.KEYBOARD)

func refresh_keyboard() -> void:
	if get_child_count() > 0:
		for child in get_children():
			remove_child(child)
			child.queue_free()
			#child.free()

func construct_calculator(keyboard) -> void:
	for y in range(len(keyboard)):
		var calculator_row: HBoxContainer = HBoxContainer.new()
		
		calculator_row.alignment = BoxContainer.ALIGNMENT_CENTER
		
		for x in range(len(keyboard[y])):
			var calculator_cell: Button = Button.new()
			var font_variation: FontVariation = FontVariation.new()
			
			font_variation.base_font = Global.DEFAULT_FONT
			
			calculator_cell.add_theme_font_override('font', font_variation)
			calculator_cell.add_theme_font_size_override('font_size', 20)
			calculator_cell.text = keyboard[y][x][0]
			calculator_cell.custom_minimum_size = Vector2(calculator_size.x / Utils.get_longest_keyboard_row(), calculator_size.x / Utils.get_longest_keyboard_row() / 2)
			calculator_cell.pressed.connect(calculator_callback.bind(keyboard[y][x][1]))
			
			calculator_row.add_child(calculator_cell)
		
		add_child(calculator_row)

func compile_expression(expression_entries: Entry):
	var expression: String = ''
	
	match expression_entries.type:
		Global.ENTRY_TYPES.ENTRIES:
			for entry in expression_entries.value:
				match entry.type:
					Global.ENTRY_TYPES.OPERATOR:
						match entry.value:
							'×':
								expression += '*'
							'÷':
								expression += '/'
							_:
								expression += entry.value
					Global.ENTRY_TYPES.POWER:
						var base = entry.value.base
						var exponent = entry.value.exponent
						
						expression += 'pow({base}, {exponent})'.format({base = compile_expression(base), exponent = compile_expression(exponent)})
					Global.ENTRY_TYPES.LOGARITHM:
						var base = entry.value.base
						var argument = entry.value.argument
						
						expression += 'log_with_base({base}, {value})'.format({base = compile_expression(base), value = compile_expression(argument)})
					Global.ENTRY_TYPES.NUMBER:
						if '.' not in entry.value:
							expression += entry.value + '.0'
						else:
							expression += entry.value
					Global.ENTRY_TYPES.PERMUTATION, Global.ENTRY_TYPES.COMBINATION:
						var n = entry.value.n
						var r = entry.value.r
						
						match entry.type:
							Global.ENTRY_TYPES.PERMUTATION:
								expression += 'permutation({n}, {r})'.format({n = compile_expression(n), r = compile_expression(r)})
							Global.ENTRY_TYPES.COMBINATION:
								expression += 'combination({n}, {r})'.format({n = compile_expression(n), r = compile_expression(r)})
					Global.ENTRY_TYPES.MODULUS:
						var arg = entry.value.arg
						
						expression += 'abs({arg})'.format({arg = compile_expression(arg)})
					Global.ENTRY_TYPES.FACTORIAL:
						var arg = entry.value.arg
						
						expression += 'factorial({arg})'.format({arg = compile_expression(arg)})
					Global.ENTRY_TYPES.PLAIN_PLACEHOLDER:
						pass
					Global.ENTRY_TYPES.FRACTION:
						var numerator = entry.value.numerator
						var denominator = entry.value.denominator
						
						expression += '{numerator}/{denominator}'.format({numerator = compile_expression(numerator), denominator = compile_expression(denominator)})
					Global.ENTRY_TYPES.SQUARE_ROOT:
						var index = entry.value.index
						var radicand = entry.value.radicand
						
						expression += 'pow({radicand},1/{index})'.format({index = compile_expression(index), radicand = compile_expression(radicand)})
					Global.ENTRY_TYPES.CONSTANT:
						var callback_value: String = str(entry.value.value)
						
						if 'exp' in entry.value:
							var exponent_value: String = str(entry.value.exp)
							
							expression += '{base}e{exponent}'.format({base = callback_value, exponent = exponent_value})
						else:
							expression += str(callback_value)
					_:
						expression += str(entry.value)
		_:
			print(Utils.get_entry_type_name(expression_entries.type))
	
	return expression
