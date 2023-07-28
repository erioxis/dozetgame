extends Node3D

@onready var timer: Timer = $Timer

var wave: int = 1;
var max_wave: int = 6;
var wave_time: int = 60;
var chill_time: int = 30;
var wait_time: int = 120;

enum ROUND_STATE
{
	WAIT,
	WAVE,
	CHILL
}

var state: ROUND_STATE

func _physics_process(delta):
	pass

func start_wait():
	state = ROUND_STATE.WAIT
	timer.wait_time = wait_time
	timer.start()

@rpc
func start_round():
	start_wait()
	
func start_wave():
	pass

func start_chill():
	pass
	
@rpc("call_local")
func set_round_info(s,w,t):
	state = s
	wave = w
	if (t>0):
		timer.wait_time = t
	timer.start()
