extends Tool
@onready var nextshoot = 0
@rpc("call_local","any_peer")
func shoot(shooter):
	nextshoot += 1
	print(Utils.translate_get("HihiHaha"))
	print(Utils.translate_get("oa_bl"))
	print(Utils.translate_get("shmish"))
	if nextshoot > 15:
		print(Utils.dropDice(10))
		nextshoot = 0
