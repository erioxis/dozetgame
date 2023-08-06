extends RigidBody3D

class_name Prop

var health: float
var durability: float
var nails: int

func _ready():
	health = mass * global_transform.basis.x.length() * global_transform.basis.y.length() * global_transform.basis.z.length() / 10
	durability = health * 3
	nails = 0
