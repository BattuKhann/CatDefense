extends Node3D

@export var health = 500

func hurt(damage):
	health -= damage

func isDead() -> bool:
	return health <= 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.isDead():
		queue_free()
