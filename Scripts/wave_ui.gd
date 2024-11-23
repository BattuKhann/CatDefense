extends Node2D

@onready var spawner: WaveDogSpawner
@onready var wave = $Control/WaveLabel
var currentWave

func _ready():
	# Assuming RandomDogSpawner is directly under the same parent as WaveUI
	spawner = get_node("../RandomDogSpawner")
	if spawner == null:
		print("Could not find spawner")
	else:
		print("Spawner found:", spawner)
		currentWave = spawner.getwave()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currentWave = spawner.getwave()
	
	if currentWave == 0:
		wave.text = "Dogs will spawn soon!"
	else:
		wave.text = "Wave: " + str(currentWave)
