class_name Enemy
extends KinematicBody2D
var velocity = Vector2.ZERO
var self_to_player = Vector2.ZERO
var angle = 0
var wait_anim = ""
var state = ""
onready var animator = get_node("AnimationPlayer")
export var hurt_time = 0.1 
export var speed = 3

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("input_event", self, "_on_Coke_input_event")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self_to_player = (get_node("/root/World/Player").get_global_position() - get_global_position()).normalized()
	set_anim()
	velocity = self_to_player * speed
	angle = Vector2.UP.angle_to(self_to_player)
	if angle < 0:
		get_node("Sprite").set_flip_h(true)
	else:
		get_node("Sprite").set_flip_h(false)
	
	var collision = move_and_collide(velocity)
	if collision != null and collision.collider is Player:
		collision.collider.state == "hurt"

func set_anim(anim = "", wait = false):
	if wait_anim.length() > 0:
		return
	var animator = get_node("AnimationPlayer")
	
	if anim.length() > 0 and animator.get_animation(anim) != null:	
		if wait:
			wait_anim = anim
		animator.play(anim)
		state = anim
		return
	angle = Vector2.UP.angle_to(self_to_player)
	if angle < PI / 2 and angle > -1 * PI/2:
		anim += "Back"
	if velocity.length() > 0:
		anim += "Walk"
	else:
		anim += "Idle"
	if animator.get_animation(anim) != null and animator.get_current_animation() != anim:
		animator.play(anim)
		state = anim

func get_hurt(amount):
	if amount < 0:
		print("No Hurt Amount")
	var color = get_node("Sprite").material.get_shader_param("color")
	color.a -= float(amount) / 100.0
	if color.a > 0:
		get_node("Light2D").visible = true
		yield(get_tree().create_timer(hurt_time), "timeout")
		get_node("Light2D").visible = false
		Util.setColor(get_node("Sprite").material, color)
	else:
		queue_free()
