@tool
extends BoxContainer

signal value_changed(value: Variant)

@export var _id: String = "option_name"

@export var _name: String = "Option Name":
	set(val):
		_name = val
		if is_inside_tree():
			_update_name()
			

enum OptionType {
	INT, FLOAT, STRING, COLOR, RANGE, TITLE, BOOL, ENUM
}

@export var type: OptionType = OptionType.INT:
	set(val):
		type = val
		if is_inside_tree():
			_update_type()
		notify_property_list_changed()

var _value: Variant:
	set(val):
		_value = val
		value_changed.emit(_value)
		if is_inside_tree():
			if type == OptionType.TITLE:
				%ResetButton.hide()
			elif _value != null and type != OptionType.TITLE:
				%ResetButton.show()
				%ResetButton.modulate.a = int(not is_same(_value, default))
			_update_value()
	
var default: Variant

var start := 0.0
var stop := 100.0
var step := 1.0
var enum_values: PackedStringArray = PackedStringArray()

func _ready():
	_update_name()
	_update_type()

func _update_name():
	%Title.text = _name

func _update_value():
	match type:
		OptionType.INT:
			if _value != null and typeof(_value) == TYPE_INT:
				%Int.value = _value
			else:
				%Int.value = default
			
		OptionType.STRING:
			if _value != null and typeof(_value) == TYPE_STRING:
				%String.text = str(_value)
				%String.caret_column = len(%String.text)
			else:
				%String.text = str(default)
			
		OptionType.COLOR:
			if _value != null and typeof(_value) == TYPE_COLOR:
				%Color.color = _value
			else:
				%Color.color = default
				
		OptionType.FLOAT:
			if _value != null and typeof(_value) == TYPE_FLOAT:
				%Float.value = _value
			else:
				%Float.value = default
		OptionType.RANGE:
			_update_range_value()
		OptionType.BOOL:
			if _value != null and typeof(_value) == TYPE_BOOL:
				%Bool.button_pressed = _value
			else:
				%Bool.button_pressed = default
		OptionType.ENUM:
			_update_enum_value()

func _update_type():
	%Int.hide()
	%Float.hide()
	%Range.hide()
	%Color.hide()
	%String.hide()
	%Bool.hide()
	%Enum.hide()
	vertical = false
	
	match type:
		OptionType.INT:
			%Int.show()
			if _value != null and typeof(_value) == TYPE_INT:
				%Int.value = _value
			else:
				%Int.value = default
			
		OptionType.STRING:
			%String.show()
			if _value != null and typeof(_value) == TYPE_STRING:
				%String.text = str(_value)
			else:
				%String.text = str(default)
			
		OptionType.COLOR:
			%Color.show()
			if _value != null and typeof(_value) == TYPE_COLOR:
				%Color.color = _value
			else:
				%Color.color = default
				
		OptionType.FLOAT:
			%Float.show()
			if _value != null and typeof(_value) == TYPE_FLOAT:
				%Float.value = _value
			else:
				%Float.value = default
		OptionType.RANGE:
			%Range.show()
			_update_range_value()
		OptionType.BOOL:
			%Bool.show()
			if _value != null and typeof(_value) == TYPE_BOOL:
				%Bool.button_pressed = _value
			else:
				%Bool.button_pressed = default
		OptionType.ENUM:
			%Enum.show()
			_update_enum_value()

func _update_enum_value():
	%Enum.clear()
	for item in enum_values:
		%Enum.add_item(item)
	if _value != null:
		%Enum.select(_value)
	else:
		%Enum.select(default)

func _update_range_value():
	var slider_node := %Range/Slider as HSlider
	var value_node = %Range/Value as LineEdit
	slider_node.min_value = start
	slider_node.max_value = stop
	slider_node.step = step
	if _value != null:
		slider_node.set_value_no_signal(_value)
		value_node.text = ("%.{0}f".format([step_decimals(step)])) % slider_node.value
	else:
		slider_node.set_value_no_signal(default)
		value_node.text = ("%.{0}f".format([step_decimals(step)])) % slider_node.value


#region EDITOR_ONLY
func _get_property_list() -> Array[Dictionary]:
	var arr: Array[Dictionary] = []
	match type:
		OptionType.INT:
			arr.append({
				"name": "value",
				"type": TYPE_INT
			})
			arr.append({
				"name": "default",
				"type": TYPE_INT
			})
		OptionType.STRING:
			arr.append({
				"name": "value",
				"type": TYPE_STRING
			})
			arr.append({
				"name": "default",
				"type": TYPE_STRING
			})
		OptionType.FLOAT:
			arr.append({
				"name": "value",
				"type": TYPE_FLOAT
			})
			arr.append({
				"name": "default",
				"type": TYPE_FLOAT
			})
		OptionType.COLOR:
			arr.append({
				"name": "value",
				"type": TYPE_COLOR
			})
			arr.append({
				"name": "default",
				"type": TYPE_COLOR
			})
		OptionType.BOOL:
			arr.append({
				"name": "value",
				"type": TYPE_BOOL
			})
			arr.append({
				"name": "default",
				"type": TYPE_BOOL
			})
		OptionType.ENUM:
			arr.append({
				"name": "value",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": ",".join(enum_values)
			})
			arr.append({
				"name": "default",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": ",".join(enum_values)
			})
			arr.append({
				"name": "enum/values",
				"type": TYPE_PACKED_STRING_ARRAY,
			})
			
		OptionType.RANGE:
			arr.append({
				"name": "value",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "%.5f,%.5f,%.5f" % [start, stop, step]
			})
			arr.append({
				"name": "default",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "%.5f,%.5f,%.5f" % [start, stop, step]
			})
			arr.append({
				"name": "range/start",
				"type": TYPE_FLOAT
			})
			arr.append({
				"name": "range/stop",
				"type": TYPE_FLOAT
			})
			arr.append({
				"name": "range/step",
				"type": TYPE_FLOAT
			})
	return arr

func _get(property: StringName) -> Variant:
	if property == "value":
		return _value
	elif property == "default":
		return default
	
	if type == OptionType.RANGE:
		if property == "range/start":
			return start
		if property == "range/stop":
			return stop
		if property == "range/step":
			return step
	if type == OptionType.ENUM:
		if property == "enum/values":
			return enum_values
	
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property == "value":
		_value = value
		return true
	elif property == "default":
		default = value
		return true
		
	if type == OptionType.RANGE:
		if property == "range/start":
			start = value
			notify_property_list_changed()
			return true
		if property == "range/stop":
			stop = value
			notify_property_list_changed()
			return true
		if property == "range/step":
			step = value
			notify_property_list_changed()
			return true
	if type == OptionType.ENUM:
		if property == "enum/values":
			enum_values = value
			notify_property_list_changed()
			return true
	return false
#endregion EDITOR_ONLY

func _on_int_value_changed(value: int) -> void:
	_value = value

func _on_float_value_changed(value: float) -> void:
	_value = value

func _on_slider_value_changed(value: float) -> void:
	_value = value

func _on_color_color_changed(color: Color) -> void:
	_value = color

func _on_string_text_changed(new_text: String) -> void:
	_value = new_text

func _on_reset_button_pressed() -> void:
	_value = default

func _on_bool_toggled(toggled_on: bool) -> void:
	_value = toggled_on

func _on_enum_item_selected(index: int) -> void:
	_value = index
