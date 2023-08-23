extends Tool
@onready var nextshoot = 0
@rpc("call_local","any_peer")

func _ready():
	toolType = Utils.TOOLTYPE.GUN

func shoot(shooter):
	nextshoot += 1
	if nextshoot > 15:
		var p = Utils.world.get_player_by_id(pOwnerId)
		Utils.world.create_bullet(p._raycast.global_position, p._raycast.global_rotation, p, 10, 100)
		p.rpc("play_shoot_effects")
		nextshoot = 0
		shootSound.play()
