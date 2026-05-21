extends Node2D

signal exit_requested(source_id: StringName, source_node: Node)

@export var p1_spawn: Marker2D
@export var p2_spawn: Marker2D
@export var hud: Control

func _ready() -> void:
	if p1_spawn == null or p2_spawn == null:
		push_error("Les points de spawn P1/P2 ne sont pas assignés dans dev_stage.gd")
		return

	var p1_scene: PackedScene = load(GameData.p1_scene)
	var p2_scene: PackedScene = load(GameData.p2_scene)

	var p1: Node2D = p1_scene.instantiate()
	var p2: Node2D = p2_scene.instantiate()
	
	if p1.has_method("set_hud"):
		p1.set_hud(hud)
	if p2.has_method("set_hud"):
		p2.set_hud(hud)

	p1.player_number = 1
	p2.player_number = 2

	add_child(p1)
	add_child(p2)

	p1.global_position = p1_spawn.global_position
	p2.global_position = p2_spawn.global_position

	p1.spawn_point = p1.global_position
	p2.spawn_point = p2.global_position

# Retour demandé vers le menu principal quand le joueur appuie sur Echap.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		exit_requested.emit(&"dev_stage", self)
