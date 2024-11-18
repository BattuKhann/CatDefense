extends Node2D
class_name PlayerUi
@onready var placeSys: PlacementSystem = $"../PlacementSystem"

func selectObject(object:PackedScene):
	placeSys.selectObject(object)
