extends Area2D

# Ce script est attaché à chaque zone d'élimination
func _ready():
# On écoute le signal " body_entered " :
# il se déclenche quand un personnage entre dans la zone
	body_entered . connect ( _on_body_entered )

func _on_body_entered (body):
# On vérifie que c'est bien un joueur (et pas une plateforme )
	if body. is_in_group (" players "):
# On appelle la fonction "die ()" du joueur
		body.die ()
