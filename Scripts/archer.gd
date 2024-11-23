extends Node3D

@onready var projectile: PackedScene = preload("res://Scenes/Towers/arrow.tscn")

var arrowVelocity = 50.0

func _ready() -> void:
	shoot(Vector3(0, 0, 10))

func shoot(targetPos: Vector3):
	
	var launchPos = global_transform.origin
	var displacement = targetPos - launchPos

	var x_displacement = Vector3(displacement.x, 0, displacement.z).length()
	var y_displacement = global_position.y
	
	var angle = atan(y_displacement / x_displacement)
	var velocityX = arrowVelocity * cos(angle)
	var velocityY = arrowVelocity * sin(angle)
	
	var local_velocity = Vector3(velocityX, velocityY, 0)
	var global_velocity = global_transform.basis * local_velocity
	
	var launched = projectile.instantiate()
	launched.global_transform.origin = launchPos
	add_child(launched)
	
	launched.linear_velocity = global_velocity
