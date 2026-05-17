class_name Bullet
extends Node2D

const SPEED: int = 600 # pixels per second

var direction: Vector2


func _process(delta: float):
	global_position += direction * SPEED * delta # moves at the exact same speed regardless of the player's hardware.


func start(direction: Vector2):
	self.direction = direction
