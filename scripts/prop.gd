extends RigidBody3D

class_name Prop

@export var health: float
@export var durability: float
@export var nails: int
@export var hold: bool = false
@export var caded: bool = false
@export var uiHeight: float = 0.6
const duraMult: float = 10
const maxNails: int = 4
const minHealth: float = 100
const maxHealth: int = 4600
var baseHealth: int
const nailPerHealth: int = 75
const massFactor: int = 10

var nailScene = preload("res://Scenes/nail.tscn")
@onready var heal = $ui/Health
@onready var dura = $ui/Durability
@onready var nailsnode = $nails
@onready var nailslabel = $ui/Nails
@onready var uncadeSound = $UncadeSound
@onready var impactSound = $ImpactSound
@onready var ui = $ui


func _ready():
	baseHealth = clamp((mass  * duraMult * massFactor), minHealth, maxHealth)
	health = baseHealth
	durability = health * 2.5
	nails = 0
	uiHeight = ui.global_position.y - global_position.y

func _physics_process(delta):
	heal.text = "health: "+str(health)
	dura.text = "durability: "+str(durability)
	nailslabel.text = "nails: "+str(nails)+"/"+str(maxNails)
	if(caded):
		ui.visible = true
	else:
		ui.visible = false
	ui.global_position = global_position
	ui.global_rotation = Vector3.ZERO
	ui.global_position.y+=uiHeight
	
	if (health<=0):
		uncadeSound.play()
		queue_free()

@rpc("call_local", "any_peer")
func cade(pos, rot, tar):
	if nails >= maxNails:
		return
	if (multiplayer.is_server()):
		var nailobj: Nail = nailScene.instantiate()
		nailsnode.add_child(nailobj, true)
		nailobj.global_position = pos
		nailobj.global_rotation = rot
		nailobj.attach(self.get_path(), tar.get_path())
		nailobj.rpc("sync_rot",rot)
	caded = true
	nails+=1
	health+=nailPerHealth

@rpc("call_local", "any_peer")
func uncade(hit):
	if (nails>0):
		nails-=1
		health-=nailPerHealth
		
		var nobj = nailsnode.get_child(0)
		
		for n in nailsnode.get_children():
			if (hit.distance_to(n.global_position)<= hit.distance_to(nobj.global_position)):
				nobj = n
		
		if (multiplayer.is_server()):
			if (is_instance_valid(nobj)):
				nobj.queue_free()
				uncadeSound.play()
		if (nails==0):
			caded=false

@rpc("call_local", "any_peer", "reliable")
func damage(dmg):
	impactSound.play()
	health -= dmg
	if ($MeshInstance3D.get_surface_override_material(0) is ShaderMaterial):
		var material:ShaderMaterial = $MeshInstance3D.get_surface_override_material(0)
		var brit = clamp(health/baseHealth,0,1)
		material.set_shader_parameter("brit", brit)
		$MeshInstance3D.material_override = material
	
