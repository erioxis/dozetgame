extends Node3D

@onready var part = $GPUParticles3D

func boom(p):
	part.amount = p
	part.emitting = true
	part.restart()

func _physics_process(delta):
	if (part.emitting == false):
		queue_free()
