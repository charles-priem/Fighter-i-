extends BasePlayer

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	super._ready()
	character_name  = "ElYaagoubi"
	character_color = Color(1.0, 1.0, 1.0) 
	move_speed = 320.0
	jump_force = 700.0
	weight     = 0.9
	max_jumps  = 2

func _physics_process(delta):
	super._physics_process(delta)
	update_animation()

func update_animation():
#	if not is_on_floor():
#		if velocity.y < 0:
#			animated_sprite.play("jump")
#		else:
#			animated_sprite.play("fall")
	if abs(velocity.x) > 20:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
