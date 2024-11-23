extends Node3D

@onready var laser_beam = $LaserPointer/LaserBeam
@onready var los: Area3D = $LOS
@onready var reload_timer = $ReloadTimer
@onready var firing_timer = $FiringTimer
@onready var pointer = $LaserPointer

var loaded: bool = true
var target: Node3D
var firingTime = 3.0

func _ready() -> void:
	aim(Vector3(3, 50, 0))
	fire()
	
func _process(delta: float) -> void:
	pass

func aim(target: Vector3):
	var direction = (target - laser_beam.global_transform.origin).normalized()
	
	direction.y = 0
	direction = direction.normalized()

	if direction.length() > 0:
		pointer.look_at(pointer.global_transform.origin + direction, Vector3.UP)
		pointer.global_rotation.y -= PI/2
		
	var direction2 = (target - laser_beam.global_transform.origin).normalized()
	
	direction2.x = 0
	direction.z = 0
	#direction2 = direction2.normalized()

	# Prevent invalid directions
	if direction2.length() > 0:
		laser_beam.look_at(laser_beam.global_transform.origin + direction2, Vector3.UP)
		laser_beam.global_rotation.z += PI/4

func fire():
	#look_at(target)
	#laser_beam.look_at(target)
	laser_beam.fire(firingTime)

func _on_reload() -> void:
	loaded = true

func _visionCheck() -> void:
	if !target:
		var overlaps = los.get_overlapping_bodies()
		if overlaps.size() > 0:
			for overlap in overlaps:
				if overlap.is_in_group("enemy"):
					target = overlap
