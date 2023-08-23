extends RigidBody3D

class_name Tool

var toolType: Utils.TOOLTYPE
var pickuped: bool
@export var pOwnerId: int
@onready var coll = $CollisionShape3D
@onready var mesh = $Mesh
@onready var shootSound = $ShootSound

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
	mesh.show()
	freeze = true

func drop():
	coll.disabled = false
	freeze = false
	mesh.show()

func setOwner(pId: int):
	pOwnerId = pId
	
func resetOwner():
	pOwnerId = 0
