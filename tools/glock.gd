extends Tool
@onready var nextshoot = 0
@rpc("call_local","any_peer")

func _ready():
	toolType = Utils.TOOLTYPE.GUN

func shoot(shooter):
	nextshoot += 1
	if nextshoot > 15:
		Utils.world.get_player_by_id(pOwnerId).rpc("play_shoot_effects")
		nextshoot = 0
		shootSound.play()
