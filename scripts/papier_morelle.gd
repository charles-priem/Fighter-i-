extends Node2D

@export var speed = 600
var direction = Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("projectile")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += (-1) * direction * speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_groups()[0] == "players" and body.name != "Morelle":
		var directionRight = true if direction.x > 0 else false
		body.take_hit(5,5,5,directionRight, true)
		queue_free()
	elif body.get_groups()[0] == "platform":
		queue_free()
