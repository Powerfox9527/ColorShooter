class_name Player
extends KinematicBody2D
# class_name Player

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var horizontal_speed = 250.0
var vertical_speed = 250.0
export var color = Color(1.0, 1.0, 1.0, 1.0)
var velocity = Vector2.ZERO
var self_to_mouse = Vector2.ZERO
onready var gun = get_node("Gun")
export var gunradius = 20
export var gunOffset = Vector2(5, 15)

# Called when the node enters the scene tree for the first time.
func _ready():
	Util.setColor(get_node("PlayerSprite").material, color)
	gun.get_node("Hand").set_texture(get_node("Hand").texture)

func _physics_process(delta):
	velocity = Vector2.ZERO
	if Input.get_action_strength("left"):
		velocity.x += -Input.get_action_strength("left") * horizontal_speed
	if Input.get_action_strength("right"):
		velocity.x += Input.get_action_strength("right") * horizontal_speed
	if Input.get_action_strength("up"):
		velocity.y += -Input.get_action_strength("up") * vertical_speed
	if Input.get_action_strength("down"):
		velocity.y += Input.get_action_strength("down") * vertical_speed
	move_and_slide(velocity)
	
	if Input.is_action_pressed("shoot"):
		gun.createBullet()
	
	var angle = Vector2.UP.angle_to(self_to_mouse)
	var offset = gunOffset
	if angle < 0:
		offset.x = -offset.x
	self_to_mouse = (get_global_mouse_position() - get_position()).normalized()
	gun.set_global_position(get_global_position() + self_to_mouse * gunradius + offset)

	if angle < 0:
		gun.set_scale(Vector2(1, -1))
	else:
		gun.set_scale(Vector2(1, 1))
	gun.set_rotation(angle - PI / 2)

	
	set_anim()

	# setColor(color + Color(delta * 3, delta * 4, delta * 5, 0))

	
func set_anim(anim = ""):
	var animator = get_node("AnimationPlayer")
	if anim.length() > 0:
		animator.set_current_animation(anim)
		return
	var angle = Vector2.UP.angle_to(self_to_mouse)
	if angle < 0:
		get_node("PlayerSprite").set_flip_h(true)
	else:
		get_node("PlayerSprite").set_flip_h(false)
	
	if angle < PI / 2 and angle > -1 * PI/2:
		anim += "Back" 
	if velocity.length() > 0:
		anim += "Walk"
	else:
		anim += "Idle"
	if animator.get_current_animation() != anim:
		animator.set_current_animation(anim)
		
		
