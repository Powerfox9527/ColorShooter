extends Node2D
var debug_points = []
var timers = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_user_signal("Inited")
	$Navigation2D.set_scale($Generator.get_scale())
	$Generator.refresh_generation()
	$Navigation2D.refresh_navigation()
	$Generator.generate_enemies()
	emit_signal("Inited")

func _draw():
	for point in debug_points:
		draw_circle(point, 10, Color.black)

func set_debug_points(points):
	debug_points = points
	update()
