extends Node3D
class_name WaveDogSpawner

@export var wave = 0
var spawning;
var spawns = []
var repeatsLeft = 0

@onready var waveTimer = $WaveTimer
@onready var headstart = $Headstart
@onready var extraTimer = $ExtraneousDogsTimer

@onready var spawn_1 = $Spawn1
@onready var spawn_2 = $Spawn2
@onready var spawn_3 = $Spawn3
@onready var spawn_4 = $Spawn4
@onready var spawn_5 = $Spawn5
@onready var spawn_6 = $Spawn6

@onready var dober: PackedScene = preload("res://Scenes/doberman_enemy.tscn")
@onready var pitbull: PackedScene = preload("res://Scenes/pitbull_enemy.tscn")
@onready var chihuahua: PackedScene = preload("res://Scenes/chihuahua_enemy.tscn")

func getwave() -> int:
	return wave

# Called when the node enters the scene tree for the first time.
func _ready():
	headstart.start()
	spawning = false
	
	# these 3 lines are fucking useless
	for i in get_children():
		if i is Node3D:
			spawns.append(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#print("headstart: ", headstart.time_left)
	#print("wave timer: ", waveTimer.time_left)
	#print("Wave: ", wave)

func setStuff(obj: Node3D, spawn: Node3D):
	obj.add_to_group("enemy")
	obj.global_position = spawn.global_position
	get_tree().root.add_child(obj)

func spawnDogs():
	if wave <= 3:
		var pitc: Node3D = pitbull.instantiate()
		var pitc2: Node3D = pitbull.instantiate()
		
		setStuff(pitc2, spawn_1)
		setStuff(pitc, spawn_2)
	elif wave <= 5:
		var doberc: Node3D = dober.instantiate()
		var pitc: Node3D = pitbull.instantiate()
		
		setStuff(doberc, spawn_1)
		setStuff(pitc, spawn_2)
	elif wave <= 10:
		var doberc: Node3D = dober.instantiate()
		var pitc: Node3D = pitbull.instantiate()
		var chiwc: Node3D = chihuahua.instantiate()
		
		setStuff(doberc, spawn_1)
		setStuff(pitc, spawn_2)
		setStuff(chiwc, spawn_3)
	elif wave <= 15:
		var doberc: Node3D = dober.instantiate()
		var doberc2: Node3D = dober.instantiate()
		var pitc: Node3D = pitbull.instantiate()
		
		setStuff(doberc, spawn_1)
		setStuff(doberc2, spawn_2)
		setStuff(pitc, spawn_3)
		
		repeatsLeft = 1
		extraTimer.start()
	elif wave <= 20:
		pass
	elif wave <= 25:
		pass
	elif wave <= 29:
		pass
	elif wave == 30:
		var doberc: Node3D = dober.instantiate()
		var doberc2: Node3D = dober.instantiate()
		var doberc3: Node3D = dober.instantiate()
		var doberc4: Node3D = dober.instantiate()
		
		repeatsLeft = 8
		setStuff(doberc, spawn_1)
		setStuff(doberc2, spawn_2)
		setStuff(doberc3, spawn_3)
		setStuff(doberc4, spawn_4)

func spawnExtraChihuahua():
	var chiwc: Node3D = chihuahua.instantiate()
	setStuff(chiwc, spawn_6)

func spawnExtraPitbull():
	var pit: Node3D = pitbull.instantiate()
	setStuff(pit, spawn_5)

func spawnExtraDoberman():
	var dob: Node3D = dober.instantiate()
	setStuff(dob, spawn_4)

func _headstart_timeout():
	spawning = true
	wave += 1
	waveTimer.start()
	headstart.stop()
	spawnDogs()

func _wave_timer_timeout():
	if wave <= 29:
		wave += 1
		waveTimer.start()
		spawnDogs()

func _extraneous_timer_timeout():
	if repeatsLeft > 0:
		repeatsLeft -= 1
		extraTimer.start()
		
		var i = int(randi_range(1,4))
		
		if i == 1:
			spawnExtraDoberman()
		elif i == 2:
			spawnExtraPitbull()
		else:
			spawnExtraChihuahua()
	else:
		pass
