extends Node3D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var projectile: PackedScene = preload("res://Scenes/Towers/yarn_ball.tscn")
@onready var initYarn: Node3D = $Yarn
@onready var reload_timer = $ReloadTimer

var velocityX: float = 20.0
var loaded: bool = true
var target: Node3D

func _ready() -> void:
	while(true):
		shoot(Vector3(3, 0, 10))
		await animationPlayer.animation_finished
		await animationPlayer.animation_finished

func _process(_delta):
	#if loaded:
		#shoot(target.global_position)
	pass

func shoot(targetPos: Vector3):
	#projectile.instantiate()
	animationPlayer.play("Fire")
	await animationPlayer.animation_finished
	
	var launchPos = initYarn.global_position
	var displacement = targetPos - launchPos

	var horizontal_distance = sqrt(ceilf(displacement.x) * ceilf(displacement.x) + ceilf(displacement.z) * ceilf(displacement.z))
	var y_displacement = initYarn.global_position.y
	
	var time = horizontal_distance / velocityX
	var velocityY = (displacement.y + (9.8/2 * time * time)) / time

	var local_velocity = Vector3(velocityX, velocityY, 0)
	var global_velocity = global_transform.basis * local_velocity

	var launched = projectile.instantiate()
	initYarn.visible = false
	add_child(launched)
	
	launched.global_position = initYarn.global_position

	launched.linear_velocity = global_velocity
	
	loaded = false
	reload_timer.start()
	
	animationPlayer.play("Reload")


func _on_reload() -> void:
	loaded = true
