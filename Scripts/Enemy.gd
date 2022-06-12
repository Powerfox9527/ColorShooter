class_name Enemy
extends KinematicBody2D
var velocity = Vector2.ZERO
var self_to_player = Vector2.ZERO

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_anim()

func set_anim(anim = ""):
	var animator = get_node("AnimationPlayer")
	self_to_player = get_node("/root/World/Player").get_global_position() - get_global_position()
	if animator:
		if anim.length() > 0:
			animator.set_current_animation(anim)
			return
		var angle = Vector2.UP.angle_to(self_to_player)
		
		if angle < PI / 2 and angle > -1 * PI/2:
			anim += "Back" 
		if velocity.length() > 0:
			anim += "Walk"
		else:
			anim += "Idle"
		if animator.get_current_animation() != anim:
			animator.set_current_animation(anim)

func get_hurt(amount):
	if amount < 0:
		print("No Hurt Amount")
	var color = get_node("Sprite").material.get_shader_param("color")
	color.a -= amount / 100
	if color.a > 0:
		Util.setColor(get_node("Sprite").material, color)
	else:
		queue_free()
