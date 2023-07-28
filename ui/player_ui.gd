extends CanvasLayer

@onready var plabel:Label = $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var wavelabel:Label= $MarginContainer/VBoxContainer/Wave
@onready var healthlabel:Label = $MarginContainer/down/Health

signal set(p)

func set_func(p):
	plabel.text = "Points: "+str(p)

func set_wave(w):
	wavelabel.text = w

func set_health(h):
	healthlabel.text = "Health: "+str(h)

func _ready():
	set.connect(set_func)
