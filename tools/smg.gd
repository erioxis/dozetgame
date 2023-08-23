extends Tool
@onready var nextshoot = 0

func _ready():
	toolType = Utils.TOOLTYPE.GUN

@rpc("call_local", "any_peer")
func shoot(s):
	var shooter = Utils.world.get_player_by_id(s)
	if shooter.isFirstShot:
		nextshoot = 15
	nextshoot += 1
	if nextshoot > 5:
		Utils.world.create_bullet(shooter._raycast.global_position, shooter._raycast.global_rotation, shooter, 10, 100)
		shooter.rpc("play_shoot_effects")
		nextshoot = 0
		shootSound.play()
		shooter.isFirstShot = false
