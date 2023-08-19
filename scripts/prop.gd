extends RigidBody3D

class_name Prop

var health: float
var durability: float
var nails: int
var hold: bool = false
var caded: bool = false
const maxNails: int = 4
var nailsObjects = []
var nailScene = preload("res://Scenes/nail.tscn")
var joint: Generic6DOFJoint3D

func _ready():
	health = mass * global_transform.basis.x.length() * global_transform.basis.y.length() * global_transform.basis.z.length() / 10
	durability = health * 3
	nails = 0

func cade(pos, rot, tar):
	if nails >= maxNails:
		return
	if (!caded):
		joint = Generic6DOFJoint3D.new()
		joint.node_a = self.get_path()
		joint.node_b = tar.get_path()
		add_child(joint)
		caded = true
	nails+=1
	var nailobj = nailScene.instantiate()
	add_child(nailobj)
	nailsObjects.push_back(nailobj)
	nailobj.global_position = pos
	nailobj.global_rotation = rot
	
func uncade():
	if (nails==1):
		caded = false
		joint.queue_free()
		nails = 0
		for n in nailsObjects:
			n.queue_free()
			nailsObjects.clear()
	else:
		nails-=1
		var nobj = nailsObjects.pick_random()
		nobj.queue_free()
		nailsObjects.erase(nobj)
