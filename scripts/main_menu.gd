extends Control

# Déclaration des chemins vers les nœuds 
@onready var play_button = $VBoxContainer/PlayButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var p1_score_label = $ScoresPanel/P1Wins
@onready var p2_score_label = $ScoresPanel/P2Wins

func _ready():
	# Initialisation de l'affichage des scores depuis l'Autoload GameData
	p1_score_label.text = "P1 Victoires: " + str(GameData.p1_wins)
	p2_score_label.text = "P2 Victoires: " + str(GameData.p2_wins)
	
	# Connexion des signaux
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Gestion du focus pour la navigation au clavier/manette
	play_button.grab_focus()
	
	# Animation d'entrée fluide
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _on_play_pressed():
	# Transition vers l'écran de sélection de personnage
	_change_scene_with_fade("res://scenes/game_scene.tscn")

func _on_options_pressed():
	# Transition vers le menu des options
	_change_scene_with_fade("res://scenes/options.tscn")

func _on_quit_pressed():
	# Quitter le jeu proprement
	get_tree().quit()

func _change_scene_with_fade(target_scene: String):
	# Petit effet de fondu avant de changer de scène
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func(): 
		get_tree().change_scene_to_file(target_scene)
	)

func _input(event):
	# Raccourci pour quitter avec la touche Echap
	if event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()
