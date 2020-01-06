extends Node2D

onready var camera = $Camera2D

const TILE_SIZE = 64

const LELVEL_SIZES = [
	Vector2(70,70),
	Vector2(35,35),
	Vector2(40,40),
	Vector2(45,45),
	Vector2(50,50),
]

const LEVEL_ROOM_COUNTS = [5, 7, 9, 12, 15]
const MIN_ROOM_DIMENSION = 5
const MAX_ROOM_DIMENSION = 8

enum Tile {box, clean}

# current level

var level_num = 0
var map = []
var rooms = []
var level_size

var player_tile

onready var player = $player
onready var tile_map = $wall

func _ready():
	OS.set_window_size(Vector2(1280, 720))
	add_camera()
	randomize()
	build_level()

func add_camera():
	remove_child(camera)
	player.add_child(camera)

func build_level():
	rooms.clear()
	map.clear()
	tile_map.clear()

	level_size = LELVEL_SIZES[level_num]
	for x in range(level_size.x):
		map.append([])
		for y in range(level_size.y):
			map[x].append(Tile.box)
			tile_map.set_cell(x,y, Tile.box)

	var free_regions = [Rect2(Vector2(2,2), level_size - Vector2(4,4))]
	var num_rooms = LEVEL_ROOM_COUNTS[level_num]
	for i in range(num_rooms):
		add_room(free_regions)
		if free_regions.empty():
			break

	connect_rooms()
	
	var start_room = rooms.front()
	var player_x = start_room.position.x + 1 + randi() % int(start_room.size.x - 2)
	var player_y = start_room.position.y + 1 + randi() % int(start_room.size.y - 2)
	
	print(start_room, player_x, player_y)
	player.position = Vector2(player_x, player_y) * TILE_SIZE
	
	
func connect_rooms():
		var out_line_graph = AStar.new()
		var point_id = 0
		for x in range(level_size.x):
			for y in range(level_size.y):
				if map[x][y] == Tile.box:
					out_line_graph.add_point(point_id, Vector3(x, y, 0))

					if x > 0 and map[x - 1][y] == Tile.box:
						var left_point = out_line_graph.get_closest_point(Vector3(x -1,y, 0))
						out_line_graph.connect_points(point_id, left_point)

					if y > 0 and map[x][y - 1] == Tile.box:
						var up_point = out_line_graph.get_closest_point(Vector3(x, y-1 , 0))
						out_line_graph.connect_points(point_id, up_point)

					point_id += 1

		var room_graph = AStar.new()
		point_id = 0
		for room in rooms:
			var room_centre = room.position + room.size / 2
			room_graph.add_point(point_id, Vector3(room_centre.x, room_centre.y, 0))
			point_id += 1

		while !is_everything_connected(room_graph):
			add_random_connection(out_line_graph, room_graph)

func is_everything_connected(graph):
	var points = graph.get_points()
	var start = points.pop_back()

	for point in points:
		var path = graph.get_point_path(start, point)
		if !path:
			return false
	return true

func add_random_connection(out_line_graph: AStar, room_graph: AStar):
	var start_room_id = get_least_connected_point(room_graph)
	var end_room_id = get_nearst_unconnected(room_graph, start_room_id)
	
	var start_pos = pick_random_door_location(rooms[start_room_id])
	var end_pos = pick_random_door_location(rooms[end_room_id])
	
	var closest_start_point = out_line_graph.get_closest_point(start_pos)
	var closest_end_point = out_line_graph.get_closest_point(end_pos)
	
	var path = out_line_graph.get_point_path(closest_start_point, closest_end_point)

	set_connect_tile(start_pos.x, start_pos.y , Tile.clean)
	set_connect_tile(end_pos.x, end_pos.y, Tile.clean)
	
	for pos in path:
		set_connect_tile(pos.x, pos.y, Tile.clean)
		
	room_graph.connect_points(start_room_id, end_room_id)
	
	
func get_least_connected_point(graph: AStar):
	var point_ids = graph.get_points()
	
	var least
	var tied_for_least = []
	
	for point in point_ids:
		var count = graph.get_point_connections(point).size()
		if !least or count < least:
			least = count
			tied_for_least = [point]
		elif count == least:
			tied_for_least.append(point)
	
	return tied_for_least[randi() % tied_for_least.size()]


func get_nearst_unconnected(graph: AStar, target_point):
	var target_pos = graph.get_point_position(target_point)
	var point_ids = graph.get_points()
	
	var nearest
	var tield_for_nearset = []
	
	for point in point_ids:
		if point == target_point:
			continue
		var path = graph.get_point_path(point, target_point)
		if path:
			continue
		
		var dist = (graph.get_point_position(point)- target_pos).length()
		if !nearest or dist < nearest:
			nearest = dist
			tield_for_nearset = [point]
		elif dist == nearest:
			tield_for_nearset.append(point)
	
	return tield_for_nearset[randi() % tield_for_nearset.size()]
	
func pick_random_door_location(room):
	var options = []
	
	for x in range(room.position.x + 1, room.end.x - 2):
		options.append(Vector3(x, room.position.y, 0))
		options.append(Vector3(x, room.end.y -1, 0))
	
	for y in range(room.position.y + 1, room.end.y - 2):
		options.append(Vector3(room.position.x, y, 0))
		options.append(Vector3(room.end.x -1, y, 0))
		
	return options[randi() % options.size()]

func add_room(free_regions):
	var region = free_regions[randi() % free_regions.size()]
	var size_x = MIN_ROOM_DIMENSION
	
	if region.size.x > MIN_ROOM_DIMENSION:
		size_x += randi() % int(region.size.x - MIN_ROOM_DIMENSION)
	
	var size_y = MIN_ROOM_DIMENSION
	
	if region.size.y > MIN_ROOM_DIMENSION:
		size_y += randi() % int(region.size.y - MIN_ROOM_DIMENSION)
	
	size_x = min(size_x, MAX_ROOM_DIMENSION)
	size_y = min(size_y, MAX_ROOM_DIMENSION)
	
	var start_x = region.position.x
	
	if region.size.x >size_x:
		start_x += randi() % int(region.size.x - size_x)
	
	var start_y = region.position.y
	
	if region.size.y >size_y:
		start_y += randi() % int(region.size.y - size_y)
	
	var room = Rect2(start_x, start_y, size_x, size_y)
	
	rooms.append(room)
	
	for x in range(start_x, start_x + size_x):
		set_tile(x, start_y, Tile.clean)
		set_tile(x, start_y + size_y - 1, Tile.clean)
		
	for y in range(start_y + 1, start_y + size_y - 1):
		set_tile(start_x, y, Tile.clean)
		set_tile(start_x + size_x - 1, y, Tile.clean)
		
		for x in range(start_x + 1, start_x + size_x - 1):
			set_tile(x, y, Tile.clean)
			
	cut_regions(free_regions, room)

func cut_regions(free_regions, regions_to_cut):
	var removal_queue = []
	var addition_queue = []

	for regions in free_regions:
		if regions.intersects(regions_to_cut):
			removal_queue.append(regions)

			var leftover_left = regions_to_cut.position.x - regions.position.x - 1
			var leftover_right = regions.end.x - regions_to_cut.end.x - 1
			var leftover_up = regions_to_cut.position.y - regions.position.y - 1
			var leftover_down = regions.end.y - regions_to_cut.end.y - 1

			if leftover_left >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(regions.position, Vector2(leftover_left, regions.size.y)))
			if leftover_right >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(Vector2(regions_to_cut.end.x + 1, regions.position.y), Vector2(leftover_right, regions.size.y)))
			if leftover_up >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(regions.position, Vector2(regions.size.x, leftover_up)))
			if leftover_down >= MIN_ROOM_DIMENSION:
				addition_queue.append(Rect2(Vector2(regions.position.x, regions_to_cut.end.y + 1), Vector2(regions.size.x, leftover_down)))

	print("removal_queue: ", removal_queue, "addition_queue: ", addition_queue)

	for region in removal_queue:
		free_regions.erase(region)

	for region in addition_queue:
		free_regions.append(region)


func set_tile(x, y, type):
	map[x][y] = type
	tile_map.set_cell(x , y , type)
	
func set_connect_tile(x, y, type):
	map[x][y] = type
	tile_map.set_cell(x , y , type)
	tile_map.set_cell(x + 1 , y + 1 , type)
	tile_map.set_cell(x + 2 , y + 2 , type)

#kek kak kek
