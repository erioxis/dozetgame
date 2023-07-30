extends CanvasLayer

@onready var plabel:Label = $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var wavelabel:Label= $MarginContainer/VBoxContainer/Wave
@onready var healthlabel:Label = $MarginContainer/down/Health

var game_manager

signal set(p)

func set_func(p):
	plabel.text = "Points: "+str(p)

func set_wave(s,w,t):
	var nam: String
	match s:
		0:
			nam = "WAIT"
		1:
			nam = "WAVE"
		2:
			nam = "CHILL"
	wavelabel.text = nam + " "+str(w)+": "+str(int(t))

func set_health(h):
	healthlabel.text = "Health: "+str(h)

func _ready():
	set.connect(set_func)
	
func dead():
	wavelabel.text = "You are dead!"
