extends Tool

var used: bool = false
var lused: bool = false

@rpc("call_local","any_peer")
func use():
	if (!pOwner._raycast.get_collider()):
		return
	if pOwner._raycast.get_collider().is_in_group("prop"):
		if (!pOwner._raycast.get_collider().hold):
			pass
