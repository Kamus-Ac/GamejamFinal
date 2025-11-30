extends CharacterBody2D

const MAX_SPEED := 200

signal player_attack(dir: Vector2)
signal player_ulti()
@onready var attack_area: Area2D = $Flip/Areas/AttackArea
@onready var anim: AnimatedSprite2D = $Flip/AnimatedSprite2D

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

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_dir * MAX_SPEED
	move_and_slide()

	if Input.is_action_just_pressed("BasicAttack"):
		basic_attack()

	if Input.is_action_just_pressed("Ulti"):
		ulti_attack()

func basic_attack() -> void:
	var dir := get_attack_direction()
	emit_signal("player_attack", dir)
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
	# Guardamos escala original
	var original_scale = attack_area.scale

	# Lo agrandamos temporalmente
	attack_area.scale = Vector2(4, 4)

	var bodies := attack_area.get_overlapping_bodies()
	for b in bodies:
		if b and b.is_in_group("enemies"):
			if b.has_method("die"):
				b.die()

	# Regresar a tamaño original
	attack_area.scale = original_scale




func get_attack_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()


func _on_anim_finished() -> void:
	# cuando termina attack o ulti, volver a idle
	if anim.animation == "BasicAttack": #or anim.animation == "ulti":
		#anim.play("walk")
