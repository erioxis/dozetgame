extends CharacterBody3D

class_name Player

@onready var camera = $Camera3D
@onready var _raycast = $Camera3D/RayCast
@onready var _label = $Label3D
@onready var body = $body
@onready var ui = $player_ui
@onready var hand = $Camera3D/hand

@onready var anim_player = $AnimationPlayer

var bloodexp = preload("res://Scenes/blood_explosion.tscn")

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

var dead: bool
var held_object: RigidBody3D
var points:int = 15
var health:float = 100

var tool : Object
var world

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	dead = false
	world = get_tree().get_root().get_node("World")
	
	if not is_multiplayer_authority():
		ui.hide()
		return

	body.visible = false
	_label.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	camera.current = true
	
	set_username(OS.get_environment("USERNAME"))

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if Input.is_action_just_pressed("left_click"):
		if (tool):
			tool.use()
		rpc("play_shoot_effects")

func _physics_process(delta):

	if not is_multiplayer_authority(): return
	# Add the gravity.
	ui.set_health(health)
	ui.emit_signal("set", points)
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")
		
	if (health<=0 and dead==false):
		rpc("kill")
		dead = true

	move_and_slide()

@rpc("any_peer","call_local","reliable")
func set_tool(t: Resource):
	if (tool):
		tool.queue_free()
	tool = t.instantiate()
	hand.add_child(tool,true)

@rpc("any_peer")
func damage(d):
	health-=d
	world.create_blood(d, global_position)

@rpc("any_peer", "call_local")
func kill():
	world.create_blood(20, global_position)
	world.kill_player(name)
	
@rpc("call_local")
func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")

func set_username(n):
	_label.text = n
