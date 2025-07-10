class_name Entry extends Node

var type: Global.TYPE
var value = null

func _init(init_type: Global.TYPE = Global.TYPE.PLACEHOLDER, init_value = null) -> void:
	type = init_type
	
	match type:
		# Primary entries types
		Global.TYPE.ENTRIES:
			# Entries type - In charge of holiding an array of valid entries.
			match typeof(init_value):
				TYPE_ARRAY:
					value = init_value
				_:
					type = Global.TYPE.ERROR
					value = 'Entries value only accept array type.'
		Global.TYPE.PLAIN_PLACEHOLDER:
			# Commonly use as a placeholder for input cursor to transition between them, but they are invisible.
			match typeof(init_value):
				TYPE_NIL:
					value = init_value
				_:
					type = Global.TYPE.ERROR
					value = 'PLAIN PLACEHOLDER ERROR: Plain placeholder doesn\'t take any value.'
		Global.TYPE.PLACEHOLDER:
			# commonly use as a placeholder to be replace later on.
			match typeof(init_value):
				TYPE_NIL:
					value = init_value
				_:
					type = Global.TYPE.ERROR
					value = 'PLACEHOLDER ERROR: Placeholder entry does not take any value'
		Global.TYPE.NUMBER:
			# An entry to store stringified number. Take note that number is the union type of integers and floats.
			match typeof(init_value):
				TYPE_STRING:
					if init_value.is_valid_int() or init_value.is_valid_float():
						value = init_value
					else:
						type = Global.TYPE.ERROR
						value = 'NUMBER ERROR: ' + init_value + 'is not a valid number.'
				_:
					type = Global.TYPE.ERROR
					value = 'NUMBER ERROR: Expected stringified number but got `' + Utils.get_type_name(typeof(init_value)) + '` instead.'
		Global.TYPE.OPERATOR:
			# An entry type to hold assignment operators in math.
			match typeof(init_value):
				TYPE_STRING:
					if init_value in ['+', '-', '*', '/', ')', '×', '÷']:
						value = init_value
					else:
						type = Global.TYPE.ERROR
						value = 'OPERATOR ERROR: Please enter a valid mathematical operator.'
				_:
					type = Global.TYPE.ERROR
					value = 'OPERATOR ERROR: Expected stringified mathematical opearor but got `'+ Utils.get_type_name(typeof(init_value)) +'` instead.'
		Global.TYPE.VARIABLE:
			# An entry type that hold variable that will soon getting replace its value during compilation.
			match typeof(init_value):
				TYPE_STRING:
					value = init_value
				_:
					type = Global.TYPE.ERROR
					value = 'VARIABLE ERROR: Expected stringified variable but got `'+ Utils.get_type_name(typeof(init_value)) +'` instead.'
		Global.TYPE.FUNCTION:
			# An entry type that hold built-in functions at the backend.
			match typeof(init_value):
				TYPE_STRING:
					value = init_value
				_:
					type = Global.TYPE.ERROR
					value = 'FUNCTION ERROR: Expected stringified function but got `'+ Utils.get_type_name(typeof(init_value)) +'` instead.'
		Global.TYPE.CONSTANT:
			# An entry type that hold built-in constants at the backend and will soon replace by the value of the repective constant value during compilation.
			match typeof(init_value):
				TYPE_STRING:
					value = init_value
				_:
					type = Global.TYPE.ERROR
					value = 'CONSTANT ERROR: Expected stringified function but got `'+ Utils.get_type_name(typeof(init_value)) +'` instead.'
		_:
			# Secondary entries strict checking is temporarily not suported.
			value = init_value
