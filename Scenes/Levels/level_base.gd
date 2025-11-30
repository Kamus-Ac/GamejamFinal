extends Node2D

var hearts_list : Array[TextureRect]
var i = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.took_damage.connect(update_hearts)
	var hearts_parent = $CanvasLayer/HBoxContainer
	for heart in hearts_parent.get_children():
		hearts_list.append(heart)

func update_hearts(health):
	print(health)
	print(i)
	var anim = hearts_list[i].get_child(0)
	if i>=0 and i <= 2:
		anim.play("muerto")
		i += 1
