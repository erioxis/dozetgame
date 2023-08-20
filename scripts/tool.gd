extends RigidBody3D

class_name Tool

var pickuped: bool
@export var pOwnerId: int
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
	freeze = true
	
func hold():
	coll.disabled = true
	freeze = false
	mesh.show()
	freeze = true

func drop():
	coll.disabled = false
	freeze = false
	mesh.show()
	freeze = false

func setOwner(pId: int):
	pOwnerId = pId
	
func resetOwner():
	pOwnerId = 0
