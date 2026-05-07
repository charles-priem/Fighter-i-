extends Control

func _ready():
	# Rendre l'écran invisible au départ
	modulate.a = 0.0 

	# Création de la séquence d'animation avec un Tween
	var tween = get_tree().create_tween() 
	
	# Fondu d'entrée sur 1 seconde
	tween.tween_property(self, "modulate:a", 1.0, 1.0) 
	
	# Attendre 2 secondes sur le logo
	tween.tween_interval(2.0) 
	
	# Fondu de sortie vers le noir
	tween.tween_property(self, "modulate:a", 0.0, 0.8) 
	
	# Aller au menu principal à la fin de l'animation
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn") 
	)

func _input(event):
	# Permet de passer le splash screen en appuyant sur n'importe quelle touche
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
