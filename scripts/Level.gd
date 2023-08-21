extends Node3D

@onready var spawn = $Spawn
@onready var props_node = $props

func get_spawn():
	return spawn
	
func get_props():
	return props_node
