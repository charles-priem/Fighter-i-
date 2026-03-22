extends Camera2D

func _ready():
	# La caméra se centre automatiquement sur les joueurs
	zoom = Vector2(0.6, 0.6)  # Dézoom pour voir plus large

func _process(_delta):
	# Trouver tous les joueurs
	var players = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return
	
	# Calculer le centre entre tous les joueurs
	var center = Vector2.ZERO
	for player in players:
		center += player.global_position
	center /= players.size()
	
	# Déplacer la caméra vers ce centre
	global_position = center
