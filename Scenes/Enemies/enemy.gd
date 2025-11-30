extends CharacterBody2D

const SPEED = 75

func _ready() -> void:
	pass#add_to_group("enemies")   # <-- importante si no lo has agregado en el editor

func _physics_process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()

func die():
	queue_free()
