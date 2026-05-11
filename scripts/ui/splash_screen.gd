extends Control

const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Empêche un double changement de scène si plusieurs entrées arrivent en même temps
var _is_transitioning: bool = false

func _ready() -> void:
	# Ignore la souris pour ne pas bloquer l'input et lance l'animation du splash
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	animation_player.play("splash")

func _input(event: InputEvent) -> void:
	# Si la transition a déjà commencé, on ignore les autres entrées
	if _is_transitioning:
		return

	# Permet de skip avec clavier, souris ou manette
	if event is InputEventKey and event.pressed and not event.echo:
		_go_to_main_menu()
	elif event is InputEventMouseButton and event.pressed:
		_go_to_main_menu()
	elif event is InputEventJoypadButton and event.pressed:
		_go_to_main_menu()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# À la fin de l'animation du splash, on va au menu principal
	if anim_name == "splash":
		_go_to_main_menu()

func _go_to_main_menu() -> void:
	# Double sécurité pour empêcher un second changement de scène
	if _is_transitioning:
		return

	_is_transitioning = true
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
