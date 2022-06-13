extends Node

class_name Util
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func setColor(material, new_color):
	new_color.r = min(1.0, new_color.r)
	new_color.g = min(1.0, new_color.g)
	new_color.b = min(1.0, new_color.b)
	material.set_shader_param("color", new_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
