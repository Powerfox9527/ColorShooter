class_name Chest
extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_body_entered")

func _body_entered(body):
	if body is Player and not is_open:
		var animation = $AnimationPlayer.get_animation("default")
		animation.set_loop(false)
		$AnimationPlayer.play("default")
		is_open = true

