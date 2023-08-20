extends Tool
@onready var nextshoot = 0
@rpc("call_local","any_peer")
func shoot(shooter):
	nextshoot += 1
	if nextshoot > 5:
		print(Utils.dropDice(10))
		nextshoot = 0
