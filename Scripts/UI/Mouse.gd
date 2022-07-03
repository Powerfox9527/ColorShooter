extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_node("/root/World/Player")
func _ready():
	set_as_toplevel(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_position(get_global_mouse_position())
	set_rotation(get_rotation() + delta)
#	var image = get_viewport().get_texture().get_data()
#	image.lock()
#	var pixel_pos = get_global_mouse_position() + player.get_global_position()
#	var hit_color = image.get_pixel(int(pixel_pos.x), int(pixel_pos.y))
#	hit_color.a = 0
#	set_self_modulate(Color.white - hit_color)
	var player_to_mouse = player.get_global_position() - get_global_position()
	player.get_node("Camera2D").set_offset(player_to_mouse / -8)
