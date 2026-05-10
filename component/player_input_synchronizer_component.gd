# WHAT IS BEING ASKED TO DO (INPUTS THAT ARE BEING SYNC)
class_name PlayerInputSynchronizerComponent
extends MultiplayerSynchronizer


@export var aim_root: Node2D # Assigning aiming reference point (WeaponRoot)
var movement_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.RIGHT # Non 0,0 starting point, for aiming can't never be centered


func _process(_delta: float):
	if is_multiplayer_authority():
		gather_input()
		
		
func gather_input():
	movement_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	aim_vector = aim_root.global_position.direction_to(aim_root.get_global_mouse_position())
