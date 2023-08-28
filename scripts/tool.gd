extends RigidBody3D

class_name Tool

var toolType: Utils.TOOLTYPE
var pickuped: bool
var lootimer: float
var lootb: bool
@export var pOwnerId: int
@onready var coll = $CollisionShape3D
@onready var mesh = $Mesh
@onready var shootSound = $ShootSound
@onready var shootTimer: Timer = $shootTimer
@onready var useTimer: Timer = $useTimer

func _ready():
	pickuped = false
	lootimer = 0
	lootb = true

@rpc("call_local","any_peer")
func use(user):
	pass

@rpc("call_local", "any_peer")
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
	
func _physics_process(delta):
	
	if (!pickuped):
		var material:ShaderMaterial = $Mesh.get_surface_override_material(0)
		material.set_shader_parameter("loot", true)
		$Mesh.material_override = material
	else:
		var material:ShaderMaterial = $Mesh.get_surface_override_material(0)
		material.set_shader_parameter("loot", false)
		$Mesh.material_override = material
	
	if (lootb):
		lootimer+= delta;
	else:
		lootimer-=delta;
	if (abs(lootimer)>=0.6):
		lootb = not lootb
		
	var material:ShaderMaterial = $Mesh.get_surface_override_material(0)
	material.set_shader_parameter("loottimer", lootimer)
	$Mesh.material_override = material
