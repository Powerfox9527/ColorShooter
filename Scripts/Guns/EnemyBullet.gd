extends Bullet

func set_color(color):
	get_node("Light2D").color = color
	get_node("Sprite").material.set_shader_param("color", color)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Timer.is_stopped():
		queue_free()


func _on_RigidBody2D_body_entered(body):
	if body is Player:
		body.get_hurt(get_node("Light2D").color)
		queue_free()
