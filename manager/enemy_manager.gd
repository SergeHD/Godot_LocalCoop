extends Node

const ROUND_BASE_TIME: int = 10
const ROUND_GROWTH: int = 5
const BASE_ENEMY_SPAWN_TIME: float = 2
const ENEMY_SPAWN_TIME_GROWTH: float = -0.15

# Toll manager for enemy
# -----------Name-----------Type----#
@export var enemy_scene: PackedScene
@export var enemy_sapwn_root: Node
@export var spawn_rect: ReferenceRect

@onready var spawn_interval_timer: Timer = $SpawnIntervalTimer
@onready var round_timer: Timer = $RoundTimer

var round_count: int = 0


func _ready() -> void:
	spawn_interval_timer.timeout.connect(_on_spawn_interval_timer_timeout)
	round_timer.timeout.connect(_on_round_timer_timeout)
	
	
func begin_round():
	round_count += 1
	round_timer.wait_time = ROUND_BASE_TIME + ((round_count - 1) * ROUND_GROWTH)
	
	
func get_random_spawn_poaition() -> Vector2:
	var x = randi_range(0, spawn_rect.size.x) # gets from random rect size (0,0) to (0,412)
	var y = randi_range(0, spawn_rect.size.y) # gets from random rect size (0,0) to (216,0)
	
	return spawn_rect.global_position + Vector2(x, y) # return sums random vector to the global psotion, hence random spawn


func spawn_enemy():
	var enemy = enemy_scene.instantiate() as Node2D # builds instance, not in tree yet (no _ready, no movement)
	enemy.global_position = get_random_spawn_poaition() # set position before adding, so it doesn't pop in at (0,0)
	enemy_sapwn_root.add_child(enemy, true) # activates node — LOCAL ONLY, doesn't replicate to clients


func _on_spawn_interval_timer_timeout():
	if is_multiplayer_authority():
		spawn_enemy()


func _on_round_timer_timeout():
	pass
