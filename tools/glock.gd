extends Tool
var amy = preload("res://Scenes/amyth.tscn")
@onready var camera = $Head/Camera3D
@onready var nextshoot = 0
@rpc("call_local","any_peer")
func shoot():
	nextshoot += 1
	print(nextshoot)
	if nextshoot > 5:
		print("a")
		var ameth = amy.instantiate()
		Utils.world.add_child(ameth, true)
		ameth.global_position = global_position
		var dir:Vector3 = global_position - camera.global_position
		var dist:float = dir.length()
		ameth.apply_central_impulse(dir*dist*50)
		nextshoot = 0
