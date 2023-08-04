extends RigidBody3D

class_name Player

@onready var camera = $Head/Camera3D
@onready var _raycast = $Head/Camera3D/RayCast
@onready var _label = $Label3D
@onready var bodymesh = $body
@onready var ui = $player_ui
@onready var hand = $Head/Camera3D/hand
@onready var head = $Head
@onready var headmesh = $Head/Camera3D/head
#@onready var anim_player = $AnimationPlayer
@onready var body = $bodycol
@onready var feet = $feet
@onready var hold_position = $Head/Camera3D/hold
@export var view_sensitivity = 10.0
var is_on_floor = false
var move_input

var bloodexp = preload("res://Scenes/blood_explosion.tscn")

@export var jump_velocity = 7
@export var acceleration = 7
var accel_multiplier = 1.0
@export var speed = 25
@export var max_speed = 50
@export var stop_speed = 0.1
@export var rotate = false

var velocity = Vector3()

var tools: Array[Tool]
var currentTool: Tool

var mouse_input = Vector2()

var dead: bool
var held_object: RigidBody3D
var points:int = 15
var health:float = 100

var world
var game_manager

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	tools.resize(3)
	dead = false
	world = get_tree().get_root().get_node("World")
	game_manager = get_tree().get_root().get_node("World").get_node("GameManager")
	
	if not is_multiplayer_authority():
		ui.hide()
		return

	linear_damp = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	bodymesh.visible = false
	headmesh.visible = false
	_label.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	camera.current = true

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
		
	pass

func _physics_process(delta):

	if (held_object):
		var direct: Vector3 = hold_position.global_position - held_object.global_position
		var dist: float = direct.length()
		held_object.linear_velocity = direct * min(1.2,dist) * 12
		rotate = Input.is_action_pressed("alt")
		if dist > 2.5: 
			held_object = null
			return
		if rotate:
			pass
		
			

	if not is_multiplayer_authority(): return
	# Add the gravity.
	set_ui()
	
	move(delta)
	
	if Input.is_action_pressed("right_click"):
		if (currentTool):
			currentTool.rpc("use")
		#rpc("play_shoot_effects")
	if Input.is_action_pressed("left_click"):
		if (currentTool):
			currentTool.rpc("shoot")
	
	#if anim_player.current_animation == "shoot":
	#	pass
	#elif move_input != Vector2.ZERO and feet.is_colliding():
	#	anim_player.play("move")
	#else:
	#	anim_player.play("idle")
		
	if (health<=0 and dead==false):
		rpc("kill")
		dead = true

func move(delta):
	is_on_floor = false
	move_input = Vector2.ZERO
	var dir = Vector3()
	#movement input
	move_input = Input.get_vector("left","right","down","up")
	dir += move_input.x*head.global_transform.basis.x;
	dir -= move_input.y*head.global_transform.basis.z;
	velocity = lerp(velocity,dir*speed,acceleration*accel_multiplier*delta)
	apply_central_force(velocity)
	if feet.is_colliding():
		is_on_floor = true
		accel_multiplier = 1.0
	if Input.is_action_just_pressed("jump") and is_on_floor:
		accel_multiplier = 0.1
		is_on_floor = false
		apply_central_impulse(Vector3.UP * jump_velocity)
	if Input.is_action_just_pressed("interact"):
		rpc("interact")
	#view and rotation
	camera.rotation_degrees.x -= mouse_input.y * view_sensitivity * delta;
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x,-80,80)
	head.rotation_degrees.y -= mouse_input.x * view_sensitivity * delta;
	mouse_input =Vector2.ZERO
	bodymesh.global_rotation.y = head.global_rotation.y

	
func _integrate_forces(state):
	if not is_multiplayer_authority(): return
	#limit max speed
	if state.linear_velocity.length()>max_speed:
		state.linear_velocity=state.linear_velocity.normalized()*max_speed
	#artificial stopping movement i.e not using physics
	if move_input.length() < 0.2:
		state.linear_velocity.x = lerp(state.linear_velocity.x,0.0,stop_speed)
		state.linear_velocity.z = lerp(state.linear_velocity.z,0.0,stop_speed)
	#push against floor to avoid sliding on "unreasonable" slopes
	if state.get_contact_count() > 0 and move_input.length()< 0.2:
		if is_on_floor and state.get_contact_local_normal(0).y < 0.9:
			apply_central_force(-state.get_contact_local_normal(0))

#mouse input
func _input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseButton:
		rpc("throw")
	if event is InputEventMouseMotion:
		mouse_input = event.relative;

func set_ui():
	ui.set_health(health)
	ui.emit_signal("set", points)
	ui.set_wave(game_manager.state, game_manager.wave, game_manager.timer.time_left)

@rpc("call_local", "any_peer")
func throw():
	if (held_object):
		var dir:Vector3 = hold_position.global_position - camera.global_position
		var dist:float = dir.length()
		held_object.apply_central_impulse(dir*dist*3)
		held_object=null

@rpc("call_local","any_peer")
func interact():
	if (held_object):
		held_object = null
		return
	if (!_raycast.get_collider()):
		return
	if _raycast.get_collider().is_in_group("prop"):
		held_object = _raycast.get_collider()
	elif _raycast.get_collider() is Tool:
		var t:Tool = _raycast.get_collider() as Tool
		if (t.pickuped): return
		rpc("pick_up", t)

@rpc("any_peer")
func damage(d):
	health-=d
	if d > 0:
		world.create_blood(d, global_position)

@rpc("call_local", "any_peer")
func pick_up(t: Tool):
	if currentTool == null:
		currentTool = t
		t.get_parent().remove_child(t)
		hand.add_child(t)
		t.global_position = hand.global_position
		t.global_rotation = hand.global_rotation
		t.pickup()

@rpc("any_peer", "call_local")
func kill():
	world.create_blood(20, global_position)
	world.kill_player(name)
	ui.dead()
	
@rpc("call_local")
func play_shoot_effects():
	#anim_player.stop()
	#anim_player.play("shoot")
	pass
