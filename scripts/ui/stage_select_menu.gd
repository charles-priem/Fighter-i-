extends Control

# Signaux envoyés au scene manager :
# - stage_selected quand une map valide est choisie
# - back_requested quand le joueur veut revenir au menu précédent
signal stage_selected(stage_scene: PackedScene, source_id: StringName, source_node: Node)
signal back_requested(source_id: StringName, source_node: Node)

# Scène utilisée pour chaque case de la grille de sélection.
const STAGE_SLOT_SCENE: PackedScene = preload("res://scenes/ui/stage_slot.tscn")

# Références vers les éléments principaux de l'interface.
@export var stage_grid: GridContainer
@export var back_button: Button
@export var total_slots: int = 6

# Empêche de déclencher plusieurs transitions en même temps.
var _is_transitioning: bool = false

# Liste des maps disponibles.
# Chaque entrée contient le nom affiché, la scène à charger et l'image de preview.
var stages: Array[Dictionary] = [
	{
		"display_name": "Map de dev",
		"scene": preload("res://scenes/stages/dev_stage.tscn"),
		"preview": preload("res://assets/art/ui/stages/dev_stage_preview.png")
	}
]

# Initialisation du menu :
# on construit la grille puis on connecte le bouton retour.
func _ready() -> void:
	_build_stage_grid()
	back_button.pressed.connect(_on_back_pressed)

# Reconstruit entièrement la grille :
# - ajoute les maps disponibles
# - complète avec des cases vides jusqu'au nombre total voulu
func _build_stage_grid() -> void:
	for child: Node in stage_grid.get_children():
		child.queue_free()

	for stage_data: Dictionary in stages:
		var slot: Node = STAGE_SLOT_SCENE.instantiate()
		stage_grid.add_child(slot)

		if slot.has_method("setup"):
			slot.setup(
				stage_data["display_name"],
				stage_data["scene"],
				stage_data["preview"]
			)

		if slot.has_signal("stage_pressed"):
			slot.connect("stage_pressed", _on_stage_pressed)

	var empty_count: int = max(total_slots - stages.size(), 0)

	for i: int in range(empty_count):
		var empty_slot: Node = STAGE_SLOT_SCENE.instantiate()
		stage_grid.add_child(empty_slot)

		if empty_slot.has_method("setup"):
			empty_slot.setup()

# Quand une map est sélectionnée on bloque les doubles clics et on prévient le scene manager.
func _on_stage_pressed(stage_scene: PackedScene) -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	stage_selected.emit(stage_scene, &"stage_select_menu", self)

# Retour au menu précédent.
func _on_back_pressed() -> void:
	if _is_transitioning:
		return

	back_requested.emit(&"stage_select_menu", self)

# Raccourci clavier/manette pour revenir en arrière avec ui_cancel.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
