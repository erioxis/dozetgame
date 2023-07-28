extends Node3D

@onready var timer = $Timer

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
	if not is_multiplayer_authority(): return

func start_wait():
	state = ROUND_STATE.WAIT
	timer.wait_time = wait_time
	timer.start()

func start_round():
	start_wait()
	
func start_wave():
	timer.wait_time = wave_time
	timer.start()

func start_chill():
	pass
	
func get_wave():
	return wave
	
func get_time():
	return timer.time_left
