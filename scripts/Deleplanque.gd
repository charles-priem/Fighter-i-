extends BasePlayer

@onready var animated_sprite = $AnimatedSprite2D
@export var sac_projectile: PackedScene

func _ready():
	super._ready()
	character_name  = "Deleplanque"
	character_color = Color(0.9, 0.5, 0.1)
	move_speed = 320.0
	jump_force = 700.0
	weight     = 0.9
	max_jumps  = 2

func _physics_process(delta):
	super._physics_process(delta)
	update_animation()

func handle_attacks():
	var attack_action = "p" + str(player_number) + "_attack"
	if Input.is_action_just_pressed(attack_action):
		is_attacking = true
		await get_tree().create_timer(0.4).timeout
		if sac_projectile:
			var projectile = sac_projectile.instantiate()
			get_tree().current_scene.add_child(projectile)
			throw_projectile(projectile)
		await get_tree().create_timer(0.2).timeout
		is_attacking = false

func update_animation():
	if is_attacking:
		if animated_sprite.animation == &"melee":
			animated_sprite.flip_h = facing_left
			return
		if animated_sprite.animation != &"attack":
			animated_sprite.play("attack")
			animated_sprite.flip_h = not facing_left
		return
	
	animated_sprite.flip_h = not facing_left
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif is_grabbing_ledge:
		animated_sprite.play("climb")
	elif is_dashing:
		animated_sprite.play("dash")
	elif abs(velocity.x) > 20:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
