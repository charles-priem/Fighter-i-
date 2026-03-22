extends Control

@onready var p1_percent = $P1Percent
@onready var p2_percent = $P2Percent

func update_percent(player_num: int, percent: float):
	# Arrondir le pourcentage et l'afficher
	var text = str(int(percent)) + "%"
	
	if player_num == 1:
		p1_percent.text = text
	else:
		p2_percent.text = text
	
	# Changer la couleur selon le danger
	var label = p1_percent if player_num == 1 else p2_percent
	if percent < 50:
		label.modulate = Color.WHITE
	elif percent < 100:
		label.modulate = Color.YELLOW
	elif percent < 150:
		label.modulate = Color.ORANGE
	else:
		label.modulate = Color.RED
