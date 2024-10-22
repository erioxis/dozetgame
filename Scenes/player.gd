extends RigidBody3D

class_name Player

@onready var camera = $Head/Camera3D
@onready var _raycast:RayCast3D = $Head/Camera3D/RayCast
@onready var _worldDetect:RayCast3D = $Head/Camera3D/worldDetect
@onready var _label = $Label3D
@onready var bodymesh = $body
@onready var ui = $player_ui
@onready var hand = $Head/Camera3D/hand
@onready var head = $Head
@onready var headmesh = $Head/Camera3D/head
@onready var anim_player = $AnimationPlayer
@onready var boots_player = $AnimationBoots
@onready var body = $bodycol
@onready var feet = $feet
@onready var hold_position = $Head/Camera3D/hold
@onready var stepSound = $step
@onready var teleportTimer: Timer = $teleportTimer
@onready var coll: CollisionShape3D = $bodycol
@export var view_sensitivity = 10.0

@export var shift: bool = false
var is_on_floor = false
var move_input

@export var isWalking: bool

var hurt: float = 0

var bloodexp = preload("res://Scenes/blood_explosion.tscn")

var currentSigil: Sigil
var selectedSigil: Sigil
var isTeleporting: bool

@export var jump_velocity = 7
@export var acceleration = 7
var accel_multiplier = 1.0
@export var speed = 25
@export var max_speed = 50
@export var stop_speed = 0.1

@export var last_pos: Vector3

@export var rotating: bool = false

var velocity = Vector3()

@export var tools: Array[Tool] = []
var currentTool: Tool
var currentSlot: int = 1


@export var mouse_input = Vector2()

var dead: bool
var held_object: Prop
var points:int = 15
var health:float = 100

var propDamageMult = 1

var game_manager

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	dead = false
	Utils.world = get_tree().get_root().get_node("World")
	game_manager = get_tree().get_root().get_node("World").get_node("GameManager")
	_raycast.add_exception(self)
	
	if not is_multiplayer_authority():
		ui.hide()
		return
	if Utils.nickname == "":
		#_label.modulate = Color(1,0,1,1)
		pass
	else:
		#add_theme_color_override("font_color", Color(1,0,0))
		_label.text = Utils.nickname
		#_label.modulate = Color(0,0,0,1)
		
	

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

func _process(delta):
	for tl in tools:
		tl.global_position = hand.global_position
		tl.global_rotation = hand.global_rotation

func _physics_process(delta):
	if (hurt>0):
		hurt-=1
	find_current_sigil()
	if (held_object):
		var direct: Vector3 = hold_position.global_position - held_object.global_position
		var dist: float = direct.length()
		if (!shift):
			held_object.linear_velocity = direct * min(1.2,dist) * 1000 * delta
		else:
			var ldirect: Vector3 = last_pos - held_object.global_position
			var ldist: float = direct.length()
			held_object.linear_velocity = ldirect * min(1.2,ldist) * 1000 * delta
			
		if dist > 2.5: 
			held_object.hold = false
			held_object = null
			rotating = false
			return
		if rotating:
			#var rotat = mouse_input
			#held_object.rotate_y(rotat.x * .1 * delta)
			#held_object.rotate_z(-rotat.y * .1 * delta)
			#held_object.angular_velocity = Vector3.ZERO
			var x_axis = camera.get_camera_transform().basis[0]
			var y_axis = camera.get_camera_transform().basis[1]
			held_object.rotate(y_axis, mouse_input.x*delta/5)
			held_object.rotate(x_axis, mouse_input.y*delta/5)
			held_object.angular_velocity = Vector3.ZERO
			

	if not is_multiplayer_authority(): return
	# Add the gravity.
	set_ui()
	
	move(delta)
	
	if Input.is_action_just_pressed("right_click"):
		if (currentTool):
			currentTool.rpc("use", name)
	if Input.is_action_pressed("left_click"):
		if (currentTool):
			currentTool.rpc("shoot", int(str(name)))
	
	if !anim_player.current_animation == "use" and !anim_player.current_animation == "shoot":
		if move_input != Vector2.ZERO and feet.is_colliding():
			isWalking = true
			anim_player.play("move")
		else:
			isWalking = false
			anim_player.play("idle")
			
	if isWalking:
		boots_player.play("walk")
		if (!stepSound.playing):
			stepSound.play()
	else:
		boots_player.play("RESET")
		
	if (health<=0 and dead==false):
		rpc("kill")
		dead = true
		

func move(delta):
	is_on_floor = false
#	move_input = Vector2.ZERO
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
	if Input.is_action_just_pressed("slot1"):
		rpc("change_tool", 0)
	if Input.is_action_just_pressed("slot2"):
		rpc("change_tool", 1)
	if Input.is_action_just_pressed("slot3"):
		rpc("change_tool", 2)
	if Input.is_action_just_pressed("left_click"):
		rpc("throw")
	if Input.is_action_just_pressed("kill"):
		damage(20)
	if Input.is_action_just_pressed("uncade"):
		if (currentTool is Hammer):
			currentTool.rpc("uncade",int(str(self.name)))
		
	if Input.is_action_pressed("alt"):
		#sa
		rotating = true
	else:
		rotating = false
	if Input.is_action_just_pressed("shift"):
		last_pos = hold_position.global_position
		rpc("set_last_pos", hold_position.global_position)
	if Input.is_action_pressed("shift"):
		shift = true
	else:
		shift = false
	if Input.is_action_just_pressed("drop"):
		if currentTool:
			var toolToDrop = currentTool.get_path()
			rpc("dropTool", toolToDrop)
	#view and rotation
	if (!rotating or !held_object):
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
	if event is InputEventMouseMotion:
		mouse_input = event.relative;
		if rotating:
			rpc("send_input", mouse_input)

func set_ui():
	ui.set_health(health)
	ui.emit_signal("set", points)
	ui.set_wave(game_manager.state, game_manager.wave, game_manager.timer.time_left)
	ui.set_hurt(hurt)
	if (isTeleporting):
		ui.sigilProgress.visible = true
		ui.set_sigil(100-(int(float(teleportTimer.time_left) / float(3) * 100)), currentSigil.letter.text)
	else:
		ui.sigilProgress.visible = false

func find_current_sigil():
	var sigils = Utils.world.level.get_sigils().get_children()
	var rot: Vector3 = _raycast.global_rotation
	var pos: Vector3 = _raycast.global_position
	var dist = 9999999999
	var aim = _raycast.get_global_transform().basis
	var forward = -aim.z
	for s in sigils:
		var d: float = s.global_position.distance_to(_raycast.global_position)
		if d<dist:
			dist = d
			currentSigil = s
			
	dist = -1
	
	for s in sigils:
		if s==currentSigil: continue
		var spos = s.global_position - _raycast.global_position
		var d = spos.dot(forward)
		if d>dist:
			dist = d
			currentSigil = s
	
	if (selectedSigil):
		if (pos.distance_to(selectedSigil.global_position)>=7):
			isTeleporting = false
			selectedSigil = null
@rpc("any_peer", "call_local")
func change_tool(s):

	if (s>=tools.size()):
		return
	if (currentTool):
		currentTool.unhold()
	currentSlot = s
	currentTool = tools[s]
	currentTool.hold()

@rpc("call_local", "any_peer")
func set_last_pos(pos):
	if multiplayer.is_server():
		last_pos = pos

@rpc("call_local", "any_peer")
func throw():
	if (held_object):
		var dir:Vector3 = hold_position.global_position - camera.global_position
		var dist:float = dir.length()
		held_object.apply_central_impulse(dir*dist*3)
		held_object.hold = false
		held_object=null
		rotating = false

@rpc("any_peer", "call_local")
func interact():
	if (held_object):
		held_object.hold = false
		held_object = null
		rotating = false
		last_pos = hold_position.global_position
		return
	if (!_raycast.get_collider()):
		return
	if _raycast.get_collider().is_in_group("prop"):
		if (!_raycast.get_collider().hold and !_raycast.get_collider().caded):
			held_object = _raycast.get_collider()
			held_object.hold = true
			last_pos = hold_position.global_position
	elif _raycast.get_collider() is Tool:
		var t:Tool = _raycast.get_collider() as Tool
		if (t.pickuped): return
		pick_up(t)
	elif _raycast.get_collider() is Sigil:
		teleportTimer.start(3)
		selectedSigil = _raycast.get_collider() as Sigil
		isTeleporting = true

func damage(d):
	health-=d
	health = round(health)
	hurt+=d
	if d > 0:
		Utils.world.rpc("create_blood",d, global_position)

func pick_up(t: Tool):
	if (tools.size() >= 3):
		return
	t.unhold()
	t.setOwner(int(str(self.name)))
	t.pickuped = true
	tools.push_back(t)

@rpc("any_peer")
func send_input(mi):
	mouse_input = mi

@rpc("any_peer", "call_local")
func kill():
	ui.set_health(health)
	Utils.world.rpc("create_blood",20, global_position)
	Utils.world.kill_player(int(str(name)))
	rpc("dropAllTools")
	tools.clear()
	ui.dead()
	if held_object:
		held_object.hold = false
	held_object = null
	if (multiplayer.is_server()):
		Utils.respawn(int(str(name)), Utils.WHO.ZOMBIE, 5)

@rpc("any_peer", "call_local")
func dropTool(t: NodePath):
	if (!t): return
	var tl = get_node(t)
	if (!tl): return
	var pOwner = Utils.world.get_player_by_id(tl.pOwnerId)
	if (!pOwner): return
	if (pOwner.currentTool == tl):
		pOwner.currentTool = null
	tl.global_position = pOwner.hand.global_position
	tl.resetOwner()
	tl.hold()
	tl.drop()
	tl.pickuped = false
	tools.erase(tl)
	
@rpc("any_peer", "call_local")
func dropAllTools():
	for tl in tools:
		tl.global_position = hand.global_position
		tl.resetOwner()
		tl.hold()
		tl.drop()
		tl.pickuped = false
	tools.clear()
	
	
@rpc("call_local", "any_peer")
func play_use_effects():
	anim_player.stop()
	anim_player.play("use")
	pass

func shoot_effects():
	rpc("play_shoot_effects")

@rpc("call_local", "any_peer")
func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")
	pass

func _on_teleport_timer_timeout():
	if !isTeleporting: return
	Utils.world.rpc("teleport", int(str(self.name)), currentSigil.global_position.x,currentSigil.global_position.y,currentSigil.global_position.z)
	isTeleporting = false
	selectedSigil = null


func _on_body_entered(body):
	if (!multiplayer.is_server()): return
	if body is Prop:
		if body.hold or body.caded: return
		var dmg = abs(body.mass*body.linear_velocity.x*body.linear_velocity.y*propDamageMult)
		print(dmg)
		if dmg>10:
			damage(dmg)
