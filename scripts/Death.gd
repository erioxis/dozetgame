extends Area3D

func _on_body_entered(body):
	if (body.is_in_group("player")):
		var player = body as Player
		if (player):
			player.damage(101)
#	elif (body.is_in_group("prop")):
	#	var prop = body as
