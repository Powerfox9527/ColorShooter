extends Node2D
#Here is the fastest algorithm I know that generates each convex polygon with equal probability. The output has exactly N vertices, and the running time is O(N log N), so it can generate even large polygons very quickly.
#1. Generate two lists, X and Y, of N random integers between 0 and C. Make sure there are no duplicates.
#2. Sort X and Y and store their maximum and minimum elements.
#3. Randomly divide the other (not max or min) elements into two groups: X1 and X2, and Y1 and Y2.
#4. Re-insert the minimum and maximum elements at the start and end of these lists (minX at the start of X1 and X2, maxX at the end, etc.).
#5. Find the consecutive differences (X1[i + 1] - X1[i]), reversing the order for the second group (X2[i] - X2[i + 1]). Store these in lists XVec and YVec.
#6. Randomize (shuffle) YVec and treat each pair XVec[i] and YVec[i] as a 2D vector.
#7. Sort these vectors by angle and then lay them end-to-end to form a polygon.
#8. Move the polygon to the original min and max coordinates.
var cell_size = Vector2(64, 64)
# accord to the tile set 
var dirs = [Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), 
Vector2(0, 1), Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1)]
export var cell_num = 60
var ran_generator = RandomNumberGenerator.new()
export var seed_id = 0
export var use_seed = false
export var island_count = 0
export var enemy_count = 1
onready var tilemap = $TileMap
onready var tilemap2 = $TileMap2
onready var tilemap3 = $TileMap3
var island_cells = []
var rainbow_cells = []
var rainbow_path = "res://Scenes/Levels/Items/Rainbow.tscn"

func _ready():
	cell_size = tilemap.get_cell_size() * tilemap.scale
	if use_seed:
		ran_generator.set_seed(seed_id)
	
func refresh_generation():
	# generate a big island in the center and spread out
	generate_island(Vector2.ZERO, 2)
	for i in range(island_count):
		var ran = ran_generator.randi_range(0, 7)
		var island_dir = (Vector2.ZERO + dirs[ran]) * ran_generator.randf_range(cell_num / 4, cell_num)
		generate_island(island_dir)
	generate_obstruct()

func generate_island(island_center, scale = 1):
	var points = [island_center] 
	while points.size() < cell_num * scale:
		var ran = ran_generator.randi_range(0, points.size() - 1)
		for dir in dirs:
			if points.count(points[ran] + dir) <= 0:
				points.append(points[ran] + dir)
	for point in points:
		var dir = get_cell_dir(point, points)
		tilemap.set_cell(point.x, point.y, dir)
	island_cells.append(points)

func connect_islands():
	for i in range(island_cells.size() - 1):
		var island = island_cells[i]
		for j in range(i+1, island_cells.size()):
			var other_island = island_cells[j]
			var rainbow = load(rainbow_path).instance()
			get_node("RainbowGroup").add_child(rainbow)
			var point_to_other = other_island[0] - island[0]
			var middle_point = (other_island[0] + island[0]) * 0.5
			rainbow.set_global_position(get_pos_by_cell(middle_point))
			var angle = point_to_other.angle() + PI/2
			rainbow.set_rotation(angle)
			rainbow.set_scale(Vector2(2, point_to_other.length()))

func get_pos_by_cell(cell, middle = false):
	if middle:
		return cell_size * scale * cell + cell_size * 0.5 * scale
	return cell_size * scale * cell
	
func get_cell_dir(point, points):
	var test_dirs = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1)]
	var test_count = []
	for i in range(test_dirs.size()):
		var dir = test_dirs[i]
		if points.count(point + dir) <= 0:
			test_count.append(i)
	if test_count.size() <= 0:
		return 8
	elif test_count.size() == 1:
		# 1230 1357
		var edge1 = [7, 1, 3, 5]
		return edge1[test_count[0]]
	else:
		# 0123 0246
		if test_count[0] == 0 and test_count[1] == 3:
			return 6
		return test_count[0] * 2

func generate_obstruct():
	var first_cells = island_cells[0]
	var second_cells = []
	for point in first_cells:
		var dir = get_cell_dir(point, first_cells)
		if dir == 8 and point != Vector2.ZERO:
			var spawn = ran_generator.randf()
			if spawn < 0.2:
				dir = ran_generator.randi_range(9, 14)
				tilemap2.set_cell(point.x, point.y, dir)
				second_cells.append(point)
		if dir in [0, 2, 4, 6]:
			var light_pos = tilemap.map_to_world(point) * scale
			light_pos += cell_size * 0.5
			spawn_light(light_pos, dir == 0 or dir == 6)
	island_cells.append(second_cells)

func generate_enemies():
	var first_cells = island_cells[0]
	var temp_enemies_count = enemy_count
	for point in first_cells:
		var dir = get_cell_dir(point, first_cells)
		if dir == 8 and point != Vector2.ZERO and not point in island_cells[1]:
			if temp_enemies_count > 0:
				var enemy_pos = tilemap.map_to_world(point) * scale
				enemy_pos += cell_size * 0.5
				var mouse = spawn_mouse(enemy_pos)
				temp_enemies_count -= 1
				mouse.connect("Death", self, "generate_gate")
	
func spawn_coke(pos = Vector2.ZERO):
	var coke = load("res://Scenes/Enemies/Coke.tscn").instance()
	coke.set_global_position(pos)
	get_node("/root/World").add_child(coke)
	return coke

func spawn_mouse(pos = Vector2.ZERO):
	var mice = load("res://Scenes/Enemies/Mouse.tscn").instance()
	mice.set_global_position(pos)
	get_node("/root/World").add_child(mice)
	return mice

func spawn_light(pos = Vector2.ZERO, flip = false):
	var light = load("res://Scenes/Levels/Items/RoadLamp.tscn").instance()
	light.set_global_position(pos)
	light.get_node("AnimatedSprite").set_flip_h(flip)
	get_node("/root/World").add_child(light)
	return light

func spawn_bonus(pos = Vector2.ZERO):
	var bonus = load("res://Scenes/Levels/Items/Chest.tscn").instance()
	bonus.set_global_position(pos)
	get_node("/root/World").add_child(bonus)
	return bonus

func generate_gate(enemy):
	enemy_count -= 1
	if enemy_count <= 0:
		# generate bonus
		spawn_bonus(enemy.get_global_position())
		var rainbow = load(rainbow_path).instance()
		get_node("RainbowGroup").add_child(rainbow)
		var first_cells = island_cells[0]
		# choose two or three direction to be gate
		var gate_count = ran_generator.randi_range(2, 3)
		var ok_cells = []
		for i in range(4):
			ok_cells.append([])
		for point in first_cells:
			var dir = get_cell_dir(point, first_cells)
			if dir in [1, 3, 5, 7]:
				ok_cells[(dir - 1) / 2].append(point)
		var rainbow_dirs = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
		
		# only use cells in the border 
		for i in range(ok_cells.size()):
			ok_cells[i] = find_most_dir_cells(ok_cells[i], rainbow_dirs[i])
		
		for i in range(ok_cells.size()):
			var ok_dir = ok_cells[i]
			if gate_count <= 0:
				break
			var ok_cell = Util.pick_rand_item(ok_dir, ran_generator)
			for j in range(20):
				ok_cell += rainbow_dirs[i]
				# horizontal and vertical have different type
				if i % 2 == 1:
					tilemap.set_cell(ok_cell.x, ok_cell.y, 15, true, false, true)
				else:
					tilemap.set_cell(ok_cell.x, ok_cell.y, 15)
				rainbow_cells.append(ok_cell)
			gate_count -= 1

# ex: find the most up cell in the cells
func find_most_dir_cells(cells, dir):
	var max_val = -INF
	var ok_cells = []
	var is_neg = dir.x < 0 or dir.y < 0
	for i in range(cells.size()):
		var cell = cells[i]
		var use_val = cell.x
		if dir.x == 0:
			use_val = cell.y
		if is_neg:
			use_val = -1 * use_val
		if max_val < use_val:
			max_val = use_val
	for i in range(cells.size()):
		var cell = cells[i]
		var use_val = cell.x
		if dir.x == 0:
			use_val = cell.y
		if is_neg:
			use_val = -1 * use_val
		if max_val == use_val:
			ok_cells.append(cells[i])
	return ok_cells
