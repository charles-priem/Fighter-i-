extends CharacterBody2D
class_name BasePlayer

# STATS 
@export var character_name  : String = "Inconnu"
@export var character_color : Color  = Color.WHITE
@export var move_speed      : float  = 300.0
@export var jump_force      : float  = 700.0
@export var weight          : float  = 1.0
@export var max_jumps       : int    = 2
@export var max_stocks      : int    = 3
@export var player_number   : int    = 1
@export var dash_speed      : float = 800.0
@export var dash_duration   : float = 0.2

# VARIABLES INTERNES 
var gravity          = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_remaining  : int   = 2
var damage_percent   : float = 0.0
var stocks           : int   = 3
var is_attacking     : bool  = false
var invincible_timer : float = 0.0
var facing_right     : bool  = true


# Dash
var is_dashing       : bool  = false
var can_air_dash     : bool  = true
var dash_timer       : float = 0.0
var dash_dir         : Vector2 = Vector2.ZERO

# VARIABLES LEDGE GRAB
var is_grabbing_ledge : bool  = false
var ledge_timer       : float = 0.0
const LEDGE_HOLD_TIME : float = 1.0  # secondes max accrochage

@onready var ledge_detector = $LedgeDetector

# CONSTANTES 
const DASH_SPEED     : float = 1000.0
const DASH_DURATION  : float = 0.15
const FAST_FALL_MULT : float = 2.5

# SIGNAUX
signal stock_lost(player_num, stocks_remaining)
signal player_eliminated(player_num)

# REFERENCES
@onready var sprite = $AnimatedSprite2D

# READY 
func _ready():
	add_to_group("players")
	velocity = Vector2.ZERO
	sprite.sprite_frames = sprite.sprite_frames.duplicate()
	ledge_detector.body_entered.connect(_on_ledge_detected)
	ledge_detector.body_exited.connect(_on_ledge_exited)
# BOUCLE PHYSIQUE 
func _physics_process(delta):
	# Gestion des timers
	if invincible_timer > 0: invincible_timer -= delta
	
	# 1. LOGIQUE DE LEDGE
	if is_grabbing_ledge:
		handle_ledge_hang(delta)
		move_and_slide()
		return

	# 2. LOGIQUE DE DASH (Prioritaire sur tout)
	if is_dashing:
		dash_timer -= delta
		velocity = dash_dir * dash_speed
		if dash_timer <= 0:
			is_dashing = false
			velocity = velocity * 0.5 # On garde un peu d'élan en sortie
		move_and_slide()
		return

	# 3. PHYSIQUE NORMALE (En dehors du dash)
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps_remaining = max_jumps
		can_air_dash = true # Reset au sol

	handle_jump()
	handle_movement()
	handle_dash_input() # La nouvelle fonction
	handle_fast_fall()

	if not is_attacking:
		handle_attacks()

	move_and_slide()
# CLIGNOTEMENT 
func _process(_delta):
	if invincible_timer > 0:
		var blink = sin(Time.get_ticks_msec() * 0.025) > 0
		sprite.visible = blink
	else:
		sprite.visible = true

# SAUT 
func handle_jump():
	var action = "p" + str(player_number) + "_jump"
	if Input.is_action_just_pressed(action) and jumps_remaining > 0:
		velocity.y = -jump_force
		jumps_remaining -= 1

# MOUVEMENT 
func handle_movement():
	if is_dashing:
		return
		
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

# DASH_input 
func handle_dash_input():
	var dash_action = "p" + str(player_number) + "_smash"
	
	if Input.is_action_just_pressed(dash_action):
		if is_on_floor() or can_air_dash:
			# On récupère la direction (Haut, Bas, Gauche, Droite ou Diagonales)
			var input_dir = Vector2(
				Input.get_axis("p" + str(player_number) + "_left", "p" + str(player_number) + "_right"),
				Input.get_axis("p" + str(player_number) + "_jump", "p" + str(player_number) + "_down")
			)
			
			# Si aucune direction pressée, on dash vers l'avant par défaut
			if input_dir == Vector2.ZERO:
				input_dir.x = 1.0 if facing_right else -1.0
			
			# Lancement du dash
			start_dash(input_dir.normalized())

func start_dash(dir):
	is_dashing = true
	dash_timer = dash_duration
	dash_dir = dir
	if not is_on_floor():
		can_air_dash = false # On consomme le dash aérien
		
# CHUTE RAPIDE 
func handle_fast_fall():
	var down_action = "p" + str(player_number) + "_down"
	if Input.is_action_just_pressed(down_action) and not is_on_floor():
		if velocity.y > 0:
			velocity.y *= FAST_FALL_MULT

#  ATTAQUES : 
func handle_attacks():
	pass

# RECEVOIR UN COUP 
func take_hit(dmg: float, kb_x: float, kb_y: float,
			  attacker_right: bool):
	if invincible_timer > 0:
		return
	is_dashing = false;
	damage_percent += dmg
	var mult = (1.0 + damage_percent / 100.0) / weight
	var vx = kb_x * mult
	var vy = kb_y * mult
	if not attacker_right:
		vx = -vx
	velocity         = Vector2(vx, vy)
	invincible_timer = 0.5
	update_hud()

# MORT
func die():
	stocks -= 1
	emit_signal("stock_lost", player_number, stocks)

	var hud = get_tree().root.get_node_or_null("GameScene/HUD/Control")
	if hud:
		hud.update_stocks(player_number, stocks)

	if stocks <= 0:
		emit_signal("player_eliminated", player_number)
		await get_tree().create_timer(1.0).timeout
		queue_free()
	else:
		await get_tree().create_timer(0.8).timeout
		respawn()

# RESPAWN 
func respawn():
	damage_percent   = 0.0
	velocity         = Vector2.ZERO
	invincible_timer = 2.0
	if player_number == 1:
		position = Vector2(-200, -400)
	else:
		position = Vector2(200, -400)
	sprite.modulate = Color(1, 1, 1, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.5)
	update_hud()

# HUD 
func update_hud():
	var hud = get_tree().root.get_node_or_null("GameScene/HUD/Control")
	if hud:
		hud.update_percent(player_number, damage_percent)

# UTILITAIRE ATTAQUE
func do_attack(hitbox_name: String, startup: float,
			   active: float, recovery: float):
	is_attacking = true
	await get_tree().create_timer(startup).timeout
	get_node(hitbox_name).monitoring = true
	await get_tree().create_timer(active).timeout
	get_node(hitbox_name).monitoring = false
	await get_tree().create_timer(recovery).timeout
	is_attacking = false
	
	# LEDGE GRAB 
func _on_ledge_detected(_body):
	# Déclencher seulement si dans les airs et en train de tomber
	if not is_on_floor() and velocity.y > 0 and not is_grabbing_ledge:
		start_ledge_grab()

func _on_ledge_exited(_body):
	pass  # On gère la sortie manuellement

func start_ledge_grab():
	is_grabbing_ledge = true
	can_air_dash = true # On récupère son dash quand on attrape un rebord !
	ledge_timer = LEDGE_HOLD_TIME
	velocity = Vector2.ZERO

func handle_ledge_hang(delta):
	# Figer sur place
	velocity = Vector2.ZERO

	# Décompter le timer
	ledge_timer -= delta

	# Tomber si le timer expire
	if ledge_timer <= 0:
		release_ledge()
		return

	var jump_action = "p" + str(player_number) + "_jump"
	var down_action = "p" + str(player_number) + "_down"

	# Remonter sur la plateforme avec saut
	if Input.is_action_just_pressed(jump_action):
		climb_up()

	# Lâcher avec bas
	if Input.is_action_just_pressed(down_action):
		release_ledge()

func climb_up():
	is_grabbing_ledge = false
	# Donner une impulsion vers le haut et dans la bonne direction
	velocity.y = -jump_force
	velocity.x = 150.0 if facing_right else -150.0
	jumps_remaining = max_jumps

func release_ledge():
	is_grabbing_ledge = false
# Lâcher avec une petite vitesse vers le bas
	velocity.y = 100.0
