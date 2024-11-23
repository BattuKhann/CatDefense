extends Node3D

@export var wave = 0
var spawning;
var spawns = []

@onready var waveTimer = $WaveTimer
@onready var headstart = $Headstart

@onready var spawn_1 = $Spawn1
@onready var spawn_2 = $Spawn2
@onready var spawn_3 = $Spawn3
@onready var spawn_4 = $Spawn4
@onready var spawn_5 = $Spawn5
@onready var spawn_6 = $Spawn6

@onready var dober: PackedScene = preload("res://Scenes/doberman_enemy.tscn")
@onready var pitbull: PackedScene = preload("res://Scenes/pitbull_enemy.tscn")
@onready var chihuahua: PackedScene = preload("res://Scenes/chihuahua_enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	headstart.start()
	spawning = false
	
	for i in get_children():
		if i is Node3D:
			spawns.append(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("headstart: ", headstart.time_left)
	print("wave timer: ", waveTimer.time_left)
	print("Wave: ", wave)

func setStuff(obj: Node3D, spawn: Node3D):
	obj.add_to_group("enemy")
	obj.global_position = spawn.global_position
	get_tree().root.add_child(obj)

func spawnDogs():
	if wave <= 5:
		var doberc: Node3D = dober.instantiate()
		var pitc: Node3D = pitbull.instantiate()
		var chiwc: Node3D = chihuahua.instantiate()
		
		setStuff(doberc, spawn_1)
		setStuff(pitc, spawn_2)
		setStuff(chiwc, spawn_3)
	elif wave <= 10:
		pass
	elif wave <= 15:
		pass
	elif wave <= 20:
		pass
	elif wave <= 25:
		pass
	elif wave <= 29:
		pass
	elif wave == 30:
		pass

func _headstart_timeout():
	spawning = true
	waveTimer.start()
	headstart.stop()
	spawnDogs()

func _wave_timer_timeout():
	wave += 1
	waveTimer.start()
	spawnDogs()
