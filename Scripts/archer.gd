extends Node3D

@onready var projectile: PackedScene = preload("res://Scenes/Towers/arrow.tscn")
@onready var los: Area3D = $LOS
@onready var reload_timer = $ReloadTimer

var arrowVelocity = 20
var loaded: bool = true
var target: Node3D

func _ready():
	
	pass
	
func _process(_delta):
	#if loaded:
		#shoot(Vector3(3,0.5,0))
	if loaded and target:
		shoot(target.global_position)
	
func shoot(targetPos: Vector3):
	look_at(targetPos)
	#global_rotation.y += PI/2
	var launchPos = global_transform.origin
	#var displacement = targetPos - launchPos
#
	#var x_displacement = Vector3(displacement.x, 0, displacement.z).length()
	#var y_displacement = global_position.y
		#
	#var angle = atan(y_displacement / x_displacement)
	#var velocityX = arrowVelocity * cos(angle)
	#var velocityY = arrowVelocity * sin(angle)
		#
	#var local_velocity = Vector3(velocityX, velocityY, 0)
	#var global_velocity = global_transform.basis * local_velocity
		
	var launched = projectile.instantiate()
	add_child(launched)
	launched.global_transform.origin = launchPos
	launched.global_rotation = global_rotation
	launched.visible = true
		
	launched.linear_velocity = -global_transform.basis.z.normalized() * arrowVelocity
	loaded = false
	reload_timer.start()

func _on_reload() -> void:
	loaded = true

func _visionCheck() -> void:
	if !target:
		var overlaps = los.get_overlapping_bodies()
		if overlaps.size() > 0:
			for overlap in overlaps:
				if overlap.is_in_group("enemy"):
					target = overlap
