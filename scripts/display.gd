extends ScrollContainer

const RADICAL_SYMBOL_PACKED_SCENE: PackedScene = preload("res://instances/radical_symbol.tscn")

@onready var calculator: VBoxContainer = get_parent().get_parent() # Calculator

func _ready() -> void:
	display()

func display():
	Utils.remove_children(self) #refresh()
	
	match calculator.tab:
		Global.TABS.MAIN:
			var entries_line: HBoxContainer = HBoxContainer.new()
			var entry_components: Array[Node] = secondary_display(calculator.entries)
			
			entries_line.add_theme_constant_override('separation', 0)
			entries_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			if entry_components.size() > 0:
				for entry_component in entry_components:
					entries_line.add_child(entry_component)
			
			add_child(entries_line)
		Global.TABS.CONSTANT_CATEGORY:
			var constant_categories_container: VBoxContainer = VBoxContainer.new()
			
			constant_categories_container.add_theme_constant_override('separation', 0)
			
			for constant_category_index in range(Global.CONSTANTS.size()):
				var constant_category_name: String = Global.CONSTANTS.keys()[constant_category_index].capitalize()
				var constant_category_button: Button = Button.new()
				
				constant_category_button.add_theme_font_override('font', Global.DEFAULT_FONT)
				constant_category_button.add_theme_font_size_override('font_size', 20)
				constant_category_button.flat = true
				constant_category_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
				constant_category_button.pressed.connect(set_constant_category.bind(constant_category_index))
				constant_category_button.text = str(constant_category_index + 1) + '. ' + constant_category_name
				constant_categories_container.add_child(constant_category_button)
			
			add_child(constant_categories_container)
		Global.TABS.CONSTANT:
			match calculator.constant_category:
				Global.CONSTANT_CATEGORIES.NULL:
					pass
				_:
					var category_name: String = Global.CONSTANT_CATEGORIES.keys()[calculator.constant_category]
					var grouped_constants: Array[Array] = Utils.group(Utils.dictionary_to_key_value_pairs(Global.CONSTANTS[category_name]), 2)
					var constants_container: VBoxContainer = VBoxContainer.new()
					
					for grouped_constant_props in grouped_constants:
						var group_container: HBoxContainer = HBoxContainer.new()
						
						#group_container.add_theme_constant_override('separation', 0)
						
						for constant_props in grouped_constant_props:
							var constant_name: String = constant_props.key.capitalize()
							var constant: Dictionary = constant_props.value
							var constant_button: Button = Button.new()
							
							constant_button.add_theme_font_override('font', Global.DEFAULT_FONT)
							constant_button.add_theme_font_size_override('font_size', 20)
							constant_button.flat = true
							constant_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
							constant_button.custom_minimum_size = Vector2(250, 0)
							constant_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
							constant_button.text = constant.display + ', ' + constant_name
							constant_button.pressed.connect(
								func():
									calculator.create_entry(Global.ENTRY_TYPES.CONSTANT, constant_props.value)
									calculator.tab = Global.TABS.MAIN
									
									display()
							)
							
							group_container.add_child(constant_button)
						
						constants_container.add_child(group_container)
					
					add_child(constants_container)

func set_constant_category(category: Global.CONSTANT_CATEGORIES):
	calculator.tab = Global.TABS.CONSTANT
	calculator.constant_category = category
	
	display()

func secondary_display(expression_entries: Entry, height: int = 0, input_cursor_position_counter: Ref = Ref.new(0)):
	var entry_components: Array[Node] = []
	
	for entry_index in range(expression_entries.value.size()):
		var entry: Entry = expression_entries.value[entry_index]
		
		match entry.type:
			Global.ENTRY_TYPES.PLAIN_PLACEHOLDER:
				entry_components.append(primary_display(input_cursor_position_counter, height, ALIGNMENT.END))
			Global.ENTRY_TYPES.NUMBER:
				for digit in entry.value:
					entry_components.append(primary_display(input_cursor_position_counter, height, ALIGNMENT.END, digit))
			Global.ENTRY_TYPES.POWER:
				var base: Entry = entry.value.base
				var exponent = entry.value.exponent
				
				match height:
					0:
						entry_components.append_array(secondary_display(base, 0, input_cursor_position_counter))
						entry_components.append_array(secondary_display(exponent, 50, input_cursor_position_counter))
					_:
						entry_components.append_array(secondary_display(base, height, input_cursor_position_counter))
						entry_components.append_array(secondary_display(exponent, height + 20, input_cursor_position_counter))
			Global.ENTRY_TYPES.PLACEHOLDER:
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
				#print('IN')
				
				render_input_cursor(placeholder_label, ALIGNMENT.CENTER, input_cursor_position_counter)
			Global.ENTRY_TYPES.LOGARITHM:
				var base = entry.value.base
				var argument = entry.value.argument
				
				entry_components.append(primary_display(input_cursor_position_counter, height, ALIGNMENT.END, 'log', true))
				match height:
					0:
						entry_components.append_array(secondary_display(base, -50, input_cursor_position_counter))
						entry_components.append_array(secondary_display(argument, 0, input_cursor_position_counter))
					_:
						entry_components.append_array(secondary_display(base, height - 20, input_cursor_position_counter))
						entry_components.append_array(secondary_display(argument, height, input_cursor_position_counter))
			Global.ENTRY_TYPES.SQUARE_ROOT:
				var radical_symbol: HBoxContainer = RADICAL_SYMBOL_PACKED_SCENE.instantiate()
				var index: Entry = entry.value.index
				var radicand: Entry = entry.value.radicand
				
				match height:
					0:
						radical_symbol.add_index_nodes.call_deferred(secondary_display(index, 25, input_cursor_position_counter))
						radical_symbol.add_radicand_nodes.call_deferred(secondary_display(radicand, 0, input_cursor_position_counter))
					_:
						radical_symbol.add_index_nodes.call_deferred(secondary_display(index, height + 20, input_cursor_position_counter))
						radical_symbol.add_radicand_nodes.call_deferred(secondary_display(radicand, height, input_cursor_position_counter))
				entry_components.append(radical_symbol)
			Global.ENTRY_TYPES.FRACTION:
				var fraction_container: VBoxContainer = VBoxContainer.new()
				var fraction_bar: ColorRect = ColorRect.new()
				
				fraction_bar.custom_minimum_size = Vector2(0, 2)
				
				for component_name in entry.value:
					var component_value = entry.value[component_name]
					var component_container: HBoxContainer = HBoxContainer.new()
					
					component_container.add_theme_constant_override('separation', 0)
					
					match height:
						0:
							for component_entry in secondary_display(component_value, 0, input_cursor_position_counter):
								component_container.add_child(component_entry)
						_:
							for component_entry in secondary_display(component_value, height, input_cursor_position_counter):
								component_entry.custom_minimum_size = Vector2(0, 0)
								component_container.add_child(component_entry)
					
					fraction_container.custom_minimum_size = Vector2(0, height * 2)
					fraction_container.add_child(component_container)
					
					if component_name == 'numerator':
						fraction_container.add_child(fraction_bar)
				
				entry_components.append(fraction_container)
			Global.ENTRY_TYPES.FUNCTION, Global.ENTRY_TYPES.CONSTANT:
				var display_text: String = ''
				
				match typeof(entry.value):
					TYPE_STRING:
						match entry.value:
							'asin(':
								display_text = 'sin⁻¹('
							'acos(':
								display_text = 'cos⁻¹('
							'atan(':
								display_text = 'tan⁻¹('
							'randf()':
								display_text = 'Ran#'
							'randi_range(':
								display_text = 'RandInt#('
							'log_with_base(10,':
								display_text = 'log('
							_:
								display_text = entry.value
					TYPE_DICTIONARY:
						display_text = entry.value.display
				
				entry_components.append(primary_display(input_cursor_position_counter, height, ALIGNMENT.END, display_text))
			Global.ENTRY_TYPES.PERMUTATION, Global.ENTRY_TYPES.COMBINATION:
				var n = entry.value.n
				var r = entry.value.r
				
				entry_components.append_array(secondary_display(n, 50, input_cursor_position_counter))
				
				var label: Label = Utils.create_label()
				
				label.add_theme_font_size_override('font_size', 30)
				
				match entry.type:
					Global.ENTRY_TYPES.PERMUTATION:
						label.text = 'P'
					Global.ENTRY_TYPES.COMBINATION:
						label.text = 'C'
				
				entry_components.append(label)
				
				entry_components.append_array(secondary_display(r, -50, input_cursor_position_counter))
			Global.ENTRY_TYPES.MODULUS:
				var modulus_container: HBoxContainer = HBoxContainer.new()
				var line: ColorRect = ColorRect.new()
				var modulus_wrapper: HBoxContainer = HBoxContainer.new()
				
				line.custom_minimum_size = Vector2(2, 0)
				
				match height:
					0:
						modulus_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
					_:
						if height > 0:
							modulus_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
						else:
							modulus_container.size_flags_vertical = Control.SIZE_SHRINK_END
				
				modulus_container.add_theme_constant_override('separation', 0)
				modulus_container.add_child(line)
				
				for node in secondary_display(entry.value.arg, height, input_cursor_position_counter): # input_cursor_position_counter.value, input_cursor_position_counter):
					node.custom_minimum_size = Vector2.ZERO
					modulus_container.add_child(node)
				
				modulus_container.add_child(line.duplicate())
				modulus_wrapper.custom_minimum_size = Vector2(0, height)
				modulus_wrapper.add_child(modulus_container)
				entry_components.append(modulus_wrapper)
			Global.ENTRY_TYPES.FACTORIAL:
				var exclamation_mark_label: Label = Utils.create_label()
				
				entry_components.append(primary_display(input_cursor_position_counter, height, ALIGNMENT.END, '!', true))
				entry_components.append_array(secondary_display(entry.value.arg, height, input_cursor_position_counter)) # input_cursor_position_counter.value, input_cursor_position_counter))
				
				entry_components.append(exclamation_mark_label)
			_:
				entry_components.append(primary_display(input_cursor_position_counter, height, ALIGNMENT.END, entry.value))
	
	return entry_components

func primary_display(input_cursor_position_counter: Ref, height: int, cursor_alignment: ALIGNMENT = ALIGNMENT.END, value: String = '', no_impact_to_cursor: bool = false):
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
	entry_container.add_child(entry_label)
	
	if not no_impact_to_cursor:
		input_cursor_position_counter.value += 1
		
		render_input_cursor(entry_label, cursor_alignment, input_cursor_position_counter)
	
	return entry_container

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
	if input_cursor_position_counter.value == calculator.input_cursor_position:
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
