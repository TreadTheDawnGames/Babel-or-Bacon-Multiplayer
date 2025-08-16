extends Control
@onready var host_button: Button = $MainMenu/MarginContainer/VBoxContainer/Host
@onready var join: Button = $MainMenu/MarginContainer/VBoxContainer/Join

const PORT = 1692
var enet_peer = ENetMultiplayerPeer.new()

const PlayerScene = preload("res://Scenes/Player/rufus.tscn")
@onready var main_menu: PanelContainer = $MainMenu
@onready var room_code_label: Label = $RoomCodeLabel
@onready var address: LineEdit = $MainMenu/MarginContainer/VBoxContainer/Address
@onready var card_board: TDCardBoard = $"../CardBoard"

var level : Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	host_button.pressed.connect(host_pressed)
	join.pressed.connect(join_pressed)
	level = get_tree().root.get_node("level")
	pass # Replace with function body.

#https://forum.godotengine.org/t/how-to-get-local-ip-address/10399/2
func get_ip() -> String:
	var ip_adress :String
	if OS.has_feature("windows"): #Windows
		if OS.has_environment("COMPUTERNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),IP.TYPE_IPV4)
	elif OS.has_feature("x11"): #Linux
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),IP.TYPE_IPV4)
	elif OS.has_feature("OSX"): #Mac
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),IP.TYPE_IPV4)
	return ip_adress

func host_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	var local_ip = hexify_ip(get_ip())
	
	room_code_label.text += "HOST - " +local_ip
	room_code_label.show()
	add_player(multiplayer.get_unique_id())
	pass
	
	
func join_pressed():
	main_menu.hide()
	room_code_label.show()
	
	var pre_unhex_code = address.text.to_upper()
	var address_code = unhexify(pre_unhex_code)
	
	@warning_ignore("integer_division")
	room_code_label.text += "CLIENT - " + pre_unhex_code if pre_unhex_code.contains("-") else pre_unhex_code.insert(pre_unhex_code.length()/2, "-")
	enet_peer.create_client(address_code, PORT)
	multiplayer.multiplayer_peer = enet_peer
	
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

func hexify_ip(ip : String) -> String:
	var result : String = ""
	
	var split_ip := ip.split(".")
	if(split_ip.size() > 4):
		printerr("Error colorizing IP: too many '.'s")
	var ip_ints = [0,0,0,0]
	var i = 0
	for num in split_ip:
		ip_ints[i] = int(num)
		i+=1
	
	for num in ip_ints:
		result += hexify(num)
	
	@warning_ignore("integer_division")
	result = result.insert(result.length()/2, "-")
	
	return result

func hexify(num : int) -> String:
	var hex_string =  "%2X".to_upper() % num
	
	var replaced : String = hex_string
	for i in 10:
		match i:
			0: 
				replaced = replaced.replace(str(i), "G")
			1: 
				replaced = replaced.replace(str(i), "H")
			2: 
				replaced = replaced.replace(str(i), "I")
			3: 
				replaced = replaced.replace(str(i), "J")
			4: 
				replaced = replaced.replace(str(i), "K")
			5: 
				replaced = replaced.replace(str(i), "L")
			6: 
				replaced = replaced.replace(str(i), "M")
			7: 
				replaced = replaced.replace(str(i), "N")
			8: 
				replaced = replaced.replace(str(i), "O")
			9: 
				replaced = replaced.replace(str(i), "P")
	
	return replaced

func unhexify(hex : String) -> String:
	
	var replaced : String = hex.replace("-", "")
	for i in 10:
		match i:
			0: 
				replaced = replaced.replace("G", str(i))
			1: 
				replaced = replaced.replace("H", str(i))
			2: 
				replaced = replaced.replace("I", str(i))
			3: 
				replaced = replaced.replace("J", str(i))
			4: 
				replaced = replaced.replace("K", str(i))
			5: 
				replaced = replaced.replace("L", str(i))
			6: 
				replaced = replaced.replace("M", str(i))
			7: 
				replaced = replaced.replace("N", str(i))
			8: 
				replaced = replaced.replace("O", str(i))
			9: 
				replaced = replaced.replace("P", str(i))
	
	var ip_strs = ["","","",""]
	var i = 0
	for strs in ip_strs:
		ip_strs[i] = replaced.substr(0,2)
		replaced = replaced.erase(0,2)
		i+=1
		print(strs)
	
	var out_str = ""
	for strs in ip_strs:
		out_str += str(strs.hex_to_int()) + "."
	
	out_str = out_str.erase(out_str.length()-1)
	
	return out_str
