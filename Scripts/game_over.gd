extends CanvasLayer
class_name game_over

@onready var audio = $audio

# Called when the node enters the scene tree for the first time.
func _ready():
	audio.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quit_pressed():
	get_tree().quit()


func _on_retry_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
