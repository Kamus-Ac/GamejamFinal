extends CharacterBody2D
@onready var hit_lag: Timer = $HitLag


const MAX_SPEED = 75
const IMPULSE = 0.5

#varibles debug
var vel: Vector2 = Vector2.ZERO
var check
var collision
var body: Node2D

var hitting : bool = false
var hit_obj_enemy: bool = false
var hit_enemy_enemy: bool = false

var push_obj_enemy : Vector2 = Vector2.ZERO
var mag_obj_enemy : float = 0
var push_enemy_enemy : Vector2 = Vector2.ZERO

func _ready() -> void:
	SignalManager.isLaunching.connect(islaunching)

func _physics_process(_delta):
	if !hitting:
		var direction = get_direction_to_player()
		
		vel = direction * MAX_SPEED
		velocity = vel
		collision = move_and_collide(velocity*_delta)
		if collision: 
			check = collision.get_collider()
			if check.is_in_group("objects") || check.is_in_group("enemies"):
				SignalManager.isLaunching.emit()
	if hitting:
		if hit_enemy_enemy:
			var push_force = Vector2(
			clampf(push_enemy_enemy.x, 100, 100.0),
			clampf(push_enemy_enemy.y, 100, 100.0)
			)
			var final = Vector2(
			push_force.x * sign(push_enemy_enemy.x),
			push_force.y * sign(push_enemy_enemy.y)
			)
			velocity = final
		if hit_obj_enemy:
			push_obj_enemy += push_obj_enemy 
			var push_force = Vector2(
			clampf(push_obj_enemy.x, 100, 100.0),
			clampf(push_obj_enemy.y, 100, 100.0)
			)
			var final = Vector2(
			push_force.x * sign(push_obj_enemy.x),
			push_force.y * sign(push_obj_enemy.y)
			)
			#velocity = Vector2(clampf(push_obj_enemy.x,50.0,200),clampf(push_obj_enemy.y,50,200)) * direction
			velocity = final
		#print (velocity)
		move_and_slide()

func die():
	queue_free()

func get_direction_to_player():
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node != null:
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO

func islaunching():
	if collision:
			body = collision.get_collider()
			if body.is_in_group("objects") and !hitting:
				velocity = Vector2.ZERO
				hitting = true
				hit_obj_enemy = true
				hit_lag.start(1.0)
				push_obj_enemy = collision.get_normal()
				
				if body is RigidBody2D:
					var dir_to_rb = (body.global_position - global_position).normalized()
					var rb_impulse = dir_to_rb * (IMPULSE * 50) # Escala para que sí se mueva
					body.apply_impulse(rb_impulse)
					
			if body.is_in_group("enemies") and !hitting:
				velocity = Vector2.ZERO
				hitting = true
				hit_enemy_enemy = true
				hit_lag.start(1.0)
				push_enemy_enemy = collision.get_normal()


func _on_hit_lag_timeout() -> void:
	hitting = false
	
	if hit_obj_enemy:
		hit_obj_enemy=false
	
	if hit_enemy_enemy:
		hit_enemy_enemy=false
