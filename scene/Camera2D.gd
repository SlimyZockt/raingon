extends Camera2D

const SPEED = 5
const MAXPOS = 64

func _process(delta):
	if get_global_mouse_position().x > 0:
		offset.x = min(offset.x + SPEED, MAXPOS * 2)
	elif get_global_mouse_position().x < 0:
		offset.x = max(offset.x - SPEED, -MAXPOS * 2)
	if get_global_mouse_position().y > 0:
		offset.y = min(offset.y + SPEED, MAXPOS)
	elif get_global_mouse_position().y < 0:
		offset.y = max(offset.y - SPEED, -MAXPOS)
