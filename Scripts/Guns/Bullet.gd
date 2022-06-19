class_name Bullet
extends RigidBody2D

var power = 5
var sender

func _ready():
	connect("body_entered", self, "_on_RigidBody2D_body_entered")

func set_color(color):
	get_node("Light2D").color = color
	get_node("Sprite").material.set_shader_param("color", color)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Timer.is_stopped():
		queue_free()

func disappear():
	queue_free()

func _on_RigidBody2D_body_entered(body):
	if body.has_method("get_hurt") and body != sender:
		body.get_hurt(Util.multiply_color(power, get_node("Light2D").color))
	disappear()
