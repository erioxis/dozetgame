extends Tool
@onready var nextshoot = 0

func _ready():
	toolType = Utils.TOOLTYPE.GUN

@rpc("call_local","any_peer")
func shoot(shooter):
	nextshoot += 1
	if nextshoot > 5:
		var p = Utils.world.get_player_by_id(pOwnerId)
		Utils.world.create_bullet(p._raycast.global_position, p._raycast.global_rotation, p, 10, 100)
		p.rpc("play_shoot_effects")
		nextshoot = 0
		shootSound.play()
