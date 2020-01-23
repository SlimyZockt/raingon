extends Node2D

class_name gun
#class Gun:

var bullet_scene

var FIRE_RATE
var BULLET_AMUONT
var BULLET_SPEED
var BULLET_RAIL 
var BulletPoint
var SHOT

var can_fire = true
const ROTATION_P = 8

func _init(bullet_scene, BulletPoint, FIRE_RATE, BULLET_AMUONT, BULLET_SPEED, BULLET_RAIL, SHOT):
	self.bullet_scene = bullet_scene
	self.BulletPoint = BulletPoint
	self.FIRE_RATE = FIRE_RATE
	self.BULLET_AMUONT = BULLET_AMUONT
	self.BULLET_SPEED = BULLET_SPEED
	self.BULLET_RAIL = BULLET_RAIL
	self.SHOT = SHOT

func shot():
	if can_fire:
		for bulletR in range(BULLET_RAIL):
			for bulletA in range( floor(-BULLET_AMUONT/2), floor(BULLET_AMUONT/2) ):
				print(bulletA)
				var	bullet_instance = bullet_scene.instance()
				if is_mouse_x_y(get_global_mouse_position().x, get_global_mouse_position().y):
					bullet_instance.position = BulletPoint.global_position + Vector2(90 * -bulletA + rotation, 0)
				else:
					bullet_instance.position = BulletPoint.global_position + Vector2( 0 , 90 * bulletA + rotation)
				if is_mouse_90_axis(get_global_mouse_position().x, get_global_mouse_position().y):
					bullet_instance.rotation_degrees = rotation_degrees + bulletA * -ROTATION_P
				else:
					bullet_instance.rotation_degrees = rotation_degrees + bulletA * ROTATION_P
				bullet_instance.apply_impulse(Vector2(), Vector2(BULLET_SPEED, 0).rotated(rotation))
				get_tree().get_root().add_child(bullet_instance)
				SHOT.play()
			can_fire = false
			yield(get_tree().create_timer(FIRE_RATE), "timeout")
			can_fire = true	

func is_mouse_x_y(mouseX,mouseY):
	var distanceX = sqrt((global_position.x - mouseX)*(global_position.x - mouseX))
	var distanceY = sqrt((global_position.y - mouseY)*(global_position.y - mouseY)) 
	
	if distanceX < distanceY:
		return true
	else:
		return false
	
func is_mouse_90_axis(mouseX,mouseY):
	var distanceX = global_position.x - mouseX
	var distanceY = global_position.y - mouseY
	
	if distanceX > distanceY:
		return true
	else:
		return false