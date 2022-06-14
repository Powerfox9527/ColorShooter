extends RigidBody2D

export var power = 5
var player

func setColor(color):
	get_node("Light2D").color = color
	get_node("Sprite").material.set_shader_param("color", color)
	connect("body_entered", self, "_on_RigidBody2D_body_entered")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Timer.is_stopped():
		queue_free()


func _on_RigidBody2D_body_entered(body):
	if body is Enemy:
		body.get_hurt(power)
		queue_free()
