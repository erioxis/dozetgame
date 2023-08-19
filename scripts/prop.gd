extends RigidBody3D

class_name Prop

@export var health: float
@export var durability: float
@export var nails: int
@export var hold: bool = false
@export var caded: bool = false
const duraMult: float = 50
const maxNails: int = 4
const minHealth: float = 200
const maxHealth: int = 4600
const massFactor: int = 0.85 * 3
const volumeFactor: int = 0.85 * 4
@export var nailsObjects = []
var nailScene = preload("res://Scenes/nail.tscn")
@onready var heal = $Health
@onready var dura = $Durability
var joint: Generic6DOFJoint3D

func _ready():
	health = clamp((mass *  massFactor + (global_transform.basis.x.length() + global_transform.basis.y.length() + global_transform.basis.z.length()) * duraMult * massFactor), minHealth, maxHealth)
	durability = health * 2.5
	nails = 0
	
func _physics_process(delta):
	heal.text = "health: "+str(health)
	dura.text = "durability: "+str(durability)

func cade(pos, rot, tar):
	if nails >= maxNails:
		return
	if (!caded):
		joint = Generic6DOFJoint3D.new()
		joint.node_a = self.get_path()
		joint.node_b = tar.get_path()
		add_child(joint, true)
		caded = true
	nails+=1
	if (multiplayer.is_server()):
		var nailobj = nailScene.instantiate()
		add_child(nailobj, true)
		nailsObjects.push_back(nailobj)
		rpc("send_nail", nailobj)
		nailobj.global_position = pos
		nailobj.global_rotation = rot
	
func uncade():
	if (nails==1):
		caded = false
		joint.queue_free()
		nails = 0
		for n in nailsObjects:
			if (is_instance_valid(n)):
				n.queue_free()
		nailsObjects.clear()
	else:
		nails-=1
		var nobj = nailsObjects.pick_random()
		if (is_instance_valid(nobj)):
			nobj.queue_free()
			nailsObjects.erase(nobj)
		
@rpc("call_local")
func send_nail(n):
	nailsObjects.push_back(n)
		
