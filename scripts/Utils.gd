extends Node

var world
var nickname

func dropDice(num: int):
	if (randi()%num+1==num):
		return true
	else:
		return false
