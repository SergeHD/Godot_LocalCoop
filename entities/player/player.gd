# Synced Outputs and Game logic
class_name Player
extends CharacterBody2D

@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent  = $PlayerInputSynchronizerComponent
@onready var weapon_root: Node2D = $Visuals/WeaponRoot
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var barrel_position: Marker2D = %BarrelPosition


var bullet_scene: PackedScene = preload("res://entities/bullet/bullet.tscn")
var flash_muzzle_scene: PackedScene = preload("uid://dqlqfjemq5wxi")
var input_multiplayer_authority: int


func _ready():
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)
	health_component.died.connect(_on_died)


func _process(_delta: float) -> void:
	update_aim_position()
	if is_multiplayer_authority(): # if in server. Anything game-critical should happen here - THE SERVER
		velocity = player_input_synchronizer_component.movement_vector * 100
		move_and_slide()
		if player_input_synchronizer_component.is_attack_pressed:
			try_fire()


func update_aim_position():
	var aim_vector = player_input_synchronizer_component.aim_vector
	var aim_position = weapon_root.global_position + aim_vector
	visuals.scale = Vector2.ONE if aim_vector.x >= 0 else Vector2(-1, 1)
	weapon_root.look_at(aim_position) #Rotates the node so that its local +X axis points towards the point


func try_fire():
	if !fire_rate_timer.is_stopped():
		return
		
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.global_position = barrel_position.global_position
	bullet.start(player_input_synchronizer_component.aim_vector)
	get_parent().add_child(bullet, true) # making bullet a parent so it can act independently in the scene
	fire_rate_timer.start()
	
	play_fire_effects.rpc()


@rpc("authority", "call_local", "unreliable")
func play_fire_effects():
	if animation_player.is_playing():
		animation_player.stop() # animation stops and goes to starting position
	animation_player.play("fire")
	
	var muzzle_flash: Node2D = flash_muzzle_scene.instantiate()
	muzzle_flash.global_position = barrel_position.global_position # getting parent node (weapon root psotion)
	muzzle_flash.global_rotation = barrel_position.global_rotation  
	get_parent().add_child(muzzle_flash)


func _on_died():
	print("Player Died")
