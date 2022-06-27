extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_position(get_global_mouse_position())
	set_rotation(get_rotation() + delta)

