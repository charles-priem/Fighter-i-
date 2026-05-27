extends Control

# Signaux envoyés au scene manager :
signal characters_selected(source_id: StringName, source_node: Node)
signal back_requested(source_id: StringName, source_node: Node)

const CHARACTER_SLOT_SCENE: PackedScene = preload("res://scenes/ui/character_slot.tscn")

@export var character_grid: GridContainer
@export var next_button: Button
@export var back_button: Button
@export var p1_status_label: Label
@export var p2_status_label: Label
@export var total_slots: int = 15

@onready var voice_player : AudioStreamPlayer = $VoicePlayer

var _is_transitioning: bool = false
var _current_selecting_player: int = 1

var _p1_selected_slot: Node = null
var _p2_selected_slot: Node = null

var characters: Array[Dictionary] = [
	{
		"display_name": "Dubois",
		"scene": preload("res://scenes/Dubois.tscn"),
		"preview": preload("res://assets/sprites/Personnages/Dubois/dubois marche 1.png")
	},
	{
		"display_name": "Mcgavigan",
		"scene": preload("res://scenes/Mcgavigan.tscn"),
		"preview": preload("res://assets/sprites/Personnages/Mcgavigan/Mcgavigan idle 1.png")
	},
	{
		"display_name": "Mele",
		"scene": preload("res://scenes/Mele.tscn"),
		"preview": preload("res://assets/sprites/Personnages/Mele/Mele_idle1.png")
	},
	{
		"display_name": "Blandre",
		"scene": preload("res://scenes/Blandre.tscn"),
		"preview": preload("res://assets/sprites/Personnages/Blandre/blandre_idle1.png")
	},
	{
		"display_name": "Benedito",
		"scene": preload("res://scenes/Benedito.tscn"),
		"preview": preload("res://assets/sprites/Personnages/Benedito/Benedito fixe 1.png")
	},
	{
		"display_name": "Deleplanque",
		"scene": preload("res://scenes/Deleplanque.tscn"),
		"preview": preload("res://assets/sprites/Personnages/Deleplanque/Samuel_idle1.png")
	},
	{
		"display_name": "Scottez",
		"scene": preload("res://scenes/Scottez.tscn"	),
		"preview": preload("res://assets/sprites/Personnages/Scottez/Scottez fixe 1.png")
	},
	{
		"display_name": "Philippe",
		"scene": preload("res://scenes/Philippe.tscn"),
		"preview": preload("res://assets/sprites/Personnages/Philippe/Justine_idle1.png")
	},
	{
		"display_name": "El Yaagoubi",
		"scene": preload("res://scenes/ElYaagoubi.tscn"),
		"preview": preload("res://assets/sprites/Personnages/El Yaagoubi/el_yaagoubi_idle1.png")
	},
	{
		"display_name": "Morelle",
		"scene": preload("res://scenes/Morelle.tscn"),
		"preview": preload("res://assets/sprites/Personnages/Morelle/morelle_idle1.webp")
	},
	{
		"display_name": "Veillon",
		"scene": preload("res://scenes/Veillon.tscn"),
		"preview": preload("res://assets/sprites/Personnages/Veillon/lmv_idle1.png")
	},
	{
		"display_name": "N Kounou",
		"scene": preload("res://scenes/NKonou.tscn"),
		"preview": preload("res://assets/sprites/Personnages/N Kounou/nkounou_idle 2.webp")
	},
	{
		"display_name": "Fardoux",
		"scene": preload("res://scenes/Fardoux.tscn"),
		"preview": preload("res://assets/sprites/Personnages/Fardoux/fardoux fixe 1.png")
	}
]

func _ready() -> void:
	_build_character_grid()
	
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
		next_button.disabled = true # Disabled until both characters are selected
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		
	_update_ui()

func _update_ui() -> void:
	if p1_status_label:
		if _p1_selected_slot:
			p1_status_label.text = "J1 : " + _p1_selected_slot.name_label.text
		else:
			p1_status_label.text = "J1 : En attente..."
			
	if p2_status_label:
		if _p2_selected_slot:
			p2_status_label.text = "J2 : " + _p2_selected_slot.name_label.text
		else:
			p2_status_label.text = "J2 : En attente..."
			
	if next_button:
		next_button.disabled = _p1_selected_slot == null or _p2_selected_slot == null

func _build_character_grid() -> void:
	if character_grid == null:
		return
		
	for child: Node in character_grid.get_children():
		child.queue_free()

	for i in range(characters.size()):
		var char_data: Dictionary = characters[i]
		var slot: Node = CHARACTER_SLOT_SCENE.instantiate()
		character_grid.add_child(slot)

		if slot.has_method("setup"):
			slot.setup(
				char_data["display_name"],
				char_data["scene"],
				char_data["preview"]
			)

		if slot.has_signal("character_pressed"):
			slot.connect("character_pressed", _on_character_pressed)

	var empty_count: int = max(total_slots - characters.size(), 0)
	for i: int in range(empty_count):
		var empty_slot: Node = CHARACTER_SLOT_SCENE.instantiate()
		character_grid.add_child(empty_slot)
		if empty_slot.has_method("setup"):
			empty_slot.setup()

func _update_slots_visuals() -> void:
	for slot in character_grid.get_children():
		if not slot.has_method("set_selected"):
			continue
			
		if slot == _p1_selected_slot and slot == _p2_selected_slot:
			slot.set_selected(3)
		elif slot == _p1_selected_slot:
			slot.set_selected(1)
		elif slot == _p2_selected_slot:
			slot.set_selected(2)
		else:
			slot.set_selected(0)

func _on_character_pressed(slot: Node, _character_scene: PackedScene) -> void:
	# Jouer la voiceline de sélection
	if _character_scene:
		var temp_char = _character_scene.instantiate()
		if "voice_select" in temp_char and temp_char.voice_select:
			if voice_player:
				voice_player.stream = temp_char.voice_select
				voice_player.play()
		temp_char.queue_free()

	if _current_selecting_player == 1:
		_p1_selected_slot = slot
		# Trouver l'index dans GameData si possible, ou juste passer la scène au GameData plus tard
		_current_selecting_player = 2
	elif _current_selecting_player == 2:
		_p2_selected_slot = slot
		# Optionnellement permettre de recommencer
		_current_selecting_player = 1
		
	_update_slots_visuals()
	_update_ui()

func _on_next_pressed() -> void:
	if _is_transitioning or _p1_selected_slot == null or _p2_selected_slot == null:
		return
	_is_transitioning = true
	
	# Mise à jour globale dans GameData
	var p1_path = _p1_selected_slot._character_scene.resource_path
	var p2_path = _p2_selected_slot._character_scene.resource_path
	
	# On cherche l'index correspondant dans GameData
	var p1_idx = GameData.CHARACTER_SCENES.find(p1_path)
	if p1_idx != -1:
		GameData.p1_character_index = p1_idx
		
	var p2_idx = GameData.CHARACTER_SCENES.find(p2_path)
	if p2_idx != -1:
		GameData.p2_character_index = p2_idx
	
	characters_selected.emit(&"character_select_menu", self)

func _on_back_pressed() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	back_requested.emit(&"character_select_menu", self)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
