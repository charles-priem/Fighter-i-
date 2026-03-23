extends CharacterBody2D
class_name BasePlayer

# STATS (modifiables par chaque prof)
@export var character_name : String = "Inconnu"
@export var character_color: Color  = Color.WHITE
@export var move_speed  : float = 300.0
@export var jump_force  : float = 700.0
@export var weight      : float = 1.0
@export var max_jumps   : int   = 2

# VARIABLES INTERNES 
var gravity          = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_remaining  : int   = 2
var damage_percent   : float = 0.0
var stocks           : int   = 3
var is_attacking     : bool  = false
var invincible_timer : float = 0.0
var facing_right     : bool  = true

@export var player_number: int = 1

@onready var sprite = $Sprite2D2

# READY 
func _ready():
	add_to_group("players")
	sprite.modulate = character_color

# BOUCLE PHYSIQUE 
func _physics_process(delta):
	if invincible_timer > 0:
		invincible_timer -= delta

	if not is_on_floor():
		velocity.y += gravity * delta

	handle_jump()
	handle_movement()

	if not is_attacking:
		handle_attacks()

	move_and_slide()

	if is_on_floor():
		jumps_remaining = max_jumps

# SAUT
func handle_jump():
	var action = "p" + str(player_number) + "_jump"
	if Input.is_action_just_pressed(action) and jumps_remaining > 0:
		velocity.y = -jump_force
		jumps_remaining -= 1

# MOUVEMENT 
func handle_movement():
	var dir = Input.get_axis(
		"p" + str(player_number) + "_left",
		"p" + str(player_number) + "_right"
	)
	if dir != 0:
		velocity.x = dir * move_speed
		facing_right = dir > 0
		sprite.flip_h = not facing_right
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

# ATTAQUES : vide, chaque prof le remplace 
func handle_attacks():
	pass

# RECEVOIR UN COUP 
func take_hit(dmg: float, kb_x: float, kb_y: float,
			  attacker_right: bool):
	if invincible_timer > 0:
		return
	damage_percent += dmg
	var mult = (1.0 + damage_percent / 100.0) / weight
	var vx = kb_x * mult
	var vy = kb_y * mult
	if not attacker_right:
		vx = -vx
	velocity = Vector2(vx, vy)
	invincible_timer = 0.5
	update_hud()

# MORT
func die():
	stocks -= 1
	damage_percent   = 0.0
	position         = Vector2(500, 100)
	velocity         = Vector2.ZERO
	invincible_timer = 2.0
	if stocks <= 0:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

# HUD 
func update_hud():
	var hud = get_tree().root.get_node_or_null("GameScene/HUD/Control")
	if hud:
		hud.update_percent(player_number, damage_percent)

# UTILITAIRE : lancer une attaque proprement 
func do_attack(hitbox_name: String, startup: float,
			   active: float, recovery: float):
	is_attacking = true
	await get_tree().create_timer(startup).timeout
	get_node(hitbox_name).monitoring = true
	await get_tree().create_timer(active).timeout
	get_node(hitbox_name).monitoring = false
	await get_tree().create_timer(recovery).timeout
	is_attacking = false
