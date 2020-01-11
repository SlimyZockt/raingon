extends Area2D

export(int) var openingDirection

var RoomTemplates
var spawned = false

# 1 -> botton Door
# 2 -> left Door
# 3 -> up Door 
# 4 -> rigth Door

func _ready():
	var Rooms = get_tree().get_nodes_in_group("rooms")
	for Room in Rooms:
		if Room.name == "RoomTemplates":
			RoomTemplates = Room
	print(openingDirection)
	yield(get_tree().create_timer(0.1), "timeout")
	spawn_room()
	print(spawned)

func spawn_room():
	if spawned == false:
		if openingDirection == 1:
			randomize()
			var BottomRoom = RoomTemplates.BottomRooms[randi() % RoomTemplates.BottomRooms.size()].instance()
			BottomRoom.position = global_position
			get_tree().get_root().add_child(BottomRoom)
		elif openingDirection == 2: 
			randomize()
			var LeftRoom = RoomTemplates.LeftRooms[randi() % RoomTemplates.LeftRooms.size()].instance()
			LeftRoom.position = global_position
			get_tree().get_root().add_child(LeftRoom)
		elif openingDirection == 3: 
			randomize()
			var UPRoom = RoomTemplates.UPRooms[randi() % RoomTemplates.UPRooms.size()].instance()
			UPRoom.position = global_position
			get_tree().get_root().add_child(UPRoom)
		elif openingDirection == 4: 
			randomize()
			var RigthRoom = RoomTemplates.RigthRooms[randi() % RoomTemplates.RigthRooms.size()].instance()
			RigthRoom.position = global_position
			get_tree().get_root().add_child(RigthRoom)
			
		spawned = true
	elif spawned == null:
		spawned = true	



func _on_spawnpoint_area_entered(area):
	if area.name.begins_with("spawnpoint"):
		if area.spawned == false and spawned == false:
			var colsedR = RoomTemplates.closedRooms.instance()
			colsedR.position = global_position
			get_tree().get_root().add_child(colsedR)
			queue_free()
		spawned = true