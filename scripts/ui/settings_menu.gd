extends Control
class_name SettingsMenu

signal back_requested(source_id: StringName, source_node: Node)

const SETTINGS_PATH = "user://settings.cfg"

@export var master_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var fullscreen_check_box: CheckBox
@export var back_button: Button

var _master_bus_index: int = -1
var _music_bus_index: int = -1

func _ready() -> void:
	_master_bus_index = AudioServer.get_bus_index("Master")
	_music_bus_index = AudioServer.get_bus_index("Music")

	if _master_bus_index != -1:
		master_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_master_bus_index))

	if _music_bus_index != -1:
		music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_music_bus_index))

	fullscreen_check_box.button_pressed = (
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	)

	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	fullscreen_check_box.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_on_back_pressed)

	back_button.grab_focus()

func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume_slider.value)
	config.set_value("audio", "music_volume", music_volume_slider.value)
	config.set_value("display", "fullscreen", fullscreen_check_box.button_pressed)
	config.save(SETTINGS_PATH)

static func apply_saved_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		return

	var master_bus := AudioServer.get_bus_index("Master")
	var music_bus := AudioServer.get_bus_index("Music")

	if master_bus != -1:
		var vol: float = config.get_value("audio", "master_volume", 1.0)
		if vol <= 0.0:
			AudioServer.set_bus_mute(master_bus, true)
		else:
			AudioServer.set_bus_mute(master_bus, false)
			AudioServer.set_bus_volume_db(master_bus, linear_to_db(vol))

	if music_bus != -1:
		var vol: float = config.get_value("audio", "music_volume", 1.0)
		if vol <= 0.0:
			AudioServer.set_bus_mute(music_bus, true)
		else:
			AudioServer.set_bus_mute(music_bus, false)
			AudioServer.set_bus_volume_db(music_bus, linear_to_db(vol))

	if config.get_value("display", "fullscreen", false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_master_volume_changed(value: float) -> void:
	if _master_bus_index == -1:
		return
	if value <= 0.0:
		AudioServer.set_bus_mute(_master_bus_index, true)
	else:
		AudioServer.set_bus_mute(_master_bus_index, false)
		AudioServer.set_bus_volume_db(_master_bus_index, linear_to_db(value))
	_save_settings()

func _on_music_volume_changed(value: float) -> void:
	if _music_bus_index == -1:
		return
	if value <= 0.0:
		AudioServer.set_bus_mute(_music_bus_index, true)
	else:
		AudioServer.set_bus_mute(_music_bus_index, false)
		AudioServer.set_bus_volume_db(_music_bus_index, linear_to_db(value))
	_save_settings()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_save_settings()

func _on_back_pressed() -> void:
	back_requested.emit(&"settings_menu", self)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
