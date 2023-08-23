extends Node3D

@onready var raycast = $RayCast3D
var powner: Player
var damage: float

@rpc("any_peer", "call_local")
func init(pos, rot, o, damage, l):
	if (!multiplayer.is_server()): return
	global_position = pos
	global_rotation = rot
	powner =  o
	raycast.target_position.z = -l
	raycast.force_raycast_update()
	if (raycast.get_collider()):
		var target = raycast.get_collider()
		if target is Zombie:
			target.rpc("damage",damage)
	#queue_free()
