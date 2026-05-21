extends BasePlayer

@onready var animated_sprite = $AnimatedSprite2D
@onready var adversaire: CharacterBody2D = $"../Morelle"

var direction = Vector2.RIGHT

func _ready():
	super._ready()
	character_name  = "Scottez"
	character_color = Color(1.0, 1.0, 1.0) 
	move_speed = 320.0
	jump_force = 700.0
	weight     = 0.9
	max_jumps  = 2

func _physics_process(delta):
	super._physics_process(delta)
	update_animation()

func handle_attacks():
	var attack_action = "p" + str(player_number) + "_attack"
	if Input.is_action_just_pressed(attack_action) :
		is_attacking = true
		var new_gravity = 980 - (adversaire.damage_percent * 13)
		adversaire.gravity = new_gravity
		await get_tree().create_timer(2).timeout
		adversaire.gravity = 980
		var directionRight = true if direction.x > 0 else false
		adversaire.take_hit(10,5,5,directionRight, false)
		is_attacking = false
		

func update_animation():
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif abs(velocity.x) > 20:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
