extends Navigation2D

var nav_tilemap = {}
var cell_size = []
var width = 0
var height = 0
var debug_points = []
onready var astar = AStar2D.new()
onready var generator = get_node("/root/World/Generator")
var dirs = [Vector2(-1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(0, -1)]
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)

func refresh_navigation():
	nav_tilemap.clear()
	cell_size.clear()
	astar.clear()
	debug_points.clear()
	var index = 0
	# first layer for the navigation, second layer for the obstruction
	for tilemap in generator.get_children():
		if not tilemap is TileMap:
			continue
		cell_size = tilemap.get_cell_size() * get_scale()
		for cellIdx in tilemap.get_used_cells():
			var cell = tilemap.get_cell(cellIdx.x, cellIdx.y)
			var nav = tilemap.tile_set.tile_get_navigation_polygon(cell)
			if(nav != null):
				set_cell_value(cellIdx.x, cellIdx.y, 1)
				debug_points.append(get_pos_by_cell(cellIdx))
			else:
				set_cell_value(cellIdx.x, cellIdx.y, 0)
				debug_points.append(get_pos_by_cell(cellIdx))
			astar.add_point(index, get_pos_by_cell(Vector2(cellIdx.x, cellIdx.y)))
			index += 1
	# print_pos_map()
	get_node("/root/World").set_debug_points(debug_points)
	update_connection()
	
func update_connection():
	for row in nav_tilemap.keys():
		for col in nav_tilemap[row].keys():
			if nav_tilemap[row][col] == 0:
				continue
			var point_id = get_astar_id(row, col)
			for dir in dirs:
				if get_cell_value(row + dir.x, col + dir.y) == 1:
					var neightbor_point_id = get_astar_id(row + dir.x, col + dir.y)
					astar.connect_points(point_id, neightbor_point_id)
#			print(String(point_id) + ": " + String(row) + ", " + String(col) + " " +
#				String(astar.get_point_connections(point_id)))

func get_cell_by_pos(pos):
	var cell_layer_size = cell_size * get_scale()
	return Vector2(floor(pos.x / cell_layer_size.x), floor(pos.y / cell_layer_size.y))

func get_pos_by_cell(cell):
	var local_position = generator.tilemap.map_to_world(cell) * scale
	local_position += cell_size * 0.5
	return local_position


func print_nav_map():
	for row in nav_tilemap.keys():
		var row_str = String(row) + ": "
		for val in nav_tilemap[row].values():
			row_str += String(val) + " "
		print(row_str)

func print_astar_map():
	for row in nav_tilemap.keys():
		var row_str = String(row) + ": "
		for val in nav_tilemap[row].keys():
			row_str += String(get_astar_id(row, val)) + " "
		print(row_str)

func print_pos_map():
	for row in nav_tilemap.keys():
		var row_str = String(row) + ": "
		for col in nav_tilemap[row].keys():
			row_str += String(get_pos_by_cell(Vector2(row, col))) + " "
		print(row_str)

func get_astar_id(row, col):
	var cell = get_pos_by_cell(Vector2(row, col))
	return astar.get_closest_point(cell)

func get_cell_value(x, y):
	x = float(x)
	y = float(y)
	if not nav_tilemap.has(x):
		return null
	if not nav_tilemap[x].has(y):
		return null
	return nav_tilemap[x][y]

func set_cell_value(x, y, z):
	if !nav_tilemap.has(x):
		nav_tilemap[x] = {}
	nav_tilemap[x][y] = z

func get_nav_path(start_pos, end_pos):
	var a_id = astar.get_closest_point(start_pos)
	var e_id = astar.get_closest_point(end_pos)
	var paths = astar.get_id_path(a_id, e_id)
	var res = PoolVector2Array()
	for step in paths:
		res.append(astar.get_point_position(step))
	if res.size() > 0:
		# res.append(end_pos)
		res.insert(0, start_pos)
	get_node("/root/World").set_debug_points(res)
	return res

func get_cell_size():
	return cell_size

func get_ran_neighbor(point):
	var p_id = astar.get_closest_point(point)
	var neighbors = astar.get_point_connections(p_id)
	if neighbors.size() <= 0:
		return
	var ran_neighbor = neighbors[int(rand_range(0, neighbors.size() - 1))]
	return astar.get_point_position(ran_neighbor)
