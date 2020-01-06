extends Node2D

onready var player = $player
onready var camera = $Camera2D


func _ready():
	add_camera()

func add_camera():
	remove_child(camera)
	player.add_child(camera)
