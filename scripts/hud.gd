extends Control

# --- REFERENCES AUX NOEUDS ---
@onready var p1_percent = $P1Panel/VBoxContainer/P1Percent
@onready var p2_percent = $P2Panel/VBoxContainer/P2Percent

@onready var p1_stocks = $P1Panel/VBoxContainer/P1Stocks
@onready var p2_stocks = $P2Panel/VBoxContainer/P2Stocks

# --- COULEURS DE DEGATS ---
const COLOR_SAFE   = Color(1.0, 1.0, 1.0) # Blanc (0-49%)
const COLOR_WARN   = Color(1.0, 0.9, 0.2) # Jaune (50-99%)
const COLOR_DANGER = Color(1.0, 0.5, 0.1) # Orange (100-149%)
const COLOR_CRIT   = Color(1.0, 0.15, 0.15) # Rouge (150%+)

func _ready():
	# On initialise l'affichage des vies au départ (3 par défaut)
	update_stocks(1, 3)
	update_stocks(2, 3)
	
	# Affichage de base au lancement
	update_percent(1, 0.0)
	update_percent(2, 0.0)

# --- MISE A JOUR DU POURCENTAGE ---
func update_percent(player_num: int, percent: float):
	var label = p1_percent if player_num == 1 else p2_percent
	
	# 1. Mettre à jour le texte
	label.text = str(int(percent)) + "%"
	
	# 2. Changer la couleur selon le danger
	if percent < 50:
		label.add_theme_color_override("font_color", COLOR_SAFE)
	elif percent < 100:
		label.add_theme_color_override("font_color", COLOR_WARN)
	elif percent < 150:
		label.add_theme_color_override("font_color", COLOR_DANGER)
	else:
		label.add_theme_color_override("font_color", COLOR_CRIT)
		
	# 3. Petit effet de "Pop" quand on prend un coup
	var tween = get_tree().create_tween()
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2)
	
# --- MISE A JOUR DES VIES ---
func update_stocks(player_num: int, stocks_remaining: int):
	var stock_container = p1_stocks if player_num == 1 else p2_stocks
	
	# On vide les anciennes icônes
	for child in stock_container.get_children():
		child.queue_free()
		
	# On ajoute autant d'icônes qu'il reste de vies
	for i in range(stocks_remaining):
		var icon = TextureRect.new()
		# Remplace par le chemin de ton icône de vie (ex: tête du prof)
		icon.texture = load("res://icon.svg") 
		icon.custom_minimum_size = Vector2(20, 20)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stock_container.add_child(icon)
