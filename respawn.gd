extends Node3D

class_name Respawn

@onready var timer = $Timer
var target: Utils.WHO
var peer_id

var zombie = preload("res://Scenes/zombie.tscn")
var player = preload("res://Scenes/player.tscn")

func init(id, tar, t):
	target = tar
	peer_id = id
	timer.start(t)

func _on_timer_timeout():
	if target == Utils.WHO.PLAYER:
		Utils.world.add_player(peer_id)
	elif target == Utils.WHO.ZOMBIE:
		Utils.world.zombificate(peer_id)
	queue_free()
