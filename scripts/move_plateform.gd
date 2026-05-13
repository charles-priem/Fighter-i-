extends RigidBody2D
class_name platform

@export var MAX_POSITION_LEFT: float
@export var MAX_POSITION_RIGHT: float

var deplacementRight: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("platform")
	gravity_scale = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move()

func move():
	if position.x >= MAX_POSITION_RIGHT:
		deplacementRight = false
	elif position.x <= MAX_POSITION_LEFT:
		deplacementRight = true
	
	if deplacementRight:
		linear_velocity = Vector2(200, 0)
	else:
		linear_velocity = Vector2(-200, 0)
