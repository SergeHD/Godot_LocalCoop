extends Node

@export var enemy_scene: PackedScene

@onready var spawn_interval_timer: Timer = $SpawnIntervalTimer

func _ready() -> void:
	spawn_interval_timer.timeout.connect(spawn_interval_timer_timeout)
	

func spawn_enemy():
	pass


func spawn_interval_timer_timeout():
	spawn_enemy()
