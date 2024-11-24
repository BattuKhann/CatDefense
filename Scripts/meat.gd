extends Node3D
class_name Wagyu

@export var health = 100

func hurt(damage):
	health -= damage

# Called when the node enters the scene tree for the first time.
func _ready():
	health = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
