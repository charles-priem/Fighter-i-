extends CharacterBody2D

# ── CONSTANTES DE MOUVEMENT ──────────────────────────────────────
const SPEED = 300.0
const JUMP_VELOCITY = -700.0
const MAX_JUMPS = 2
const HIT_INVINCIBILITY = 0.5
const DASH_SPEED = 600.0
const FAST_FALL_MULTIPLIER = 2.5

# ── DONNÉES DES ATTAQUES [dégâts, force_x, force_y] ─────────────
const ATTACK_DATA = {
	"ground": [8.0,  400.0, -300.0],
	"air":    [6.0,  350.0, -400.0],
	"smash":  [15.0, 700.0, -500.0],
}

# ── VARIABLES ────────────────────────────────────────────────────
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_remaining = MAX_JUMPS
var damage_percent = 0.0
var is_attacking = false
var invincible_timer = 0.0
var stocks = 3
var is_dashing = false

@export var player_number: int = 1

#@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D2

# ── READY ────────────────────────────────────────────────────────
func _ready():
	add_to_group("players")

# ── BOUCLE PRINCIPALE ────────────────────────────────────────────
func _physics_process(delta):
	if invincible_timer > 0:
		invincible_timer -= delta

	if not is_on_floor():
		velocity.y += gravity * delta

	handle_jump()
	handle_movement()

	if not is_attacking:
		handle_attack()
		handle_dash()
		handle_fast_fall()

	move_and_slide()
	update_animation()

	if is_on_floor():
		jumps_remaining = MAX_JUMPS

# ── CLIGNOTEMENT (invincibilité) ─────────────────────────────────
func _process(_delta):
	if invincible_timer > 0:
		var blink = sin(Time.get_ticks_msec() * 0.02) > 0
		$Sprite2D.visible = blink
	else:
		$Sprite2D.visible = true

# ── SAUT ─────────────────────────────────────────────────────────
func handle_jump():
	var action = "p" + str(player_number) + "_jump"
	if Input.is_action_just_pressed(action) and jumps_remaining > 0:
		velocity.y = JUMP_VELOCITY
		jumps_remaining -= 1

# ── MOUVEMENT HORIZONTAL ─────────────────────────────────────────
func handle_movement():
	var direction = Input.get_axis(
		"p" + str(player_number) + "_left",
		"p" + str(player_number) + "_right"
	)
	if direction != 0:
		velocity.x = direction * SPEED
		$Sprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

# ── ATTAQUES ─────────────────────────────────────────────────────
func handle_attack():
	var p = str(player_number)
	if Input.is_action_just_pressed("p" + p + "_attack"):
		if is_on_floor():
			do_ground_attack()
		else:
			do_air_attack()
	elif Input.is_action_just_pressed("p" + p + "_smash"):
		do_smash_attack()

func do_ground_attack():
	is_attacking = true
#	$Hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
#	$Hitbox.monitoring = false
	await get_tree().create_timer(0.20).timeout
	is_attacking = false

func do_air_attack():
	is_attacking = true
#	$Hitbox.monitoring = true
	await get_tree().create_timer(0.12).timeout
#	$Hitbox.monitoring = false
	await get_tree().create_timer(0.15).timeout
	is_attacking = false

func do_smash_attack():
	is_attacking = true
	await get_tree().create_timer(0.12).timeout
#	$Hitbox.monitoring = true
	await get_tree().create_timer(0.25).timeout
#	$Hitbox.monitoring = false
	await get_tree().create_timer(0.35).timeout
	is_attacking = false

# ── DASH ─────────────────────────────────────────────────────────
func handle_dash():
	var direction = Input.get_axis(
		"p" + str(player_number) + "_left",
		"p" + str(player_number) + "_right"
	)
	if Input.is_action_just_pressed("p" + str(player_number) + "_smash") \
	and is_on_floor() and not is_dashing and direction != 0:
		is_dashing = true
		invincible_timer = DASH_SPEED
		velocity.x = direction * DASH_SPEED
		await get_tree().create_timer(0.15).timeout
		is_dashing = false

# ── CHUTE RAPIDE ─────────────────────────────────────────────────
func handle_fast_fall():
	var down = "p" + str(player_number) + "_down"
	if Input.is_action_just_pressed(down) and not is_on_floor():
		if velocity.y > 0:
			velocity.y *= FAST_FALL_MULTIPLIER

# ── RECEVOIR UN COUP ─────────────────────────────────────────────
func take_hit(damage: float, knockback_x: float, knockback_y: float,
			  attacker_facing_right: bool):
	if invincible_timer > 0:
		return
	damage_percent += damage
	var mult = 1.0 + (damage_percent / 100.0)
	var kb_x = knockback_x * mult
	var kb_y = knockback_y * mult
	if not attacker_facing_right:
		kb_x = -kb_x
	velocity.x = kb_x
	velocity.y = kb_y
	invincible_timer = HIT_INVINCIBILITY
	update_hud()

# ── MORT / RÉAPPARITION ──────────────────────────────────────────
func die():
	stocks -= 1
	var hud = get_tree ().root. get_node("GameScene/HUD")
	if hud:
		hud.update_percent(player_number, damage_percent)
	if stocks <= 0:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		respawn()

func respawn():
	damage_percent = 0.0
	position = Vector2(500, 200)
	velocity = Vector2.ZERO
	invincible_timer = 2.0

# ── HUD ──────────────────────────────────────────────────────────
func update_hud():
	var hud = get_tree().root.get_node_or_null("GameScene/HUD")
	if hud:
		hud.update_percent(player_number, damage_percent)

# ── ANIMATIONS ───────────────────────────────────────────────────
func update_animation():
	pass
#	if is_attacking:
#		return
#	if not is_on_floor():
#		anim.play("jump" if velocity.y < 0 else "fall")
#	elif abs(velocity.x) > 10:
#		anim.play("run")
#	else:
#		anim.play("idle")
