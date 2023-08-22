extends StaticBody3D

class_name Sigil

var num: int
@onready var letter = $Letter

func set_letter(l):
	letter.text = str(l)
