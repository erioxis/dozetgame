extends RigidBody3D

class_name Tool

var pickuped: bool
@onready var coll = $CollisionShape3D

func _ready():
	pickuped = false

func use():
	pass
	
func pickup():
	coll.disabled = true
	freeze = true
	
func drop():
	pass
