extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_node("/root/World/Player")
var return_to_black = true
func _ready():
	set_as_toplevel(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_position(get_global_mouse_position())
	set_rotation(get_rotation() + delta)
#	var new_color = get_self_modulate()
#	if return_to_black:
#		new_color -= Color.white * delta
#	else:
#		new_color += Color.white * delta
#	new_color.a = 1
#	set_self_modulate(new_color)
#	if new_color.r <= 0:
#		return_to_black = false
#	elif new_color.r >= 1:
#		return_to_black = true
	var player_to_mouse = player.get_global_position() - get_global_position()
	player.get_node("Camera2D").set_offset(player_to_mouse / -8)
