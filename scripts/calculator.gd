extends VBoxContainer

var is_shifted: bool = false
var entries: Entry = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER)])
var input_cursor_position: int = 1
var tab: Global.TABS = Global.TABS.MAIN
var constant_category: Global.CONSTANT_CATEGORIES = Global.CONSTANT_CATEGORIES.NULL

func get_entry(input_cursor_coords) -> Entry:
	var entry: Entry = null
	
	if input_cursor_coords.size() > 0:
		for input_cursor_coord in input_cursor_coords:
			match typeof(input_cursor_coord):
				TYPE_ARRAY:
					if entry == null: entry = entries.value[input_cursor_coord[0]]
					else: entry = entry.value[input_cursor_coord[0]]
				TYPE_INT, TYPE_STRING_NAME:
					if entry == null: entry = entries.value[input_cursor_coord]
					else: entry = entry.value[input_cursor_coord]
	else:
		entry = entries
	
	return entry

func get_current_entry() -> Entry: return get_entry(Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries))

func get_previous_entry() -> Entry:
	var input_cursor_coords: Array = Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries)
	
	if input_cursor_coords.size() > 0:
		var last_coord = input_cursor_coords[input_cursor_coords.size() - 1]
		
		match typeof(last_coord):
			TYPE_ARRAY:
				if last_coord[0] - 1 >= 0: last_coord[0] -= 1
				else: return null
			TYPE_INT, TYPE_STRING_NAME:
				if last_coord - 1 >= 0: last_coord -= 1
				else: return null
	
	return get_entry(input_cursor_coords)

func get_next_entry() -> Entry:
	var input_cursor_coords: Array = Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries)
	
	if input_cursor_coords.size() > 0:
		var last_coord = input_cursor_coords.pop_back()
		
		match typeof(last_coord):
			TYPE_ARRAY:
				if last_coord[0] + 1 < get_entry(input_cursor_coords).value.size(): last_coord[0] += 1
				else: return null
			TYPE_INT, TYPE_STRING_NAME:
				if last_coord + 1 < get_entry(input_cursor_coords).value.size(): last_coord += 1
				else: return null
	
		input_cursor_coords.append(last_coord)
	
	return get_entry(input_cursor_coords)

func get_entries_holder(input_cursor_coords: Array, layer: Ref = Ref.new(2)):
	for i in range(input_cursor_coords.size() + 1):
		#print(Utils.get_entry_type_name(get_entry(input_cursor_coords).type))
		match get_entry(input_cursor_coords).type:
			Global.ENTRY_TYPES.ENTRIES:
				layer.value -= 1
				
				match layer.value:
					0: return input_cursor_coords
		
		input_cursor_coords.pop_back()

func create_entry(type: Global.ENTRY_TYPES, value) -> void:
	var current_entry: Entry = get_current_entry()
	var input_cursor_coords: Array = Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries)
	
	match current_entry.type:
		Global.ENTRY_TYPES.PLACEHOLDER:
			insert_entry(input_cursor_coords.duplicate_deep(), Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER), 0)
			current_entry.type = type
			current_entry.value = value
		Global.ENTRY_TYPES.NUMBER:
			var number_entry: Entry = get_entry(input_cursor_coords)
			var number_coords: Array = input_cursor_coords.pop_back()
			var number_index: int = number_coords[0]
			var slice_index: int = number_coords[1]
			var sliced_number: Array[String] = Utils.slice_text(current_entry.value, slice_index)
			
			if input_cursor_coords.size() == 0 or input_cursor_coords.size() > 0 and input_cursor_coords[-1] != &'base':
				var entries_holder: Entry = get_entry(input_cursor_coords)
				
				entries_holder.value.pop_at(number_index)
				entries_holder.value.insert(number_index, Entry.new(Global.ENTRY_TYPES.NUMBER, sliced_number[0]))
				entries_holder.value.insert(number_index + 1, Entry.new(type, value))
				
				if sliced_number.size() > 1:
					entries_holder.value.insert(number_index + 2, Entry.new(Global.ENTRY_TYPES.NUMBER, sliced_number[1]))
			else:
				input_cursor_coords.pop_back() # pop `&'base'` from the 'input_cursor_coords' array.
				var power_index: int = input_cursor_coords.pop_back()
				var outer_entries_holder: Entry = get_entry(input_cursor_coords)
				
				outer_entries_holder.value.insert(power_index, Entry.new(Global.ENTRY_TYPES.NUMBER, sliced_number[0]))
				outer_entries_holder.value.insert(power_index + 1, Entry.new(type, value))
				
				if sliced_number.size() > 1:
					number_entry.value = sliced_number[1]
				else:
					number_entry.type = Global.ENTRY_TYPES.PLACEHOLDER
					number_entry.value = null
		_:
			var insert_index: int = input_cursor_coords.pop_back()
			
			get_entry(input_cursor_coords).value.insert(insert_index + 1, Entry.new(type, value))
	
	input_cursor_position += 1

func create_entries(...local_entries: Array) -> void:
	var current_entry: Entry = get_current_entry()
	var input_cursor_coords: Array = Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries)
	
	match current_entry.type:
		Global.ENTRY_TYPES.PLACEHOLDER:
			insert_entry(input_cursor_coords.duplicate_deep(), Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER), 0)
			for entry_index in range(local_entries.size()):
				var entry: Entry = local_entries[entry_index]
				
				match entry_index:
					0:
						current_entry.type = entry.type
						current_entry.value = entry.value
					_:
						insert_entry(input_cursor_coords.duplicate_deep(), entry, entry_index + 1)
		Global.ENTRY_TYPES.NUMBER:
			var number_entry: Entry = get_entry(input_cursor_coords)
			var number_coords: Array = input_cursor_coords.pop_back()
			var number_index: int = number_coords[0]
			var slice_index: int = number_coords[1]
			var sliced_number: Array[String] = Utils.slice_text(current_entry.value, slice_index)
			
			if input_cursor_coords.size() == 0 or input_cursor_coords.size() > 0 and input_cursor_coords[-1] != &'base':
				var entries_holder: Entry = get_entry(input_cursor_coords)
				
				entries_holder.value.pop_at(number_index)
				entries_holder.value.insert(number_index, Entry.new(Global.ENTRY_TYPES.NUMBER, sliced_number[0]))
				
				for entry_index in range(local_entries.size()):
					var entry: Entry = local_entries[entry_index]
					
					entries_holder.value.insert(number_index + entry_index + 1, entry)
				
				if sliced_number.size() > 1:
					entries_holder.value.insert(number_index + local_entries.size() + 1, Entry.new(Global.ENTRY_TYPES.NUMBER, sliced_number[1]))
			else:
				input_cursor_coords.pop_back() # pop `&'base'` from the 'input_cursor_coords' array.
				var power_index: int = input_cursor_coords.pop_back()
				var outer_entries_holder: Entry = get_entry(input_cursor_coords)
				
				outer_entries_holder.value.insert(power_index, Entry.new(Global.ENTRY_TYPES.NUMBER, sliced_number[0]))
				
				for entry_index in range(local_entries.size()):
					var entry: Entry = local_entries[entry_index]
					
					outer_entries_holder.value.insert(power_index + entry_index + 1, entry)
				
				if sliced_number.size() > 1:
					number_entry.value = sliced_number[1]
				else:
					number_entry.type = Global.ENTRY_TYPES.PLACEHOLDER
					number_entry.value = null
		_:
			var insert_index: int = input_cursor_coords.pop_back()
			
			for entry_index in range(local_entries.size()):
				var entry: Entry = local_entries[entry_index]
				
				get_entry(input_cursor_coords).value.insert(insert_index + entry_index + 1, entry)
	
	input_cursor_position += 1

func create_number_entry(value: String) -> void:
	var current_entry: Entry = get_current_entry()
	var input_cursor_coords: Array = Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries)
	
	match current_entry.type:
		Global.ENTRY_TYPES.PLACEHOLDER:
			insert_entry(input_cursor_coords, Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER), 0)
			current_entry.type = Global.ENTRY_TYPES.NUMBER
			current_entry.value = value
		Global.ENTRY_TYPES.PLAIN_PLACEHOLDER:
			var next_entry: Entry = get_next_entry()
			
			match next_entry:
				null:
					insert_entry(input_cursor_coords.duplicate_deep(), Entry.new(Global.ENTRY_TYPES.NUMBER, value), 1)
				_:
					match next_entry.type:
						Global.ENTRY_TYPES.NUMBER:
							input_cursor_coords[input_cursor_coords.size() - 1] = [input_cursor_coords[input_cursor_coords.size() - 1] + 1, -1]
							insert_number(input_cursor_coords.duplicate_deep(), value)
						_:
							insert_entry(input_cursor_coords.duplicate_deep(), Entry.new(Global.ENTRY_TYPES.NUMBER, value), 1)
		Global.ENTRY_TYPES.NUMBER:
			insert_number(input_cursor_coords.duplicate_deep(), value)
		_:
			insert_entry(input_cursor_coords.duplicate_deep(), Entry.new(Global.ENTRY_TYPES.NUMBER, value), 1)
	
	input_cursor_position += 1

func insert_number(input_cursor_coords: Array, value: String) -> void:
	var number_coords: Array = input_cursor_coords.pop_back()
	var number_index: int = number_coords[0]
	var insert_index: int = number_coords[1]
	var number_entry: Entry = null
	
	number_entry = get_entry(input_cursor_coords).value[number_index]
	number_entry.value = number_entry.value.insert(insert_index + 1, value)

func insert_entry(input_cursor_coords: Array, entry: Entry, offset: int = 0):
	var insert_index: int = input_cursor_coords.pop_back()
	var entries_holder: Entry = get_entry(input_cursor_coords)
	
	entries_holder.value.insert(insert_index + offset, entry)

func create_power_entry(exponent_value: String):
	var current_entry: Entry = get_current_entry()
	var input_cursor_coords: Array = Utils.get_input_cursor_coords(Ref.new(input_cursor_position), entries)
	var exponent_entries: Array[Entry] = []
	
	match exponent_value:
		'':
			exponent_entries = [Entry.new(Global.ENTRY_TYPES.PLACEHOLDER)]
		_:
			exponent_entries = [Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER), Entry.new(Global.ENTRY_TYPES.NUMBER, exponent_value)]
	
	match current_entry.type:
		Global.ENTRY_TYPES.NUMBER:
			var number_entry: Entry = get_entry(input_cursor_coords)
			var number_coords: Array = input_cursor_coords.pop_back()
			var number_index: int = number_coords[0]
			var slice_index: int = number_coords[1]
			var sliced_number: Array[String] = Utils.slice_text(current_entry.value, slice_index)
			
			if input_cursor_coords.size() == 0 or input_cursor_coords.size() > 0 and input_cursor_coords[-1] != &'base':
				var entries_holder: Entry = get_entry(input_cursor_coords)
				
				entries_holder.value.pop_at(number_index)
				entries_holder.value.insert(number_index, Entry.new(Global.ENTRY_TYPES.POWER, {
					base = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.NUMBER, sliced_number[0])]),
					exponent = Entry.new(Global.ENTRY_TYPES.ENTRIES, exponent_entries)
				}))
				entries_holder.value.insert(number_index + 1, Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER))
				
				if sliced_number.size() > 1:
					entries_holder.value.insert(number_index + 2, Entry.new(Global.ENTRY_TYPES.NUMBER, sliced_number[1]))
			else:
				input_cursor_coords.pop_back() # pop `&'base'` from the 'input_cursor_coords' array.
				var power_index: int = input_cursor_coords.pop_back()
				var outer_entries_holder: Entry = get_entry(input_cursor_coords)
				
				outer_entries_holder.value.insert(power_index, Entry.new(Global.ENTRY_TYPES.POWER, {
					base = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.NUMBER, sliced_number[0])]),
					exponent = Entry.new(Global.ENTRY_TYPES.ENTRIES, exponent_entries)
				}))
				outer_entries_holder.value.insert(power_index + 1, Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER))
				
				if sliced_number.size() > 1:
					number_entry.value = sliced_number[1]
				else:
					number_entry.type = Global.ENTRY_TYPES.PLACEHOLDER
					number_entry.value = null
		_:
			var insert_index: int = input_cursor_coords.pop_back()
			var entries_holder: Entry = get_entry(input_cursor_coords)
			
			entries_holder.value.insert(insert_index + 1, Entry.new(Global.ENTRY_TYPES.POWER, {
				base = Entry.new(Global.ENTRY_TYPES.ENTRIES, [Entry.new(Global.ENTRY_TYPES.PLACEHOLDER)]),
				exponent = Entry.new(Global.ENTRY_TYPES.ENTRIES, exponent_entries)
			}))
			entries_holder.value.insert(insert_index + 2, Entry.new(Global.ENTRY_TYPES.PLAIN_PLACEHOLDER))
	
	input_cursor_position += 1
