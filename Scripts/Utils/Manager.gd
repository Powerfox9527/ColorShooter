extends Node2D
var debug_points = []
var debug_points_red = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)

func _draw():
	for point in debug_points:
		draw_circle(point, 10, Color.black)
	for point in debug_points_red:
		draw_circle(point, 10, Color.red)

func set_debug_points(points):
	debug_points = points
	update()

func set_debug_points_red(points):
	debug_points_red = points
	update()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
