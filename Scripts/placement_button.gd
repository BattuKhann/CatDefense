extends Button

@export var button_icon:Texture2D
@export var draggable:PackedScene
@export var placable: PackedScene
@onready var ui: PlayerUi = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon = button_icon


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	ui.selectObject(draggable, placable)
