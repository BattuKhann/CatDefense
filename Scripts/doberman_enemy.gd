extends CharacterBody3D

const SPEED = 2.0
const ACCEL = 8

@export var DAMAGE = 50
@export var camera3d: Camera3D

@onready var navigation_agent_3d = $NavigationAgent3D
@onready var sprite3d = $Sprite3D

var target: Node3D = null

func findCam():
	camera3d = get_tree().root.find_child("MainCamera", true, false)

func _ready():
	# Find the nearest object in the group "targets" and set it as the target
	find_target()
	camera3d = get_node_or_null("../MainCamera")
	
	if camera3d:
		print("found camera")
	else:
		findCam()

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
	rotateSprite()
	
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

func rotateSprite():
	# Get the direction vector from the camera to the CharacterBody3D (parent)
	var to_character = global_transform.origin - camera3d.global_transform.origin
	# Project the direction vector onto the camera's right vector
	var right_dot = to_character.dot(camera3d.transform.basis.x)

	# Flip the sprite based on whether the character is left or right of the camera
	sprite3d.flip_h = right_dot < 0

	# Align the sprite to face the camera
	look_at(camera3d.global_transform.origin, Vector3.UP)
