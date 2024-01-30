extends Node


static func _get_settings_list():
	return [
		{
			"category": "Audio",
			"name": "test_setting",
			"display_name": "Test Setting",
			"type": GlobalEnums.OptionType.INT,
			"default": 10
		},
		{
			"category": "Audio",
			"name": "old_setting",
			"display_name": "Old Setting",
			"type": GlobalEnums.OptionType.INT,
			"default": 10
		},
		{
			"category": "Audio",
			"name": "range_setting",
			"display_name": "Range Setting",
			"type": GlobalEnums.OptionType.RANGE,
			"default": 10.3,
			"start": 0.2,
			"stop": 15.4,
			"step": 0.01,
		},
		{
			"category": "Graphics",
			"name": "new_setting",
			"display_name": "New Setting",
			"type": GlobalEnums.OptionType.STRING,
			"default": "Hello!"
		},
		{
			"category": "Graphics",
			"name": "color_setting",
			"display_name": "Color Setting",
			"type": GlobalEnums.OptionType.COLOR,
			"default": Color.RED
		},
		{
			"category": "Animation",
			"name": "animation_enabled",
			"display_name": "Animation Enabled",
			"type": GlobalEnums.OptionType.BOOL,
			"default": true
		},
		{
			"category": "Visiblity",
			"name": "visiblity_test",
			"type": GlobalEnums.OptionType.ENUM,
			"default": GlobalEnums.VisiblityType.HIDDEN,
			"enum_values": GlobalEnums.VisiblityType.keys()
		}
	]
