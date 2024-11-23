extends Node3D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var projectile: PackedScene = preload("res://Scenes/Towers/yarn_ball.tscn")
@onready var initYarn: MeshInstance3D = $"siege-catapult2/siege-catapult/catapult/YarnMesh"
@onready var initYarnPos: Node3D = $"siege-catapult2/siege-catapult/catapult/YarnMesh/Node3D"

var velocityX: float = 20.0

func _ready() -> void:
	while(true):
		shoot(Vector3(3, 0, 10))
		await animationPlayer.animation_finished
		await animationPlayer.animation_finished

func _process(delta: float) -> void:
	pass

func shoot(targetPos: Vector3):
	#projectile.instantiate()
	animationPlayer.play("Fire")
	await animationPlayer.animation_finished
	
	var launchPos = initYarn.global_transform.origin
	var displacement = targetPos - launchPos

	var horizontal_distance = Vector3(displacement.x, 0, displacement.z).length()
	#print(horizontal_distance)
	var y_displacement = initYarn.global_position.y
	
	var time = horizontal_distance / velocityX
	var velocityY = ((9.8/2 * time * time) - launchPos.y) / time
	
	var local_velocity = Vector3(velocityX, velocityY, 0)
	var global_velocity = global_transform.basis * local_velocity
	#print(local_velocity)
	var launched = projectile.instantiate()
	#launched.global_transform.origin = launchPos
	launched.global_transform.origin = Vector3(launchPos.x - 2.7, launchPos.y + 0.46, launchPos.z + 0.55)
	#print(Vector3(launchPos.x - 2, launchPos.y + 1, launchPos.z + 0.581921))
	initYarn.visible = false
	add_child(launched)
	
	launched.linear_velocity = global_velocity
	#launched.mass = 0
	
	animationPlayer.play("Reload")
