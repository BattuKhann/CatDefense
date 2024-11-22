extends CharacterBody3D

const SPEED = 2.0
const ACCEL = 8

@export var DAMAGE = 10
@export var camera3d: Camera3D
@export var health = 100

@export var damage: int = 10  # Damage dealt by this enemy
@export var attack_range: float = 15.0  # Range within which the enemy will attack
@export var attack_interval: float = 5.0  # Time between consecutive attacks

var attack_timer = 0.0  # Tracks time since last attack 

@onready var navigation_agent_3d = $NavigationAgent3D
@onready var sprite3d = $Sprite3D

var root
var characters_in_range = []

var target: Node3D = null

func findCam():
	camera3d = get_tree().root.find_child("MainCamera", true, false)

func hurt(damage: int):
	health -= damage

func isDead():
	return health <= 0

func _ready():
	# Find the nearest object in the group "targets" and set it as the target
	root = get_tree().root
	find_target()
	camera3d = get_node_or_null("../MainCamera")
	
	if camera3d:
		print("found camera")
	else:
		findCam()

func find_target():
	# Get the nearest object in the group "troop"
	var nearest_distance = 1000
	var nearest_target = null

	for member in get_tree().get_nodes_in_group("tower"):
		# Ensure the member is a valid Node3D and not this object
		if is_instance_valid(member) and member is Node3D and member != self:
			var distance = global_transform.origin.distance_to(member.global_transform.origin)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_target = member

	# Set the nearest target
	if is_instance_valid(target):
		# Disconnect from the previous target if it exists
		target.disconnect("tree_exited", Callable(self, "_on_target_exited"))
	
	target = nearest_target

	if is_instance_valid(target):
		# Connect to the target's tree_exited signal
		target.connect("tree_exited", Callable(self, "_on_target_exited"))
		navigation_agent_3d.target_position = target.global_transform.origin
	else:
		print("No valid target found.")

# Called when the current target is removed from the scene
func _on_target_exited():
	print("Target exited the scene.")
	target = null

func _process(delta):
	attack_timer += delta
	if attack_timer >= attack_interval:
		attack_timer = 0.0
		hurt_nearby_characters()

func hurt_nearby_characters():
	for char in characters_in_range:
		char.hurt(DAMAGE)

func _physics_process(delta):
	rotateSprite()
	
	for child in get_tree().get_nodes_in_group("tower"):
		if child != self:
			# Calculate distance
			var distance = global_transform.origin.distance_to(child.global_transform.origin)
			
			if distance <= attack_range:
				characters_in_range.append(child)
	
	#for i in characters_in_range:
		#print(i)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if isDead():
		queue_free()
	
	if target:
		sprite3d.play("running")
		# Update the NavigationAgent3D's target position if the target moves
		navigation_agent_3d.target_position = target.global_transform.origin

		# Calculate the next path position to move toward
		var next_position = navigation_agent_3d.get_next_path_position()
		var direction = (next_position - global_transform.origin).normalized()
		
		var distance = global_transform.origin.distance_to(target.global_transform.origin)
		if distance < 15:
			velocity.x = move_toward(velocity.x, 0, ACCEL * delta)
			velocity.z = move_toward(velocity.z, 0, ACCEL * delta)
			move_and_slide()

		# Apply movement
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		move_and_slide()
	else:
		# If no target, stop movement
		sprite3d.play("idle")
		velocity.x = move_toward(velocity.x, 0, ACCEL * delta)
		velocity.z = move_toward(velocity.z, 0, ACCEL * delta)
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
	sprite3d.flip_h = right_dot > 0
