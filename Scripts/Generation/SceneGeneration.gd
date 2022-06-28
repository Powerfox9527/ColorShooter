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
var dirs = [Vector2(0, -1), Vector2(1, 0), Vector2(1, 0), Vector2(0, 1), 
Vector2(0, 1), Vector2(-1, 0), Vector2(-1, 0), Vector2(0, -1)]
var cell_half_num = 20
var ran_generator = RandomNumberGenerator.new()
export var seed_id = 0
onready var tilemap = $TileMap
func _ready():
	cell_size = tilemap.get_cell_size() * tilemap.scale
	ran_generator.set_seed(seed_id)
	var points = [Vector2.ZERO]
	var used_dirs = [ran_generator.randi_range(0, 7)]
	for i in range(cell_half_num):
		var ran = get_ran_follower(used_dirs[i])
		used_dirs.append(ran)
	for dir in used_dirs:
		points.append(points.back() + dirs[dir])
		tilemap.set_cell(points.back().x, points.back().y, dir)
	print(points)
	print(used_dirs)
	get_node("/root/World").set_debug_points([Vector2.ZERO])

func get_pos_by_cell(cell, tile_layer = 0):
	return cell_size * scale * cell

func get_ran_follower(tile):
	var ran = 0
	# if tile is even, then the follower could only be itself+1 or itself + 2
	if tile % 2 == 0:
		ran = ran_generator.randi_range(tile + 1, tile + 2)
	# if tile is odd, then the follower could only be itself or itself+1
	else:
		ran = ran_generator.randi_range(tile, tile + 1)
	# avoid 7
	return ran % 8
