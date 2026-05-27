extends BasePlayer

@export var chat_projectile: PackedScene
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	super._ready()
	character_name  = "Justine"
	character_color = Color(0.9, 0.2, 0.6)
	move_speed = 310.0
	jump_force = 720.0
	weight     = 0.85
	max_jumps  = 2

func _physics_process(delta):
	super._physics_process(delta)
	update_animation()

func handle_attacks():
	var attack_action = "p" + str(player_number) + "_attack"
	if Input.is_action_just_pressed(attack_action):
		is_attacking = true
		await get_tree().create_timer(0.4).timeout
		if chat_projectile:
			var projectile = chat_projectile.instantiate()
			get_tree().current_scene.add_child(projectile)
			throw_projectile(projectile)
		await get_tree().create_timer(0.2).timeout
		is_attacking = false

func update_animation():
	if is_attacking:
		animated_sprite.play("attack")
	elif not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif is_dashing:
		animated_sprite.play("dash")
	elif abs(velocity.x) > 20:
		animated_sprite.play("run")
	elif taking_damage:
		animated_sprite.play("damage")
		if invincible_timer <= 0.0:
			taking_damage = false
	else:
		animated_sprite.play("idle")
