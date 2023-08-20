extends Node3D

@onready var part = $GPUParticles3D
@onready var sound = $Sound

func boom(p):
	part.amount = p
	part.emitting = true
	part.restart()
	sound.play()

func _physics_process(_delta):
	if (part.emitting == false):
		queue_free()
