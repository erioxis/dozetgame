extends Node3D

@onready var timer: Timer = $Timer

var wave: int = 1;
var max_wave: int = 6;
var wave_time: int = 60;
var chill_time: int = 30;
var wait_time: int = 60;

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
	state = ROUND_STATE.WAVE
	timer.wait_time = wait_time
	timer.start()

func start_chill():
	state = ROUND_STATE.CHILL
	timer.wait_time = chill_time
	timer.start()
	
@rpc("call_local")
func set_round_info(s,w,t):
	state = s
	wave = w
	if (t>0):
		timer.wait_time = t
	timer.start()


func _on_timer_timeout():
	match state:
		ROUND_STATE.WAIT:
			start_wave()
		ROUND_STATE.WAVE:
			start_chill()
			wave += 1
		ROUND_STATE.CHILL:
			start_wave()
			wave += 1
