class_name Entry extends Node

var type: Global.ENTRY_TYPES
var value = null

func _init(init_type: Global.ENTRY_TYPES = Global.ENTRY_TYPES.PLACEHOLDER, init_value = null) -> void:
	type = init_type
	strict_validation_before_assignment(init_value)

func strict_validation_before_assignment(entry_value) -> void:
	match type:
		# Base Entry Type
		Global.ENTRY_TYPES.ENTRIES:
			# Entry Type – Responsible for holding an array of valid entries.
			match typeof(entry_value):
				TYPE_ARRAY:
					value = entry_value
				_:
					type = Global.ENTRY_TYPES.ERROR
					value = 'Entries value only accepts an array of valid entry types.'
		# Primary Entry Types
		Global.ENTRY_TYPES.PLAIN_PLACEHOLDER:
			# Commonly used as an invisible placeholder to help transition the input cursor between entries.
			match typeof(entry_value):
				TYPE_NIL:
					value = entry_value
				_:
					type = Global.ENTRY_TYPES.ERROR
					value = 'PLAIN PLACEHOLDER ERROR: Plain placeholders do not accept any value.'
		Global.ENTRY_TYPES.PLACEHOLDER:
			# Commonly used as a placeholder meant to be replaced by another entry later.
			match typeof(entry_value):
				TYPE_NIL:
					value = entry_value
				_:
					type = Global.ENTRY_TYPES.ERROR
					value = 'PLACEHOLDER ERROR: Placeholder entries do not accept any value.'
		Global.ENTRY_TYPES.NUMBER:
			# An entry that stores a stringified number.
			# Note: 'Number' includes both integers and floating-point values.
			match typeof(entry_value):
				TYPE_STRING:
					if entry_value.is_valid_int() or entry_value.is_valid_float():
						value = entry_value
					else:
						type = Global.ENTRY_TYPES.ERROR
						value = 'NUMBER ERROR: ' + entry_value + ' is not a valid number.'
				_:
					type = Global.ENTRY_TYPES.ERROR
					value = 'NUMBER ERROR: Expected a stringified number, but received `' + Utils.get_type_name(typeof(entry_value)) + '` instead.'
		Global.ENTRY_TYPES.OPERATOR:
			# An entry representing a mathematical assignment operator.
			match typeof(entry_value):
				TYPE_STRING:
					if entry_value in ['+', '-', '*', '/', ')', '×', '÷', ',']:
						value = entry_value
					else:
						type = Global.ENTRY_TYPES.ERROR
						value = 'OPERATOR ERROR: Please provide a valid mathematical operator.'
				_:
					type = Global.ENTRY_TYPES.ERROR
					value = 'OPERATOR ERROR: Expected a stringified operator, but received `' + Utils.get_type_name(typeof(entry_value)) + '` instead.'
		Global.ENTRY_TYPES.VARIABLE:
			# An entry representing a variable whose value will be replaced during compilation.
			match typeof(entry_value):
				TYPE_STRING:
					value = entry_value
				_:
					type = Global.ENTRY_TYPES.ERROR
					value = 'VARIABLE ERROR: Expected a stringified variable, but received `' + Utils.get_type_name(typeof(entry_value)) + '` instead.'
		Global.ENTRY_TYPES.FUNCTION:
			# An entry representing built-in functions used at the backend.
			match typeof(entry_value):
				TYPE_STRING:
					value = entry_value
				_:
					type = Global.ENTRY_TYPES.ERROR
					value = 'FUNCTION ERROR: Expected a stringified function, but received `' + Utils.get_type_name(typeof(entry_value)) + '` instead.'
		Global.ENTRY_TYPES.CONSTANT:
			# An entry representing built-in constants that will be replaced with their corresponding values during compilation.
			match typeof(entry_value):
				TYPE_DICTIONARY:
					if 'display' in entry_value and 'value' in entry_value:
						match typeof(entry_value.display):
							TYPE_STRING:
								pass
							_:
								type = Global.ENTRY_TYPES.ERROR
								value = 'CONSTANT ERROR: The `display` parameter only accepts a string, but received `' + Utils.get_type_name(typeof(entry_value.display)) + '` instead.'
								return
						match typeof(entry_value.value):
							TYPE_INT, TYPE_FLOAT, TYPE_STRING:
								pass
							_:
								type = Global.ENTRY_TYPES.ERROR
								value = 'CONSTANT ERROR: The `value` parameter only accepts integers, floats, or strings, but received `' + Utils.get_type_name(typeof(entry_value.value)) + '` instead.'
								return
						if 'exp' in entry_value:
							match typeof(entry_value.exp):
								TYPE_INT:
									pass
								_:
									type = Global.ENTRY_TYPES.ERROR
									value = 'CONSTANT ERROR: The `exp` parameter only accepts an integer, but received `' + Utils.get_type_name(typeof(entry_value.exp)) + '` instead.'
						
						value = entry_value
				_:
					type = Global.ENTRY_TYPES.ERROR
					value = 'CONSTANT ERROR: Expected a stringified function, but received `' + Utils.get_type_name(typeof(entry_value)) + '` instead.'
		_:
			# Strict checking for secondary entry types is currently not supported.
			value = entry_value

"""
ENTRIES /
PLAIN_PLACEHOLDER /
PLACEHOLDER /
NUMBER /
OPERATOR /
CONSTANT /
FUNCTION /
VARIABLE /
POWER
LOGARITHM
SQUARE_ROOT
MODULUS
FACTORIAL
PERMUTATION
COMBINATION
FRACTION
"""
