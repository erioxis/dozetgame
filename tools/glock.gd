extends Tool
var amy = preload("res://Scenes/amyth.tscn")

@onready var nextshoot = 0
@onready var world = get_tree().get_root().get_node("World")
@rpc("call_local","any_peer")
func shoot():
	nextshoot += 1
	print(nextshoot)
	if nextshoot > 5:
		print("a")
		var ameth = amy.instantiate()
		world.add_child(ameth)
		ameth.global_position = global_position
		var dir:Vector3 = global_position - ameth.global_position
		var dist:float = dir.length()
		ameth.apply_central_impulse(dir*dist*50)
		nextshoot = 0
