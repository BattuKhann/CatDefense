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
	aim(Vector3(3, -1, 0))
	fire()
	
func _process(delta: float) -> void:
	pass

func aim(target: Vector3):
	pointer.look_at(Vector3(target.x, pointer.global_position.y, target.z))
	pointer.global_rotation.y -= PI/2
	
	laser_beam.look_at(target)
	laser_beam.global_rotation.x += PI/2
	pass
		

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
