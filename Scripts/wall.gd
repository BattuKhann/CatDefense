extends Node3D
class_name Wall

@export var health = 600

func hurt(damage):
	health -= damage
	#print("wall health: ", health)

func isDead() -> bool:
	return health <= 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.isDead():
		queue_free()
