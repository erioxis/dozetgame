extends Tool

class_name Hammer

var used: bool = false
var lused: bool = false

func _ready():
	toolType = Utils.TOOLTYPE.TOOL

@rpc("call_local","any_peer")
func use(uid):
	if (!useTimer.is_stopped()): return
	useTimer.start(0.5)
	var user = Utils.world.get_player_by_id(int(str(uid)))
	user.rpc("play_use_effects")
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
				user._worldDetect.force_raycast_update()
				prop.cade(user._worldDetect.get_collision_point(), user._worldDetect.global_rotation, world)
				user.rpc("throw")
	user._worldDetect.clear_exceptions()
	
@rpc("call_local","any_peer")
func uncade(uid):
	var pOwner = Utils.world.get_player_by_id(uid)
	if (!pOwner._worldDetect.get_collider()) : return
	if pOwner._worldDetect.get_collider().is_in_group("prop"):
		if (pOwner._worldDetect.get_collider().caded):
			var prop = pOwner._raycast.get_collider() as Prop
			if (prop):
				prop.uncade(pOwner._raycast.get_collision_point())
