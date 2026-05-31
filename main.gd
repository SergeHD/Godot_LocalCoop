extends Node

var player_scene: PackedScene = preload("uid://cooq3ldg1a88u")
var enemy_scene: PackedScene = preload("uid://ddh5hb3k1eaev")

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


func _ready():
	multiplayer_spawner.spawn_function = func(data):
		var player = player_scene.instantiate() as Player
		player.name = str(data.peer_id)
		player.input_multiplayer_authority = data.peer_id
		return player

	peer_ready.rpc_id(1)
	 
	if is_multiplayer_authority(): 
		var enemy = enemy_scene.instantiate() as Node2D # hard coding enemt instaiate for better despawn on client side
		enemy.global_position = Vector2.ONE * 100
		add_child(enemy) #adding it to the root scene
		# enemies global positions is not synced, add multiplayer synchronizer to the enemy node 

@rpc("any_peer", "call_local", "reliable")
func peer_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({ "peer_id": sender_id })
