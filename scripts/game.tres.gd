extends Node2D

onready var player = $player
onready var camera = $Camera2D

const TILE_SIZE = 128

func _ready():
	add_camera()

func add_camera():
	remove_child(camera)
	player.add_child(camera)


func _on_Area2D_area_entered(area):
	if area.name.begins_with("spawnpoint"):
		remove_child(area)