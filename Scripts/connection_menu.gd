extends Control
@onready var host_button: Button = $MainMenu/MarginContainer/VBoxContainer/Host
@onready var join_button: Button = $MainMenu/MarginContainer/VBoxContainer/Join

const PORT = 1692
var enet_peer = ENetMultiplayerPeer.new()

const PlayerScene = preload("res://Scenes/Player/rufus.tscn")
@onready var main_menu: PanelContainer = $MainMenu
@onready var room_code_label: Label = $RoomCodeLabel
@onready var address: LineEdit = $MainMenu/MarginContainer/VBoxContainer/Address
@onready var card_board: TDCardBoard = $"../CardBoard"

var level : Node2D
@onready var internet_timeout: Timer = $InternetTimeout
var times_ticked : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thread = Thread.new()
	thread.start(_upnp_setup.bind(PORT))
	
	upnp_completed.connect(func(a): 
		print(a)
		if(a == OK):
			print("UPNP SUCCESS")
	)
	
	host_button.pressed.connect(host_pressed)
	join_button.pressed.connect(join_pressed)
	level = get_tree().root.get_node("level")
	print("Addresses: ", IP.get_local_addresses())
	pass # Replace with function body.

#https://forum.godotengine.org/t/how-to-get-local-ip-address/10399/2
func get_ip() -> String:
	var ip_address = "ERROR GETTING IP ADDRESS"
	if(upnp and upnp.get_device_count() > 0):
		ip_address = upnp.query_external_address()
	else:
		printerr("UPNP Error")
	print("Qry ext add ",upnp.query_external_address())
	return ip_address

func update_join_label():
	join_button.text = "Connecting... " + str(30 - times_ticked)
	times_ticked += 1
	print(enet_peer.get_connection_status())
	pass
	
func host_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	var local_ip = Hexifier.hexify_ip(get_ip())
	
	room_code_label.text += "HOST - " +local_ip
	room_code_label.show()
	add_player(multiplayer.get_unique_id())
	pass

func join_pressed():
	print(enet_peer.get_connection_status())
	
	join_button.text = "Connecting... 31"# + str(enet_peer.timeout)
	var pre_unhex_code = address.text.to_upper()
	var address_code = Hexifier.unhexify(pre_unhex_code)
	
	@warning_ignore("integer_division")
	room_code_label.text += "CLIENT - " + pre_unhex_code if pre_unhex_code.contains("-") else pre_unhex_code.insert(pre_unhex_code.length()/2, "-")
	enet_peer.create_client(address_code, PORT)
	internet_timeout.timeout.connect(update_join_label)
	internet_timeout.start()
	
	
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.connected_to_server.connect(
		func(): 
			print("Connected")
			join_button.text = "Connected!"
			internet_timeout.stop()
			room_code_label.show()
			get_tree().create_timer(0.5).timeout.connect(hide)
			)
	multiplayer.connection_failed.connect(
		func(): 
			enet_peer.close()
			printerr("Failed to connect")
			join_button.text = "Failed to Connect. Try again?"
			internet_timeout.stop()
			times_ticked = 0
			)
	pass

func add_player(peer_id):
	var player = PlayerScene.instantiate()
	player.player_id = peer_id
	player.name = str(peer_id)
	$"../../Rufuses".add_child(player)
	
	print(peer_id)
	if(peer_id == 1):
		player.modulate = Color.GREEN
	GameManager.Rufuses.append(player)
	#card_board.active_rufus = player
	#card_board.show()

func remove_player(peer_id):
	for rufus in GameManager.Rufuses:
		if rufus.player_id == peer_id:
			GameManager.Rufuses.erase(rufus)
			rufus.queue_free()


# Emitted when UPnP port mapping setup is completed (regardless of success or failure).
signal upnp_completed(error)

# Replace this with your own server port number between 1024 and 65535.
var thread = null

var upnp = UPNP.new()
func _upnp_setup(server_port):
	# UPNP queries take some time.
	var err = upnp.discover()
	print("Discover local port ",upnp.discover_local_port)
	if err != UPNP.UPNP_RESULT_SUCCESS:
		push_error(str(err))
		upnp_completed.emit(err)
		if(err == upnp.UPNP_RESULT_NO_DEVICES):
			print("NO DEVICES")
		return
	print("Device count: ", upnp.get_device_count())
	#upnp.add_port_mapping(PORT)
	print("Gateway: ", upnp.get_gateway())
	#print("Valid Gateway: %s", upnp.get_gateway().is_valid_gateway())

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		print("IT PASSED THE CHECK!!")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		upnp_completed.emit.call_deferred(OK)

func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	thread.wait_to_finish()
