extends AnimatedSprite
var colour = Color(0.0, 0.0, 0.0, 1.0)
var speed = 1.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	move_local_y(speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func setColour(new_colour):
	new_colour.r = min(1.0, new_colour.r)
	new_colour.g = min(1.0, new_colour.g)
	new_colour.b = min(1.0, new_colour.b)
	colour = new_colour
	material.set_shader_param("colour", new_colour)
