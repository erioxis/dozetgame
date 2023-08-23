extends Tool
@onready var nextshoot = 0

func _ready():
	toolType = Utils.TOOLTYPE.GUN

@rpc("call_local","any_peer")
func shoot(shooter):
	if (isFirstShoot):
		nextshoot = 5
		isFirstShoot = false
	nextshoot += 1
	if nextshoot > 5:
		nextshoot = 0
		Utils.world.get_player_by_id(pOwnerId).rpc("play_shoot_effects")
		shootSound.play()
