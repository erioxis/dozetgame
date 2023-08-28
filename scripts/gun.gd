extends Tool

class_name Gun

var whenshoot: float = 0.2
var canShoot: bool = true
var damage: float = 10

func _ready():
	toolType = Utils.TOOLTYPE.GUN

@rpc("call_local", "any_peer")
func shoot(s):
	var shooter = Utils.world.get_player_by_id(s)
	if shootTimer.is_stopped():
		shootTimer.start(whenshoot)
		Utils.world.create_bullet(shooter._raycast.global_position, shooter._raycast.global_rotation, shooter, damage, 100)
		shooter.rpc("play_shoot_effects")
		shootSound.play()
