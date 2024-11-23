extends CharacterBody3D

const SPEED = 2.7
const ACCEL = 10

@export var DAMAGE = 8
@export var camera3d: Camera3D
@export var health = 100

@onready var hurtsfx = $Hurt
@onready var attack = $Attack
@onready var death = $Death

@export var damage: int = 8  # Damage dealt by this enemy
@export var attack_range: float = 2 # Range within which the enemy will attack
@export var attack_interval: float = 0.3  # Time between consecutive attacks

var attack_timer = 0.0  # Tracks time since last attack 

@onready var navigation_agent_3d = $NavigationAgent3D
@onready var sprite3d = $Sprite3D

var root
var characters_in_range = []
var attacking = false

var target: Node3D = null

func _on_animation_finished():
	if sprite3d.animation == "attack":
		attacking = false
		sprite3d.stop()
		
		if isDead():
			sprite3d.play("death")
			death.play()
		
		if target:  # Check if the enemy still has a target
			sprite3d.play("running")
		else:
			sprite3d.play("idle")

func choose_25_chance() -> bool:
	return randf() < 0.25

func findCam():
	camera3d = get_tree().root.find_child("MainCamera", true, false)

func hurt(damage: int):
	health -= damage
	sprite3d.play("hurt")
	hurtsfx.play()

func isDead() -> bool:
	return health <= 0

func _ready():
	# Find the nearest object in the group "targets" and set it as the target
	root = get_tree().root
	find_target()
	camera3d = get_node_or_null("../MainCamera")
	
	if sprite3d.has_signal("animation_finished"):
		sprite3d.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
	if camera3d:
		print("found camera")
	else:
		findCam()

func find_target():
	target = null
	# Get the nearest object in the group "tower"
	var nearest_distance = 100
	var nearest_target = null

	for member in get_tree().get_nodes_in_group("tower_wall"):
		# Ensure the member is a valid Node3D and not this object
		if is_instance_valid(member) and member is Node3D and member != self:
			var distance = global_transform.origin.distance_to(member.global_transform.origin)
			
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
		pass
		#print("No valid target found.")

# Called when the current target is removed from the scene
func _on_target_exited():
	print("Target exited the scene.")
	target = null

#func _process(delta):
	#attack_timer += delta
	#if attack_timer >= attack_interval:
		#attack_timer = 0.0
		#hurt_nearby_characters()
		
func test(delta):
	attack_timer += delta
	if attack_timer >= attack_interval:
		attack_timer = 0.0
		hurt_nearby_characters()

func hurt_nearby_characters():
	# Create a new array to hold valid characters
	var valid_characters = []
	for char in characters_in_range:
		if is_instance_valid(char):
			attacking = true
			sprite3d.stop()
			valid_characters.append(char)
			
			sprite3d.play("attack")
			attack.play()
			
			if char and char is Wall and char.has_method("hurt"):
				if !isDead():
					char.hurt(DAMAGE)
			elif char and char is Wagyu and char.has_method("hurt"):
				if !isDead():
					char.hurt(DAMAGE)
			
	# Update the list with only valid characters
	characters_in_range = valid_characters
	print(characters_in_range)
	print("dog health: ", health)

func _physics_process(delta):
	rotateSprite()
	
	for child in get_tree().get_nodes_in_group("tower_wall"):
		if child != self:
			# Calculate distance
			var distance = global_transform.origin.distance_to(child.global_transform.origin)
			
			if distance <= attack_range:
				if not characters_in_range.has(child):
					characters_in_range.append(child)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if isDead():
		sprite3d.play("death")
		if !sprite3d.is_playing():
			queue_free()
	
	if target:
		if !attacking:
			sprite3d.play("running")
		
		# Update the NavigationAgent3D's target position if the target moves
		navigation_agent_3d.target_position = target.global_transform.origin
		
		# Calculate the next path position to move toward
		var next_position = navigation_agent_3d.get_next_path_position()
		var direction = (next_position - global_transform.origin).normalized()
		
		var distance = global_transform.origin.distance_to(target.global_transform.origin)
		if distance < 3:
			velocity.x = move_toward(velocity.x, 0, ACCEL * delta)
			velocity.z = move_toward(velocity.z, 0, ACCEL * delta)
			test(delta)
			move_and_slide()
			
		# Apply movement
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		move_and_slide()
	else:
		# If no target, stop movement
		if !attacking:
			sprite3d.play("idle")
		
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
	sprite3d.flip_h = right_dot > 0
