extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null:
		player = get_node("/root/World/Player")
	var color = player.material.get_shader_param("color")
	get_node("RedBar:Range").set_value(color.r * 100)
	get_node("GreenBar:Range").set_value(color.g * 100)
	get_node("BlueBar:Range").set_value(color.b * 100)
