extends RigidBody2D

export var life_span = 3.0
export var power = 2
var player

	# set_global_position(get_global_position() + velocity * speed)
func setColor(color):
	get_node("Light2D").color = color
	get_node("Sprite").material.set_shader_param("color", color)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life_span -= delta
	if life_span <= 0:
		queue_free()


func _on_RigidBody2D_body_entered(body):
	if body is Enemy:
		body.get_hurt(power)
		queue_free()
