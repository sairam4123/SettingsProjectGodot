extends Node

var settings_structure = []
var setting_values = {}
var settings_name_dict = {}  # {key: str, value: null}

var config: ConfigFile = ConfigFile.new()

func _get_settings_structure():
	var settings_data = []
	var gd_files = _get_dirs("*.gd", "*.gdc")
	for gd_file in gd_files:
		var script = load(gd_file)
		if script.has_method("_get_settings_list"):
			settings_data.append_array(script.call("_get_settings_list"))
	settings_name_dict.clear()
	settings_data = settings_data.filter(_validate_structure)
	settings_name_dict.clear()
	return settings_data

func _validate_structure(dict: Dictionary) -> bool:
	var _name = dict.get("name")
	if _name == null:
		push_error("Name not provided for setting")
		return false
	_name = str(_name)
	if settings_name_dict.has(_name):
		push_error("name already defined setting ", _name)
		return false
	var type = dict.get("type")
	if type == null:
		push_error("type not proided for setting ", _name)
		return false
	var disp_name = dict.get("display_name")
	if disp_name == null:
		push_warning("display_name not provided for setting %s, generating one!" % _name)
		dict["display_name"] = _name.capitalize()
		disp_name = _name.capitalize()
	var category = dict.get("category")
	if category == null:
		push_error("category not provided for setting ", _name)
		return false
	var default = dict.get("default")
	if default == null:
		push_warning("default not provided for setting %s, may cause issues" % _name)
	
	if type == GlobalEnums.OptionType.RANGE:
		var start = dict.get("start")
		if start == null:
			push_warning("start should be provided for range types for setting %s, defaulting to 0" % _name)
			start = 0
			dict["start"] = 0
		var stop = dict.get("stop")
		if stop == null:
			push_warning("stop should be provided for range types for setting %s, defaulting to 1" % _name)
			stop = 1
			dict["stop"] = 1
		var step = dict.get("step")
		if step == null:
			push_warning("step should be provided for range types for setting %s, defaulting to 0.01" % _name)
			step = 0.01
			dict["step"] = 0.01
	if type == GlobalEnums.OptionType.ENUM:
		var enum_values = dict.get("enum_values")
		if enum_values == null:
			push_error("enum_values must be provided for setting ", _name)
			return false
		enum_values = PackedStringArray(Array(enum_values).map(
			func(string: String):
				return string.capitalize()
		))
		dict["enum_values"] = enum_values
	return true


func _get_dirs(filter_mask: String = "", filter_mask2: String = "", filter_mask3: String = ""):
	var filter_dirs = func(_dirs):
		var _filtered_dirs = []
		for dir in _dirs:
			if dir.begins_with("."):
				continue
			_filtered_dirs.append(dir)
		return _filtered_dirs
	
	var _directory = "res://"
	var base = DirAccess.open(_directory)
	var dirs = base.get_directories()
	dirs = filter_dirs.call(dirs)
	var files = Array(base.get_files())
	files = files.map(func(file): return _directory.path_join(file))
	var queue = dirs.map(func(dir): return _directory.path_join(dir) + "/")
	while queue:
		var dir = queue.pop_front()
		var dir_acc = DirAccess.open(dir)
		if not dir_acc:
			continue
		var _dirs = dir_acc.get_directories()
		var _files = dir_acc.get_files()
		for _file in _files:
			files.append(dir.path_join(_file))
		_dirs = filter_dirs.call(_dirs)
		queue.append_array(_dirs.map(func(_dir): return dir.path_join(_dir) + "/"))
	
	var res = []
	for file in files:
		if file.match(filter_mask) or file.match(filter_mask2) or file.match(filter_mask3):
			res.append(file)
	return res

func get_categories():
	var categories = {}
	for setting in settings_structure:
		var category = setting.get("category", "Uncategorized")
		categories[category] = null
	return categories.keys()

func get_settings_for(category):
	var settings = settings_structure.filter(func(setting): return setting.get("category") == category)
	return settings

func get_settings_in(category):
	var settings = get_settings_for(category)
	return settings.map(func(setting): return setting.get("name"))

func get_setting_config(_name):
	var setting = settings_structure.filter(func(setting): return setting.get("name") == _name)
	if setting:
		setting = setting[0]
	return setting

func get_setting_value(_name: String):
	var setting_config = get_setting_config(_name)
	if setting_values.has(_name):
		return setting_values[_name]
	else:
		setting_values[_name] = setting_config.get("default")
		return setting_config.get("default")

func set_setting_value(_name: String, value: Variant):
	setting_values[_name] = value

func _ready() -> void:
	settings_structure = _get_settings_structure()
	load_settings()
	
func save_settings():
	config.clear()
	for cate in get_categories():
		for setting in get_settings_in(cate):
			config.set_value(cate, setting, get_setting_value(setting))
	config.save("user://options.cfg")

func load_settings():
	config.clear()
	config.load("user://options.cfg")
	for cate in get_categories():
		for setting_config in get_settings_for(cate):
			set_setting_value(setting_config.name, config.get_value(cate, setting_config.name, setting_config.default))
