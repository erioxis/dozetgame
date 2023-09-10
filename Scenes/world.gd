extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_enter = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEnter
@onready var name_enter = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/NameEnter
@onready var game_manager = $GameManager
@onready var level = $Level

@onready var auth_menu = $CanvasLayer/AuthMenu
@onready var login_enter = $CanvasLayer/AuthMenu/MarginContainer/VBoxContainer/LoginEnter
@onready var pass_enter = $CanvasLayer/AuthMenu/MarginContainer/VBoxContainer/PassEnter
@onready var user_name_enter = $CanvasLayer/AuthMenu/MarginContainer/VBoxContainer/UserNameEnter
@onready var reg_button = $CanvasLayer/AuthMenu/MarginContainer/VBoxContainer/RegButton

@onready var error_label = $CanvasLayer/AuthMenu/MarginContainer/VBoxContainer/Error

const KEY := "nakama_dozet_server"

const alph = ['A', 'B', 'C']

var bloodexp = preload("res://Scenes/blood_explosion.tscn")

const Player = preload("res://Scenes/player.tscn")
const Zombie = preload("res://Scenes/zombie.tscn")
const Bullet = preload("res://Scenes/bullet.tscn")
const PORT = 3120
var client = Nakama.create_client(KEY, "127.0.0.1", 7350, "http")
var device_id = OS.get_unique_id()
var session
var socket
var multiplayer_bridge : NakamaMultiplayerBridge

func _ready():
	Steam.steamInit()
		
	client.timeout = 10

	Utils.world = self
	init_sigils()

func _physics_process(delta):
	if (user_name_enter.text == ""):
		reg_button.disabled = true
		return
	if (login_enter.text == ""):
		reg_button.disabled = true
		return
	if (pass_enter.text == "" or pass_enter.text.length() < 8):
		reg_button.disabled = true
		return
	reg_button.disabled = false

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_host_button_pressed():
	Utils.nickname = Steam.getFriendPersonaName(Steam.getSteamID())
	main_menu.hide()
	
	await multiplayer_bridge.create_match()
	get_tree().get_multiplayer().peer_connected.connect(self.add_player)
	get_tree().get_multiplayer().peer_disconnected.connect(self.remove_player)
	
	add_player(multiplayer.get_unique_id())
	game_manager.start_round()

func _on_join_button_pressed():
	Utils.nickname = Steam.getFriendPersonaName(Steam.getSteamID())
	main_menu.hide()
	
	#enet_peer.create_client(address_enter.text, PORT)
	#multiplayer.multiplayer_peer = enet_peer
	multiplayer_bridge.join_match(address_enter.text)

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	var sigils = level.get_sigils().get_children()
	var random_sigil = randi() % level.get_sigils().get_child_count()
	add_child(player)
	teleport(player.name, sigils[random_sigil].global_position.x, sigils[random_sigil].global_position.y, sigils[random_sigil].global_position.z)
	game_manager.rpc_id(peer_id,"set_round_info", game_manager.state, game_manager.wave, game_manager.timer.time_left)
	print("Player "+str(peer_id)+" is connected")

@rpc("any_peer","call_local")
func create_blood(n, pos):
	var blood = bloodexp.instantiate()
	add_child(blood, true)
	blood.global_position = pos
	blood.boom(n)
	
func init_sigils():
	var sigils = level.get_sigils().get_children()
	for s in sigils.size():
		sigils[s].set_letter(alph[s])
	
	
func remove_player(peer_id):
	var player = get_player_by_id(peer_id)
	if player:
		create_blood(15, player.global_position)
		player.queue_free()
		if (player is Player):
			player.dropAllTools()
	print("Player "+str(peer_id)+" has removed")
	
func kill_player(peer_id):
	var player = get_player_by_id(int(str(peer_id)))
	if player:
		player.queue_free()
	print("Player "+str(peer_id)+" died")
	
func zombificate(peer_id):
	var zombie = Zombie.instantiate()
	zombie.name = str(peer_id)
	add_child(zombie)
	
	game_manager.rpc_id(peer_id,"set_round_info", game_manager.state, game_manager.wave, game_manager.timer.time_left)
	
func get_player_by_id(id: int):
	return get_node_or_null(str(id))


@rpc("call_local", "any_peer")
func teleport(id, x, y, z):
	get_player_by_id(int(str(id))).global_position = Vector3(x,y,z)
	
@rpc("call_local", "any_peer")
func create_bullet(pos, rot, o, damage, l):
	if multiplayer.is_server():
		var bullet = Bullet.instantiate()
		add_child(bullet, true)
		bullet.rpc("init",pos, rot, o, damage, l)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
		
	var _map_result = upnp.add_port_mapping(PORT)
	
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)
		
	print("Success! Join Address: %s" % upnp.query_external_address())


func _on_reg_button_pressed():
	session = await client.authenticate_email_async(login_enter.text, pass_enter.text, user_name_enter.text, true)
	if session.is_exception():
		error_label.text = str(session.exception.message)
		return
	main_menu.show()
	auth_menu.hide()
	init_sockets()


func _on_log_button_pressed():
	session = await client.authenticate_email_async(login_enter.text, pass_enter.text, user_name_enter.text, false)
	if session.is_exception():
		error_label.text = str(session.exception.message)
		return
	main_menu.show()
	auth_menu.hide()
	init_sockets()

	
func init_sockets():
	socket = Nakama.create_socket_from(client)
	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	print("Socket connected.")
	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	multiplayer_bridge.match_join_error.connect(self._on_match_join_error)
	multiplayer_bridge.match_joined.connect(self._on_match_join)
	get_tree().get_multiplayer().set_multiplayer_peer(multiplayer_bridge.multiplayer_peer)

func _on_match_join_error(error):
	print ("Unable to join match: ", error.message)

func _on_match_join() -> void:
	print ("Joined match with id: ", multiplayer_bridge.match_id)
