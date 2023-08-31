extends Node3D

@onready var label:Label3D = $Label3D

func set_label(l):
	label.text = str(l)
	
func set_color(c):
	label.modulate = c
	
func _physics_process(delta):
	global_position.y+=delta
	if label.modulate.a8 <= 10:
		queue_free()
		return
	label.modulate.a8 -= 3
	label.outline_modulate.a8 -= 3
	
