extends Control

signal back_requested(source_id: StringName, source_node: Node)

@export var master_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var fullscreen_check_box: CheckBox
@export var back_button: Button

var _master_bus_index: int = -1
var _music_bus_index: int = -1

# Initialisation du menu de paramètres :
# on récupère les bus audio, on synchronise l'état des contrôles avec les réglages actuels,
# puis on connecte les signaux de l'interface.
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

# Gestion de l'audio :
# les sliders sont supposés avoir une plage de 0.0 à 1.0.
# On convertit la valeur linéaire en décibels avant de l'envoyer à l'AudioServer.
func _on_master_volume_changed(value: float) -> void:
	if _master_bus_index == -1:
		return

	if value <= 0.0:
		AudioServer.set_bus_mute(_master_bus_index, true)
	else:
		AudioServer.set_bus_mute(_master_bus_index, false)
		AudioServer.set_bus_volume_db(_master_bus_index, linear_to_db(value))

func _on_music_volume_changed(value: float) -> void:
	if _music_bus_index == -1:
		return

	if value <= 0.0:
		AudioServer.set_bus_mute(_music_bus_index, true)
	else:
		AudioServer.set_bus_mute(_music_bus_index, false)
		AudioServer.set_bus_volume_db(_music_bus_index, linear_to_db(value))

# Gestion de l'affichage :
# on applique simplement le mode fenêtre ou plein écran selon l'état de la case.
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_pressed() -> void:
	back_requested.emit(&"settings_menu", self)
