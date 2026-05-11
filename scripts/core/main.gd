extends Node

const SPLASH_SCREEN_SCENE: PackedScene = preload("res://scenes/ui/splash_screen.tscn")
const MAIN_MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const SETTINGS_MENU_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game_scene.tscn")

@onready var stage: Node = $Stage
@onready var screens: CanvasLayer = $Screens

var current_screen: Node = null
var current_stage: Node = null

func _ready() -> void:
	show_splash_screen()

func clear_screen() -> void:
	if current_screen != null:
		current_screen.queue_free()
		current_screen = null

func clear_stage() -> void:
	if current_stage != null:
		current_stage.queue_free()
		current_stage = null

func show_screen(scene_resource: PackedScene) -> Node:
	clear_screen()

	current_screen = scene_resource.instantiate()
	screens.add_child(current_screen)

	return current_screen

func show_stage(scene_resource: PackedScene) -> Node:
	clear_stage()

	current_stage = scene_resource.instantiate()
	stage.add_child(current_stage)

	return current_stage

func show_splash_screen() -> void:
	var splash_screen: Node = show_screen(SPLASH_SCREEN_SCENE)

	if splash_screen.has_signal("finished"):
		splash_screen.finished.connect(_on_splash_finished)

func show_main_menu() -> void:
	var main_menu: Node = show_screen(MAIN_MENU_SCENE)

	if main_menu.has_signal("play_requested"):
		main_menu.play_requested.connect(_on_play_requested)

	if main_menu.has_signal("settings_requested"):
		main_menu.settings_requested.connect(_on_settings_requested)

	if main_menu.has_signal("quit_requested"):
		main_menu.quit_requested.connect(_on_quit_requested)

func show_settings_menu() -> void:
	var settings_menu: Node = show_screen(SETTINGS_MENU_SCENE)

	if settings_menu.has_signal("back_requested"):
		settings_menu.back_requested.connect(_on_settings_back_requested)

func start_game() -> void:
	clear_screen()
	show_stage(GAME_SCENE)

func _on_splash_finished() -> void:
	show_main_menu()

func _on_play_requested() -> void:
	start_game()

func _on_settings_requested() -> void:
	show_settings_menu()

func _on_settings_back_requested() -> void:
	show_main_menu()

func _on_quit_requested() -> void:
	get_tree().quit()
