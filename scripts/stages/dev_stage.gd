extends Node2D

signal exit_requested(source_id: StringName, source_node: Node)

# Retour demandé vers le menu principal quand le joueur appuie sur Echap.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		exit_requested.emit(&"dev_stage", self)
