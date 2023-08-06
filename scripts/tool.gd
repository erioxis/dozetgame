extends RigidBody3D

class_name Tool

var pickuped: bool
@onready var coll = $CollisionShape3D

func _ready():
	pickuped = false

@rpc("call_local","any_peer")
func use():
	pass

@rpc("call_local","any_peer")
func shoot():
	pass
	
func pickup():
	coll.disabled = true
	freeze = true
	
func drop():
	coll.disabled = false
	freeze = false
