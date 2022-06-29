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
var cell_num = 60
var ran_generator = RandomNumberGenerator.new()
export var seed_id = 0
export var use_seed = false
export var island_count = 6
onready var tilemap = $TileMap
var island_cells = []
var rainbow_path = "res://Scenes/Levels/Rainbow.tscn"

func _ready():
	cell_size = tilemap.get_cell_size() * tilemap.scale
	if use_seed:
		ran_generator.set_seed(seed_id)
	# generate a big island in the center and spread out
	generate_island(Vector2.ZERO, 2)
	for i in range(island_count):
		var ran = ran_generator.randi_range(0, 7)
		var island_dir = (Vector2.ZERO + dirs[ran]) * ran_generator.randf_range(cell_num / 4, cell_num)
		generate_island(island_dir)
	connect_islands()

func generate_island(island_center, scale = 1):
	var points = [island_center] 
	while points.size() < cell_num * scale:
		var ran = ran_generator.randi_range(0, points.size() - 1)
		for dir in dirs:
			if points.count(points[ran] + dir) <= 0:
				points.append(points[ran] + dir)
	for point in points:
		tilemap.set_cell(point.x, point.y, get_cell_dir(point, points))
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
			rainbow.set_scale(Vector2(1, point_to_other.length() * scale.y))

func get_pos_by_cell(cell):
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

