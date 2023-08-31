extends Node3D

@onready var props_node = $props
@onready var sigils = $sigils
@onready var zgases = $zgases
	
func get_props():
	return props_node
	
func get_sigils():
	return sigils
	
func get_zgases():
	return zgases
