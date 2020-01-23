extends Camera2D

const SPEED = 5
const MAXPOS = 64

var player 
var wait = false

func _ready():
	player = get_parent().get_node("player")


func _process(delta):
	if get_global_mouse_position().x > player.position.x:
		offset.x = min(offset.x + SPEED, MAXPOS )
	elif get_global_mouse_position().x < player.position.x:
		offset.x = max(offset.x - SPEED, -MAXPOS )
	if get_global_mouse_position().y > player.position.y:
		offset.y = min(offset.y + SPEED, MAXPOS)
	elif get_global_mouse_position().y < player.position.y:
		offset.y = max(offset.y - SPEED, -MAXPOS)
