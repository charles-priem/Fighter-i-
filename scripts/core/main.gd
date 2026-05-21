extends Node

const SPLASH_SCREEN_SCENE: PackedScene = preload("res://scenes/ui/splash_screen.tscn")
const MAIN_MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const SETTINGS_MENU_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")
const STAGE_SELECT_MENU_SCENE: PackedScene = preload("res://scenes/ui/stage_select_menu.tscn")
const CHARACTER_SELECT_MENU_SCENE: PackedScene = preload("res://scenes/ui/character_select_menu.tscn")

@onready var stage: Node = $Stage
@onready var screens: CanvasLayer = $Screens

var current_screen: Node = null
var current_stage: Node = null
var selected_stage_scene: PackedScene = null

# Point d'entrée du jeu :
# on démarre par le splash screen puis tout le reste sera piloté par le scene manager.
func _ready() -> void:
	_show_splash_screen()

# Remplace proprement l'enfant courant d'un conteneur par une nouvelle scène instanciée.
# Cette fonction est utilisée aussi bien pour les écrans UI que pour la scène de stage.
func _replace_child(container: Node, current_child: Node, scene_resource: PackedScene) -> Node:
	if current_child != null:
		current_child.queue_free()

	var new_child: Node = scene_resource.instantiate()
	container.add_child(new_child)
	return new_child

# Connecte un signal seulement s'il existe sur la scène instanciée.
# Cela évite une erreur pendant le prototypage si une scène n'a pas encore tous ses signaux.
func _connect_if_exists(node: Node, signal_name: StringName, callback: Callable) -> void:
	if node.has_signal(signal_name):
		node.connect(signal_name, callback)

# Gestion centralisée de l'affichage :
# Screens contient les menus et overlays, Stage contient la scène de jeu.
func _show_screen(scene_resource: PackedScene) -> Node:
	current_screen = _replace_child(screens, current_screen, scene_resource)
	return current_screen

func _show_stage(scene_resource: PackedScene) -> Node:
	current_stage = _replace_child(stage, current_stage, scene_resource)
	_connect_if_exists(current_stage, &"exit_requested", _on_stage_exit_requested)
	_connect_if_exists(current_stage, &"match_finished", _on_match_finished)
	return current_stage

# Affichage des différentes scènes UI.
# Chaque scène émet des signaux et Main décide de la suite du flux.
func _show_splash_screen() -> void:
	var splash_screen: Node = _show_screen(SPLASH_SCREEN_SCENE)
	_connect_if_exists(splash_screen, &"finished", _on_splash_finished)

func _show_main_menu() -> void:
	var main_menu: Node = _show_screen(MAIN_MENU_SCENE)
	_connect_if_exists(main_menu, &"play_requested", _on_play_requested)
	_connect_if_exists(main_menu, &"settings_requested", _on_settings_requested)
	_connect_if_exists(main_menu, &"quit_requested", _on_quit_requested)

func _show_settings_menu() -> void:
	var settings_menu: Node = _show_screen(SETTINGS_MENU_SCENE)
	_connect_if_exists(settings_menu, &"back_requested", _on_settings_back_requested)

func _show_stage_select_menu() -> void:
	var stage_select_menu: Node = _show_screen(STAGE_SELECT_MENU_SCENE)
	_connect_if_exists(stage_select_menu, &"stage_selected", _on_stage_selected)
	_connect_if_exists(stage_select_menu, &"back_requested", _on_stage_select_back_requested)

func _show_character_select_menu() -> void:
	var character_select_menu: Node = _show_screen(CHARACTER_SELECT_MENU_SCENE)
	_connect_if_exists(character_select_menu, &"characters_selected", _on_characters_selected)
	_connect_if_exists(character_select_menu, &"back_requested", _on_character_select_back_requested)

# Lance la scène de stage choisie et retire l'écran actif.
func _start_game() -> void:
	if selected_stage_scene == null:
		return

	if current_screen != null:
		current_screen.queue_free()
		current_screen = null

	_show_stage(selected_stage_scene)

# Retour depuis une scène de jeu :
# on supprime la scène courante puis on réaffiche le menu principal.
func _return_to_main_menu_from_game() -> void:
	if current_stage != null:
		current_stage.queue_free()
		current_stage = null

	_show_main_menu()

# Réception des signaux :
func _on_splash_finished(_source_id: StringName = &"", _source_node: Node = null) -> void:
	call_deferred("_show_main_menu")

func _on_play_requested(_source_id: StringName = &"", _source_node: Node = null) -> void:
	call_deferred("_show_character_select_menu")

func _on_characters_selected(_source_id: StringName = &"", _source_node: Node = null) -> void:
	call_deferred("_show_stage_select_menu")

func _on_character_select_back_requested(_source_id: StringName = &"", _source_node: Node = null) -> void:
	call_deferred("_show_main_menu")

func _on_match_finished(_winner_player: int, _source_id: StringName = &"", _source_node: Node = null) -> void:
	call_deferred("_return_to_main_menu_from_game")

func _on_settings_requested(_source_id: StringName = &"", _source_node: Node = null) -> void:
	call_deferred("_show_settings_menu")

func _on_settings_back_requested(_source_id: StringName = &"", _source_node: Node = null) -> void:
	call_deferred("_show_main_menu")

func _on_stage_select_back_requested(_source_id: StringName = &"", _source_node: Node = null) -> void:
	call_deferred("_show_main_menu")

func _on_stage_selected(stage_scene: PackedScene, _source_id: StringName = &"", _source_node: Node = null) -> void:
	selected_stage_scene = stage_scene
	call_deferred("_start_game")

func _on_stage_exit_requested(_source_id: StringName = &"", _source_node: Node = null) -> void:
	call_deferred("_return_to_main_menu_from_game")

func _on_quit_requested(_source_id: StringName = &"", _source_node: Node = null) -> void:
	get_tree().quit()
