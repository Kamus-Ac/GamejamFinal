extends CharacterBody2D

const MAX_SPEED := 200

signal player_attack(dir: Vector2)
signal player_ulti()
signal animation_done
@onready var attack_area: Area2D = $Flip/Areas/AttackArea
@onready var anim: AnimatedSprite2D = $Flip/AnimatedSprite2D
@onready var ulti_area: Area2D = $Flip/Areas/UltiArea

#---VIDA---#
#var hearts_list: Array[TextureRect]
var health = 4


enum STATE {
	IDLE,
	RUNNING,
	ATTACKING,
	ATTACKING_ULTI,
	HURTED,
	DEATH
}

var current_state: STATE = STATE.IDLE

#@onready var attack_area: Area2D = $AttackArea
#@onready var ulti_area: Area2D = $UltiArea

func _ready() -> void:
	# asegurar que la animación ataque no esté en loop desde el editor
	# conectar la señal para volver a idle al terminar
	if anim:
		anim.animation_finished.connect(_on_anim_finished)
	# por defecto el area no "monitorea" (no es requerido si usamos get_overlapping_bodies())
	attack_area.monitoring = true 
	#ulti_area.monitoring = false
	
	#habria que agregar los corazones

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_dir * MAX_SPEED
	move_and_slide()
	
	print("PLAYER STATE:" + str(current_state))
	match current_state:
		STATE.IDLE:
			anim.play("idle")
			
			if input_dir != Vector2.ZERO:
				current_state = STATE.RUNNING
			
			if Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			if Input.is_action_just_pressed("Ulti"):
				current_state = STATE.ATTACKING_ULTI
		STATE.RUNNING:
			anim.play("run")
			
			if Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			if Input.is_action_just_pressed("Ulti"):
				current_state = STATE.ATTACKING_ULTI
			
			if input_dir == Vector2.ZERO:
				current_state = STATE.IDLE
		STATE.ATTACKING:
			anim.play("basicAttack")
			basic_attack()
			await animation_done
			
			if Input.is_action_just_pressed("Ulti"):
				current_state = STATE.ATTACKING_ULTI
			
			if input_dir == Vector2.ZERO:
				current_state = STATE.IDLE
			else:
				current_state = STATE.RUNNING
		STATE.ATTACKING_ULTI:
			anim.play("ulti")
			ulti_attack()
			await animation_done
			
			if Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			if input_dir == Vector2.ZERO:
				current_state = STATE.IDLE
			else:
				current_state = STATE.RUNNING
		STATE.HURTED:
			anim.play("hurt")
		STATE.DEATH:
			anim.play("death")

func take_damage():	
	if health>0:
		health-=1
		print("dfsd",health)
		#animacion
		#update heart display, es funcion
	if health <= 0:
		print("Jugador muerto")
		queue_free()


func basic_attack() -> void:
	var dir := get_attack_direction()
	#emit_signal("player_attack", dir)
	#anim.play("BasicAttack")

		# DEBUG: posición y tamaño del area
	#print("AttackArea global_pos:", attack_area.global_position, "shape:", attack_area.get_node("CollisionShape2D").shape)

		# Opción robusta: tomar cuerpos superpuestos AHORA mismo
	var bodies := attack_area.get_overlapping_bodies()
	print("Bodies overlapped (count):", bodies.size())
	for b in bodies:
		print(" - found:", b, " groups:", b.get_groups())
		if b and b.is_in_group("enemies"):
			if b.has_method("die"):
				b.die()

func ulti_attack() -> void:
	var dir := get_attack_direction()
	#emit_signal("player_attack", dir)
	#anim.play("BasicAttack")

		# DEBUG: posición y tamaño del area
	#print("AttackArea global_pos:", attack_area.global_position, "shape:", attack_area.get_node("CollisionShape2D").shape)

		# Opción robusta: tomar cuerpos superpuestos AHORA mismo
	var bodies := ulti_area.get_overlapping_bodies()
	print("Bodies overlapped ULTI(count):", bodies.size())
	for b in bodies:
		print(" - found:", b, " groups:", b.get_groups())
		if b and b.is_in_group("enemies"):
			if b.has_method("die"):
				b.die()

func get_attack_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()

func _on_anim_finished() -> void:
	# cuando termina attack o ulti, volver a idle
	if anim.animation == "BasicAttack": #or anim.animation == "ulti":
		pass#anim.play("walk")


func _on_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		take_damage() # Replace with function body.
