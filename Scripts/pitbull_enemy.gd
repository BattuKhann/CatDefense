extends CharacterBody3D

const SPEED = 6.0
const ACCEL = 10

@export var DAMAGE = 15

@onready var navigation_agent_3d = $NavigationAgent3D
@onready var sprite3d = $Sprite3D

var target: Node3D = null

func _ready():
	# Find the nearest object in the group "targets" and set it as the target
	find_target()

func find_target():
	# Get the nearest object in the group "targets"
	var nearest_distance = 1000
	var nearest_target = null

	for member in get_tree().get_nodes_in_group("target"):
		if member is Node3D:
			var distance = global_transform.origin.distance_to(member.global_transform.origin)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_target = member

	target = nearest_target
	if target:
		navigation_agent_3d.target_position = target.global_transform.origin

func _physics_process(delta):
	if target:
		# Update the NavigationAgent3D's target position if the target moves
		navigation_agent_3d.target_position = target.global_transform.origin

		# Calculate the next path position to move toward
		var next_position = navigation_agent_3d.get_next_path_position()
		var direction = (next_position - global_transform.origin).normalized()
		
		var distance = global_transform.origin.distance_to(target.global_transform.origin)
		if distance < 10:
			velocity.x = move_toward(velocity.x, 0, ACCEL * delta)
			velocity.z = move_toward(velocity.z, 0, ACCEL * delta)
			move_and_slide()

		# Apply movement
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		move_and_slide()

		# Recalculate the target if it's too far or unreachable
		if navigation_agent_3d.path_empty():
			find_target()
	else:
		# If no target, stop movement
		velocity.x = move_toward(velocity.x, 0, ACCEL * delta)
		velocity.z = move_toward(velocity.z, 0, ACCEL * delta)
		move_and_slide()

func _on_Target_exited():
	# Re-evaluate the target when the current target exits the group or becomes unreachable
	find_target()
