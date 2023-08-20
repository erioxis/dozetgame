extends Node3D

class_name Nail

@onready var joint = $Generic6DOFJoint3D

func attach(obj1, obj2):
	joint.node_a = obj1
	joint.node_b = obj2
