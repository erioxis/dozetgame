extends RigidBody3D

class_name Tool

var pickuped: bool
@export var pOwner: Player
@onready var coll = $CollisionShape3D
@onready var mesh = $Mesh

func _ready():
	pickuped = false

@rpc("call_local","any_peer")
func use(user):
	pass

@rpc("call_local","any_peer")
func shoot(shooter):
	pass
	
func unhold():
	coll.disabled = true
	freeze = true
	mesh.hide()
	
func hold():
	coll.disabled = true
	freeze = false
	mesh.show()

func drop():
	coll.disabled = false
	freeze = false
	mesh.show()
