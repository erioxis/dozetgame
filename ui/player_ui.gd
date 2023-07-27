extends CanvasLayer

@onready var plabel:Label = $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var wavelabel:Label= $MarginContainer/VBoxContainer/Wave
@onready var healthlabel:Label = $MarginContainer/down/Health
@onready var round_info = get_node("/root/RoundInfo")

signal set(p)

func set_func(p):
	plabel.text = "Points: "+str(p)
	
func set_health(h):
	healthlabel.text = "Health: "+str(h)
	
func set_wave(s, w, t):
	match s:
		round_info.round_state.WAIT:
			wavelabel.text = "Waiting: "+str(t)
			wavelabel.add_theme_color_override("font_color", Color(1.0,1.0,1.0,1.0))
		round_info.round_state.WAVE:
			wavelabel.text = "Wave: "+str(w)+": "+str(t)
			wavelabel.add_theme_color_override("font_color", Color(1.0,0.3,0.3,1.0))
		round_info.round_state.CHILL:
			wavelabel.text = "Chill: "+str(t)
			wavelabel.add_theme_color_override("font_color", Color(0.0,0.7,0.7,1.0))

func _ready():
	set.connect(set_func)
