extends "res://Scenes/Players/basic_player.gd"
@onready var animacion: AnimatedSprite2D = $Flip/AnimatedSprite2D
@onready var object: RigidBody2D = null
@onready var flip: Node2D = $Flip
@onready var marker_2d: Marker2D = $Marker2D


#flip sprite
var mouse_position: Vector2 = Vector2.ZERO
var flip_position: Vector2 = Vector2.ZERO

#throw object
var lastClickState: bool = false
var isClickBeingPressed: bool = false
var factor: float = 1 # Factor de velocidad conforme mantienes el click
var objectPosition: Vector2 = Vector2.ZERO

#grab object
var grabbing: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	flip_sprite()
	rotate_object()
	#if Input.is_action_pressed("BasicAttack"):
		#animacion.play("BasicAttack")
		#pass
		
	
	isClickBeingPressed = false
	if object:
		if !grabbing:
			grab_objects()
		if Input.is_action_pressed("Grab") and grabbing:
			isClickBeingPressed = true
			lastClickState = isClickBeingPressed
			if factor < 5: # El valor maximo del factor es 5
				factor += 0.1 # Se suma 0.1 al factor cada frame
			
		if lastClickState == true and isClickBeingPressed == false:
			grabbing = false
			throw_object()
			lastClickState = false

func throw_object():
	var root_node = get_tree().current_scene
			
	objectPosition = object.global_position
	
	object.get_parent().remove_child(object)
	root_node.add_child(object)
	var col = object.get_node("CollisionTF")
	col.disabled = false
	object.position =  objectPosition
	
	
	object.apply_impulse(flip_position * -factor)
	object = null
	
	
func flip_sprite():
	mouse_position = get_global_mouse_position()
	flip_position = position - mouse_position
	if flip_position.x < 0:
		
		#scale = Vector2(1,1)
		#animacion.flip_h = false
		flip.scale.x= 1
		#$AttackArea/CollisionShape2D.scale.x = -1    # áreas hacia la derecha
	elif flip_position.x > 0:
		#$AttackArea/CollisionShape2D.scale.x = 1    # áreas hacia la derecha
		#animacion.flip_h = true
		flip.scale.x= -1
		#scale = Vector2(-1,1)
func rotate_object():
	marker_2d.look_at(get_global_mouse_position())
	
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#var root_node = get_tree().current_scene
			#
			#object.get_parent().remove_child(object)
			#root_node.add_child(object)
			#
			#object.apply_impulse(flip_position * -factor)



	

func grab_objects():
	if Input.is_action_just_pressed("Grab"):
		grabbing = true
		object.get_parent().remove_child(object)
		marker_2d.add_child(object)
		var col = object.get_node("CollisionTF")
		col.disabled = true
		object.linear_velocity = Vector2.ZERO
		object.position = Vector2(25, 0)
		
		


func _on_AttackArea_body_entered(body):
	if body.is_in_group("enemies"):
		body.die()


func _on_recolect_body_entered(body: Node2D) -> void:
	if body.is_in_group("objects"):
		object = body
