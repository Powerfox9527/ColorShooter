extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var horizontal_speed = 10.0
var vertical_speed = 15.0
var colour = Vector3(1.0, 1.0, 1.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	setColour(Vector3(1.0, 1.0, 1.0)) # Replace with function body.

func _process(delta):
	if Input.get_action_strength("left"):
		move_local_x(-Input.get_action_strength("left") * horizontal_speed) 
	elif Input.get_action_strength("right"):
		move_local_x(Input.get_action_strength("right") * horizontal_speed)
	elif Input.get_action_strength("up"):
		move_local_y(-Input.get_action_strength("up") * vertical_speed)
	elif Input.get_action_strength("down"):
		move_local_y(Input.get_action_strength("down") * vertical_speed)
	setColour(Vector3(delta * 3, delta * 3, delta * 3))
	
func setColour(new_colour):
	colour = new_colour
	material.set_shader_param("Modulate", new_colour)
