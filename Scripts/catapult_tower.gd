extends Node3D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var projectile: PackedScene = preload("res://Scenes/Towers/yarn_ball.tscn")
@onready var initYarn: MeshInstance3D = $"siege-catapult2/siege-catapult/catapult/YarnMesh"

var velocityX: float = 40.0

func _ready() -> void:
	shoot(Vector3(3, 0, 30))

func _process(delta: float) -> void:
	pass

func shoot(targetPos: Vector3):
	animationPlayer.play("Fire")
	
	var launchPos = initYarn.global_transform.origin
	var displacement = targetPos - launchPos
	
	var horizontal_distance = Vector3(displacement.x, 0, displacement.z).length()
	var y_displacement = initYarn.global_position.y
	
	var time = horizontal_distance / velocityX
	var velocityY = (launchPos.y + 9.8/2 * time * time) / time
	
	var local_velocity = Vector3(velocityX, velocityY, 0)
	var global_velocity = global_transform.basis * local_velocity
	
	await animationPlayer.animation_finished
	print(local_velocity)
	var launched = projectile.instantiate()
	launched.global_transform.origin = launchPos
	add_child(launched)
	
	launched.linear_velocity = global_velocity
