extends Control

const PORT: int = 3000

#Godot uid(Path) came from right click scene
var main_scene: PackedScene = preload("uid://b1guvxe0n0cop")

@onready var host_button: Button = $HBoxContainer/HostButton
@onready var join_button: Button = $HBoxContainer/JoinButton

func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)

	
# HOST — scene changes immediately because the server is already "connected" to itself
func _on_host_pressed() -> void:
	var server_peer := ENetMultiplayerPeer.new()   # This means its creating server_peer type ENENetMultiplayerPeer
	server_peer.create_server(PORT)                # Also Server_peer: type = type.new
	multiplayer.multiplayer_peer = server_peer 
	get_tree().change_scene_to_packed(main_scene)
	
	
func _on_join_pressed() -> void:
	var client_peer := ENetMultiplayerPeer.new() 
	client_peer.create_client("169.254.83.107",PORT) #IP/UDP to connect to Host ← handshake 
	multiplayer.multiplayer_peer = client_peer
	# ← no scene change here, just waits... 
	#  Can't change scene immediately, must WAIT for handshake with server


func _on_connected_to_server():  # ← fires once handshake completes
	get_tree().change_scene_to_packed(main_scene) # THEN changes scene
	# ← handshake is DONE, now it's safe to switch scenes
