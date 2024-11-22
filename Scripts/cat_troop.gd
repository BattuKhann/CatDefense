extends CharacterBody3D

const SPEED = 2.0
const ACCEL = 8

@export var DAMAGE = 50
@export var camera3d: Camera3D
@export var health = 100

@export var damage: int = 10  # Damage dealt by this enemy
@export var attack_range: float = 10.0  # Range within which the enemy will attack
@export var attack_interval: float = 2.0  # Time between consecutive attacks

var attack_timer = 0.0  # Tracks time since last attack

@onready var navigation_agent_3d = $NavigationAgent3D
@onready var sprite3d = $Sprite3D


var target: Node3D = null

func findCam():
	camera3d = get_tree().root.find_child("MainCamera", true, false)



func hurt(damage):
	health -= damage

func isDead():
	return health <= 0

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

	for member in get_tree().get_nodes_in_group("enemy"):
		if member is Node3D:
			var distance = global_transform.origin.distance_to(member.global_transform.origin)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_target = member

	target = nearest_target
	if target:
		navigation_agent_3d.target_position = target.global_transform.origin

func _process(delta):
	attack_timer += delta
	if attack_timer >= attack_interval:
		attack_timer = 0.0
		hurt_nearby_characters()

func gethealth():
	return health

func hurt_nearby_characters():
	# Find all children of the root node
	var root = get_tree().root
	var characters_in_range = []
	
	for child in root.get_children():
		# Check if the child is a CharacterBody3D and not itself
		if child is CharacterBody3D and child != self:
			# Calculate the distance to the child
			var distance = global_transform.origin.distance_to(child.global_transform.origin)
			if distance <= attack_range:
				characters_in_range.append(child)
	
	for char in characters_in_range:
		if char.has_method("hurt"):
			char.hurt(damage)

func _physics_process(delta):
	print("troop hp: ")
	print(self.health)
	rotateSprite()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if isDead():
		queue_free()
	
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
	else:
		# If no target, stop movement
		velocity.x = move_toward(velocity.x, 0, ACCEL * delta)
		velocity.z = move_toward(velocity.z, 0, ACCEL * delta)
		find_target()
		move_and_slide()

func _on_Target_exited():
	# Re-evaluate the target when the current target exits the group or becomes unreachable
	find_target()

func rotateSprite():
	if not camera3d:
		return  # Ensure nodes are valid before proceeding
	
	# Get the direction vector from the sprite to the camera
	var to_camera = (camera3d.global_transform.origin - global_transform.origin).normalized()
	
	# Preserve the sprite's current X rotation (pitch)
	var current_pitch = rotation.x
	# Calculate the yaw (Y-axis rotation) to face the camera
	var target_yaw = atan2(to_camera.x, to_camera.z)
	# Apply the calculated yaw while locking the pitch
	rotation_degrees = Vector3(rad_to_deg(current_pitch), rad_to_deg(target_yaw), 0)
	# Optionally handle horizontal flipping based on the camera's relative position
	var right_dot = to_camera.dot(camera3d.transform.basis.x)
	sprite3d.flip_h = right_dot < 0
