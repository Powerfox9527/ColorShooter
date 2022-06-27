extends Node2D
#Here is the fastest algorithm I know that generates each convex polygon with equal probability. The output has exactly N vertices, and the running time is O(N log N), so it can generate even large polygons very quickly.
#Generate two lists, X and Y, of N random integers between 0 and C. Make sure there are no duplicates.
#Sort X and Y and store their maximum and minimum elements.
#Randomly divide the other (not max or min) elements into two groups: X1 and X2, and Y1 and Y2.
#Re-insert the minimum and maximum elements at the start and end of these lists (minX at the start of X1 and X2, maxX at the end, etc.).
#Find the consecutive differences (X1[i + 1] - X1[i]), reversing the order for the second group (X2[i] - X2[i + 1]). Store these in lists XVec and YVec.
#Randomize (shuffle) YVec and treat each pair XVec[i] and YVec[i] as a 2D vector.
#Sort these vectors by angle and then lay them end-to-end to form a polygon.
#Move the polygon to the original min and max coordinates.
var cell_size = Vector2(32, 32)
var dirs = [Vector2(-1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2(1, -1)]
var cell_half_num = 2
var ran_generator = RandomNumberGenerator.new()
export var seed_id = 0
func _ready():
	ran_generator.set_seed(seed_id)
	var points = [Vector2.ZERO]
	var used_dirs = []
	for i in range(cell_half_num):
		var ran = ran_generator.randi_range(0, 7)
		used_dirs.append(dirs[ran])
		points.append(get_pos_by_cell(points[i] / cell_size + dirs[ran]))
	for i in range(cell_half_num):
		used_dirs.append(used_dirs[cell_half_num - i - 1] * -1)
		points.append(get_pos_by_cell(points[i] / cell_size - used_dirs[cell_half_num - i - 1]))
	get_node("/root/World").set_debug_points(points)

func get_pos_by_cell(cell, tile_layer = 0):
	return cell_size * scale * cell
