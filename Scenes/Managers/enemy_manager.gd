extends Node

@export var enemy_scene: PackedScene
@export var spawn_radius := 480
@export var initial_spawn_count := 3
@export var spawn_increase_per_wave := 2
@export var max_enemies_per_wave := 20
@export var spawn_delay := 0.6  # tiempo entre cada spawn

var current_wave := 1
var enemies_alive := 0

func _ready():
	start_wave()

func start_wave():
	print("=== STARTING WAVE", current_wave, "===")
	
	var enemies_to_spawn = min(
		initial_spawn_count + (current_wave - 1) * spawn_increase_per_wave,
		max_enemies_per_wave
	)
	
	enemies_alive = enemies_to_spawn
	print("Enemies this wave:", enemies_to_spawn)
	
	spawn_wave(enemies_to_spawn)

func spawn_wave(count: int) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		push_warning("No player found in the scene!")
		return

	for i in range(count):
		var dir := Vector2.RIGHT.rotated(randf_range(0, TAU))
		var spawn_pos := player.global_position + dir * spawn_radius
		
		var enemy = enemy_scene.instantiate()
		get_parent().add_child.call_deferred(enemy)
		enemy.global_position = spawn_pos

		# Asignar skin aleatorio desde el propio enemigo
		if enemy.has_method("assign_random_skin"):
			enemy.assign_random_skin()

		# Conectar señal de muerte
		enemy.died.connect(_on_enemy_died)

		# Esperar un poco antes de spawnear el siguiente
		if spawn_delay > 0:
			await get_tree().create_timer(spawn_delay).timeout

func _on_enemy_died():
	enemies_alive -= 1
	print("Enemy died. Alive:", enemies_alive)
	
	if enemies_alive <= 0:
		current_wave += 1
		start_wave()
