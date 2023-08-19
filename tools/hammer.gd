extends Tool

class_name Hammer

var used: bool = false
var lused: bool = false

@rpc("call_local","any_peer")
func use(user):
	var prop
	var world
	var first: bool = true
	var objects_collide = []
	while user._worldDetect.is_colliding():
		var obj = user._worldDetect.get_collider()
		objects_collide.append( obj )
		user._worldDetect.add_exception( obj )
		user._worldDetect.force_raycast_update()
	for obj in objects_collide:
		if (first):
			prop = obj
			first = false
			user._worldDetect.remove_exception( obj )	
		else:
			world = obj
			user._worldDetect.remove_exception( obj )	
			break	
	if (prop and world):
		if prop.is_in_group("prop"):
			if ((world is StaticBody3D) or (world is Prop)) and (prop is Prop):
				prop.cade(user._raycast.get_collision_point(), user._raycast.global_rotation, world)
				user.rpc("throw")
	user._worldDetect.clear_exceptions()
	
func uncade():
	if (!pOwner._worldDetect.get_collider()) : return
	if pOwner._worldDetect.get_collider().is_in_group("prop"):
		if (pOwner._raycast.get_collider().caded):
			var prop = pOwner._raycast.get_collider() as Prop
			prop.uncade()
