extends Sprite

var color = Color(0.0, 0.0, 0.0, 1.0)
export var speed = 30
var velocity = Vector2(0.0, 0.0)
var life_span = 5.0
var player


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	life_span -= delta
	if life_span <= 0:
		queue_free()
	set_global_position(get_global_position() + velocity * speed)
	get_node("Light2D").color = material.get_shader_param("color")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
