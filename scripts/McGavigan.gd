extends BasePlayer

func _ready():
	super._ready()
	character_name  = "McGavigan"
	character_color = Color(0.9, 0.5, 0.1)
	move_speed = 320.0
	jump_force = 700.0
	weight     = 0.9
	max_jumps  = 2
