extends Control

const GAME_SCENE: String = "res://scenes/game_scene.tscn"
const SETTINGS_SCENE: String = "res://scenes/ui/settings_menu.tscn"

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var p1_score_label: Label = $PlayerScores/Player1Score
@onready var p2_score_label: Label = $PlayerScores/Player2Score

var _is_transitioning: bool = false

func _ready() -> void:
	# Initialisation de l'affichage des scores depuis l'Autoload GameData
	p1_score_label.text = "- Joueur 1 : " + str(GameData.p1_wins)
	p2_score_label.text = "- Joueur 2 : " + str(GameData.p2_wins)

	# Connexion des signaux
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Gestion du focus pour la navigation au clavier/manette
	play_button.grab_focus()

	# Animation d'entrée fluide
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _on_play_pressed() -> void:
	# Transition vers l'écran de sélection de personnage
	_change_scene_with_fade(GAME_SCENE)

func _on_settings_pressed() -> void:
	# Transition vers le menu des paramètres
	_change_scene_with_fade(SETTINGS_SCENE)

func _on_quit_pressed() -> void:
	# Quitter le jeu proprement
	get_tree().quit()

func _change_scene_with_fade(target_scene: String) -> void:
	if _is_transitioning:
		return

	_is_transitioning = true

	# Petit effet de fondu avant de changer de scène
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func() -> void:
		get_tree().change_scene_to_file(target_scene)
	)

func _unhandled_input(event: InputEvent) -> void:
	# Raccourci pour quitter avec la touche Echap
	if event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()
