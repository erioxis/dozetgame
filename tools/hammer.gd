extends Tool

class_name Hammer

var used: bool = false
var lused: bool = false

@rpc("call_local","any_peer")
func use():
	var prop
	var world
	var first: bool = true
	var objects_collide = []
	while pOwner._worldDetect.is_colliding():
		var obj = pOwner._worldDetect.get_collider()
		objects_collide.append( obj )
		pOwner._worldDetect.add_exception( obj )
		pOwner._worldDetect.force_raycast_update()
	for obj in objects_collide:
		if (first):
			prop = obj
			first = false
			pOwner._worldDetect.remove_exception( obj )	
		else:
			world = obj
			pOwner._worldDetect.remove_exception( obj )	
			break	
	if (prop and world):
		if prop.is_in_group("prop"):
			if ((world is StaticBody3D) or (world is Prop)) and (prop is Prop):
				prop.cade(pOwner._raycast.get_collision_point(), pOwner._raycast.global_rotation, world)
				pOwner.rpc("throw")
	pOwner._worldDetect.clear_exceptions()
	
func uncade():
	if (!pOwner._worldDetect.get_collider()) : return
	if pOwner._worldDetect.get_collider().is_in_group("prop"):
		if (pOwner._raycast.get_collider().caded):
			var prop = pOwner._raycast.get_collider() as Prop
			prop.uncade()
