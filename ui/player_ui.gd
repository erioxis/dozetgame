extends CanvasLayer

@onready var plabel:Label = $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var wavelabel:Label= $MarginContainer/VBoxContainer/Wave
@onready var healthlabel:Label = $MarginContainer/down/Health
@onready var sigilProgress: ProgressBar= $ProgressBar
@onready var sigilText:Label = $ProgressBar/ProgressText
@onready var hurt = $Hurt

var game_manager

signal set(p)

func set_func(p):
	plabel.text = "Points: "+str(p)
	
func set_hurt(h):
	hurt.color.a8 = clamp(h, 0, 100)
	
func set_sigil(s, l):
	sigilProgress.value = s
	sigilText.text = Utils.translate_get("Teleporting to sigil")+" "+str(l)
	
func zombificate():
	sigilProgress.visible = false
	sigilText.visible = false
	plabel.visible = false

func set_wave(s,w,t):
	var nam: String
	var remainder = fmod(int(t),3)
	var hehe : bool = true
	#print(remainder)
	match s:
		0:
			match remainder:
				0.0:
					nam = "Waiting players..."
				1.0: 
					nam = "Waiting players.."
				2.0: 
					nam = "Waiting players."
			hehe = false
		1:
			nam = "Wave"
		2:
			nam = "Just chill"
	if hehe: 
		wavelabel.text = nam + " "+str(w)+": "+str(int(t))
	else:
		wavelabel.text = nam + " "+str(int(t))

func set_health(h):
	healthlabel.text = "Health: "+str(clamp(h,0,9999))

func _ready():
	set.connect(set_func)
	
func dead():
	wavelabel.text = "You are dead!"
