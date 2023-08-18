extends Tool
@onready var nextshoot = 0
@rpc("call_local","any_peer")
func shoot():
	nextshoot += 1
	if nextshoot > 5:
		pass
	pass
