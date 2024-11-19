extends Node3D
class_name PlacementSystem

@onready var cam:Camera3D = $"../MainCamera"
@onready var navRegion3d:NavigationRegion3D = $"../NavigationRegion3D"

var RAYCAST_LENGTH = 1000
var last_hovered_area: Area3D = null
var selected: PackedScene = null
var placing: Node3D = null

func reloadNav():
	if navRegion3d and navRegion3d.navigation_mesh:
		navRegion3d.navigation_mesh.clear_baked_data()
		navRegion3d.bake_navigation_mesh(true)
	

func _ready():
	# debug
	print("nav mesh is present from initilization")

func selectObject(object: PackedScene):
	if selected == object:
		selected = null
		placing = null
	else:
		selected = object
		placing = selected.instantiate()
		add_child(placing)
		
#Mose Movement
func _physics_process(_delta):
	var space_state = get_world_3d().direct_space_state
	var mouse_position:Vector2 = get_viewport().get_mouse_position()
	var origin:Vector3 = cam.project_ray_origin(mouse_position)
	var end:Vector3 = origin + cam.project_ray_normal(mouse_position) * RAYCAST_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var rayResult:Dictionary = space_state.intersect_ray(query)
	
	if rayResult.size() > 0:
		var co:CollisionObject3D = rayResult.get("collider")
		
		if co and co is Area3D:
			if last_hovered_area != co:
				# Reset the previous hovered area
				if last_hovered_area:
					_highlight(last_hovered_area, false)
				# Set the new hovered area
				last_hovered_area = co
				_highlight(co, true)
		if placing:
			placing.global_position = Vector3(co.global_position.x, 0.2, co.global_position.z)
		
	elif last_hovered_area:
		_highlight(last_hovered_area, false)
	
	
	

func _highlight(area: Area3D, highlight: bool):
	var mesh_instance = area.find_child("MeshInstance3D")  # Replace with your node path
	if mesh_instance and mesh_instance is MeshInstance3D:
		var material = StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		var color = Color(1.0, 1.0, 1.0, 1)  # White color with 75% opacity
		material.albedo_color = color
		if highlight:
			mesh_instance.set_surface_override_material(0, material)
		else:
			mesh_instance.set_surface_override_material(0, null)
