extends Node

var SettingOption = preload("res://option.tscn")

var settings_container = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var categories = SettingsManager.get_categories()  # settings call
	var i = 1
	
	for category in categories:
		var btn = %CategoryButton.duplicate()
		btn.text = category
		btn.show()
		btn.pressed.connect(_handle_tab_change.bind(i))
		%Categories.add_child(btn)
		
		# addition of containers
		var container = %Settings.duplicate()
		%TabContainer.add_child(container)
		
		# populate settings
		var settings = SettingsManager.get_settings_for(category)  # settings call
		var cate_option = SettingOption.instantiate()
		cate_option.type = GlobalEnums.OptionType.TITLE
		cate_option._name = category
		cate_option._id = category
		container.add_child(cate_option)
		for setting in settings:
			var _set_option = SettingOption.instantiate()
			# configure the settings
			_set_option._name = setting.display_name
			_set_option._id = setting.name
			_set_option.type = setting.type
			_set_option.default = setting.default
			if setting.type == GlobalEnums.OptionType.RANGE:
				_set_option.start = setting.start
				_set_option.stop = setting.stop
				_set_option.step = setting.step
			if setting.type == GlobalEnums.OptionType.ENUM:
				_set_option.enum_values = setting.enum_values
			
			container.add_child(_set_option)
			
			# set the current value or the default
			_set_option._value = SettingsManager.get_setting_value(setting.name)  # settings call
			_set_option.value_changed.connect(_on_value_changed.bind(setting.name))
			settings_container[setting] = _set_option
		
		i += 1
	var first_button = %Categories.get_child(2)
	first_button.button_pressed = true
	first_button.pressed.emit()

func _handle_tab_change(index):
	%TabContainer.current_tab = index

func _handle_setting_changed():
	var cates = SettingsManager.get_categories()
	for cate in cates:
		for setting in SettingsManager.get_settings_for(cate):
			SettingsManager.set_setting_value(setting.name, settings_container[setting]._value)

func _on_save_button_pressed() -> void:
	_handle_setting_changed()
	_show_saving()
	SettingsManager.save_settings()

func _on_value_changed(value: Variant, setting: String):
	SettingsManager.set_setting_value(setting, value)
	#_show_saving()
	$DebounceTimer.start()
	


func _on_debounce_timer_timeout() -> void:
	print("saving settings")
	_show_saving()
	SettingsManager.save_settings()

func _show_saving():
	var text_leng = len(%SavingLabel.text)
	var tween = create_tween()
	tween.tween_callback(%SavingLabel.show)
	tween.tween_property(%SavingLabel, "visible_characters", text_leng, $DebounceTimer.wait_time/2).from(text_leng-3)
	tween.tween_property(%SavingLabel, "visible_characters", text_leng, $DebounceTimer.wait_time/2).from(text_leng-3)
	tween.tween_callback(%SavingLabel.hide)


func _on_reset_button_pressed() -> void:
	var cates = SettingsManager.get_categories()
	for cate in cates:
		for setting in SettingsManager.get_settings_for(cate):
			SettingsManager.set_setting_value(setting.name, setting.default)
			settings_container[setting]._value = setting.default

