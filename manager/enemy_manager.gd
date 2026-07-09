class_name EnemyManager
extends Node

signal round_changed(round_number: int)

const ROUND_BASE_TIME: int = 10
const ROUND_GROWTH: int = 5
const BASE_ENEMY_SPAWN_TIME: float = 2
const ENEMY_SPAWN_TIME_GROWTH: float = -0.15

# Tool manager for enemy
# -----------Name-----------Type----#
@export var enemy_scene: PackedScene 
@export var enemy_sapwn_root: Node
@export var spawn_rect: ReferenceRect

@onready var spawn_interval_timer: Timer = $SpawnIntervalTimer
@onready var round_timer: Timer = $RoundTimer

var _round_count: int
var round_count: int:
	get:
		return _round_count
	set(value):
		_round_count = value
		round_changed.emit(_round_count)
			
var spawned_enemies: int 


func _ready() -> void:
	spawn_interval_timer.timeout.connect(_on_spawn_interval_timer_timeout)
	round_timer.timeout.connect(_on_round_timer_timeout)
	GameEvents.enemy_died.connect(_on_enemy_died)
	
	if is_multiplayer_authority():
		begin_round()


func synchronize(to_peer_id = -1):
	if !is_multiplayer_authority():
		return
	
	var data = {
		"round_timer_is_running": !round_timer.is_stopped(),
		"round_timer_time_left": round_timer.time_left,
		"round_count": round_count
	}
	
	if to_peer_id > -1 && to_peer_id !=1:
		_synchronize.rpc_id(to_peer_id, data)
	else:
		_synchronize.rpc(data)
	
	_synchronize.rpc(data)

@rpc("authority", "call_remote", "reliable")
func _synchronize(data: Dictionary): # the "_" treat this as private/internal
	var wait_time: float = data["round_timer_time_left"]
	if wait_time > 0:
		round_timer.wait_time = wait_time
	if data["round_timer_is_running"]:
		round_timer.start()
	round_count = data["round_count"]

func get_round_time_remaining() -> float:
	return round_timer.time_left


func begin_round():
	round_count += 1
	round_timer.wait_time = ROUND_BASE_TIME + ((round_count - 1) * ROUND_GROWTH) #The - 1 is just shifting so the growth starts /counting from zero instead of one.
	round_timer.start()
	
	spawn_interval_timer.wait_time = BASE_ENEMY_SPAWN_TIME + ((round_count -1) * ENEMY_SPAWN_TIME_GROWTH)
	spawn_interval_timer.start()
	
	synchronize()
	
func check_round_completed():
	if !round_timer.is_stopped():
		return
		
	if spawned_enemies == 0:
		print('Round Completed')
		begin_round()
	
func get_random_spawn_poaition() -> Vector2:
	var x = randf_range(0, spawn_rect.size.x) # gets from random rect size (0,0) to (0,412)
	var y = randf_range(0, spawn_rect.size.y) # gets from random rect size (0,0) to (216,0)
	
	return spawn_rect.global_position + Vector2(x, y) # return sums random vector to the global psotion, hence random spawn


func spawn_enemy():
	var enemy = enemy_scene.instantiate() as Node2D # builds instance, not in tree yet (no _ready, no movement)
	enemy.global_position = get_random_spawn_poaition() # set position before adding, so it doesn't pop in at (0,0)
	enemy_sapwn_root.add_child(enemy, true) # activates node — LOCAL ONLY, doesn't replicate to clients
	spawned_enemies += 1

func _on_spawn_interval_timer_timeout():
	if is_multiplayer_authority():
		spawn_enemy()
		spawn_interval_timer.start()


func _on_round_timer_timeout():
	if is_multiplayer_authority():
		spawn_interval_timer.stop()
		check_round_completed()
		print("round over")
		
		
func _on_enemy_died():
	spawned_enemies -= 1
	check_round_completed()
