extends Node2D

var constant_category: Global.CONSTANT_CATEGORIES = Global.CONSTANT_CATEGORIES.NULL
var constants_container: VBoxContainer = VBoxContainer.new()
var constant_label: Label = Utils.create_label()

func _ready() -> void:
	var horizontal_container: HBoxContainer = HBoxContainer.new()
	var constant_categories_container: VBoxContainer = VBoxContainer.new()
	var placeholder_style: StyleBoxFlat = StyleBoxFlat.new()
	
	placeholder_style.bg_color = Color.TRANSPARENT
	placeholder_style.border_color = Color.WHITE
	placeholder_style.set_border_width_all(2)
	placeholder_style.set_corner_radius_all(3)
	
	#horizontal_container.add_theme_constant_override('separation', 0)
	#constants_container.add_theme_constant_override('separation', 0)
	constant_categories_container.add_theme_constant_override('separation', 0)
	
	constant_label.add_theme_font_size_override('font_size', 30)
	constant_label.add_theme_stylebox_override('normal', placeholder_style)
	constant_label.size_flags_vertical = Control.SIZE_FILL
	constant_label.text = ' '
	
	for constant_category_index in range(Global.CONSTANTS.size()):
		var constant_category_name: String = Global.CONSTANTS.keys()[constant_category_index].capitalize()
		var constant_category_button: Button = Button.new()
		
		constant_category_button.pressed.connect(set_constant_category.bind(constant_category_index))
		constant_category_button.text = constant_category_name
		constant_categories_container.add_child(constant_category_button)
	
	horizontal_container.add_child(constant_categories_container)
	horizontal_container.add_child(constants_container)
	horizontal_container.add_child(constant_label)
	add_child(horizontal_container)

func set_constant_category(category: Global.CONSTANT_CATEGORIES):
	constant_category = category
	
	render_category_tab()

func render_category_tab():
	if constants_container.get_child_count() > 0:
		Utils.remove_children(constants_container)
	
	match constant_category:
		Global.CONSTANT_CATEGORIES.NULL:
			pass
		_:
			var category_name: String = Global.CONSTANT_CATEGORIES.keys()[constant_category]
			var grouped_constants: Array[Array] = Utils.group(Utils.dictionary_to_key_value_pairs(Global.CONSTANTS[category_name]), 2)
			
			for grouped_constant_props in grouped_constants:
				var group_container: HBoxContainer = HBoxContainer.new()
				
				#group_container.add_theme_constant_override('separation', 0)
				
				for constant_props in grouped_constant_props:
					var constant_name: String = constant_props.key.capitalize()
					var constant: Dictionary = constant_props.value
					var constant_button: Button = Button.new()
					
					constant_button.custom_minimum_size = Vector2(250, 0)
					constant_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					constant_button.text = constant.display + ', ' + constant_name
					
					if 'exp' in constant:
						constant_button.pressed.connect(display_constant_value.bind(constant.display, constant.value, constant.exp))
					else:
						constant_button.pressed.connect(display_constant_value.bind(constant.display, constant.value))
					
					group_container.add_child(constant_button)
				
				constants_container.add_child(group_container)

func display_constant_value(display: String, constant_value: float, exponent = null):
	if exponent != null:
		constant_label.text = display + ': ' + str(constant_value) + '^' + str(exponent)
	else:
		constant_label.text = display + ': ' + str(constant_value)
