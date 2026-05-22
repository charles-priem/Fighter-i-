extends Node

# --- CONFIGURATION DES PERSONNAGES ---
# [cite: 60, 80, 89, 113]

const CHARACTER_SCENES = [
	"res://scenes/ElYaagoubi.tscn",
	"res://scenes/Dubois.tscn",
	"res://scenes/Benedito.tscn",
	"res://scenes/Fardoux.tscn",
	"res://scenes/Benyoussef.tscn",
	"res://scenes/Blandre.tscn",
	"res://scenes/Deleplanque.tscn",
	"res://scenes/McGavigan.tscn",
	"res://scenes/Benedito.tscn"
]

const CHARACTER_NAMES = [
	"ElYaagoubi",
	"Dubois",
	"Benedito",
	"Fardoux",
	"Benyoussef",
	"Blandre",
	"Deleplanque",
	"McGavigan",
	"Prof 8"
]

const CHARACTER_DESC = [
	"Rapide et imprévisible",
	"Puissant et solide",
	"Aérien et agile",
	"",
	"Contrôleur de zone",
	"Attaques longue portée",
	"Vitesse maximale",
	"Illusions et clones",
	"Défenseur implacable"
]

const CHARACTER_COLORS = [
	Color(0.9, 0.3, 0.1),
	Color(0.2, 0.8, 0.3),
	Color(0.1, 0.5, 0.9),
	Color(0.8, 0.8, 0.8),
	Color(0.9, 0.8, 0.1),
	Color(0.7, 0.2, 0.9),
	Color(0.1, 0.9, 0.8),
	Color(0.9, 0.3, 0.1),
	Color(0.4, 0.4, 0.4)
]

# --- CHOIX DES JOUEURS ---
# [cite: 130, 132, 139, 141]

var p1_character_index: int = 0
var p2_character_index: int = 1

var p1_scene: String:
	get: return CHARACTER_SCENES[p1_character_index]

var p2_scene: String:
	get: return CHARACTER_SCENES[p2_character_index]

# --- RÉSULTATS ET STATISTIQUES ---
# [cite: 146, 148, 150]

var last_winner: int = 0
var p1_wins: int = 0
var p2_wins: int = 0

# --- PARAMÈTRES ---
# [cite: 156, 159]

var game_mode: String = "vs"
var stock_count: int = 3

# --- FONCTIONS UTILITAIRES (NOMS MODIFIÉS POUR ÉVITER LES CONFLITS) ---
# [cite: 164, 172, 174, 179]

# Changé de get_name() à get_character_name() pour éviter l'erreur native de Godot
func get_character_name(index: int) -> String:
	return CHARACTER_NAMES[index]

func get_character_color(index: int) -> Color:
	return CHARACTER_COLORS[index]

func get_character_desc(index: int) -> String:
	return CHARACTER_DESC[index]

func reset_match():
	last_winner = 0
