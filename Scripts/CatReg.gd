class_name CatRegiment extends Node3D

var currSquare: Square

var isFriendly: bool
var xPos: int
var yPos: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func move(target: Square) -> void:
	currSquare = target;
	pass
	
func attack() -> void:
	pass
