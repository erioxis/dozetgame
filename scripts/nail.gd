extends Node3D

class_name Nail

@onready var joint = $Generic6DOFJoint3D
@onready var sound = $Sound

func attach(obj1, obj2):
	joint.node_a = obj1
	joint.node_b = obj2
	
func _ready():
	sound.play()

