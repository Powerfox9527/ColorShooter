class_name Actor
extends KinematicBody2D

var velocity = Vector2.ZERO
var angle = 0
var wait_anim = ""
var self_to_target = Vector2.ZERO
onready var animator = get_node("AnimationPlayer")
onready var gun = get_node("Gun")
onready var sprite = get_node("ActorSprite")
export var speed = 300
export var hurt_time = 0.1
export var gun_radius = 20
export var gun_offset = Vector2(5, 15)
export var attack = 10
export var defense = 10
export var color = Color(0, 0, 0, 1)
var state = ""

func _ready():
	Util.set_color(sprite.material, color)
	animator.connect("animation_finished", self, "_on_anim_finished")

func set_color(new_color):
	color = new_color
	Util.set_color(sprite.material, new_color)

func update_gun(delta):
	# gun position and rotation and layer
	var angle = Vector2.UP.angle_to(self_to_target)
	var offset = gun_offset
	if angle < 0:
		offset.x = -offset.x
	gun.set_global_position(get_global_position() + self_to_target * gun_radius + offset)
	if angle < 0:
		gun.set_scale(Vector2(1, -1))
	else:
		gun.set_scale(Vector2(1, 1))
	if angle < PI / 2 and angle > -1 * PI/2:
		move_child(gun, 0)
	else:
		move_child(gun, get_child_count() - 1)
	gun.set_rotation(angle - PI / 2)
	
### anim
func set_move_anim():
	var anim = ""
	if angle < PI / 2 and angle > -1 * PI/2:
		anim += "Back"
	if velocity.length() > 0:
		anim += "Walk"
	else:
		anim += "Idle"
	if animator.get_animation(anim) != null and animator.get_current_animation() != anim:
		animator.play(anim)

func set_anim(anim, wait = false):
	if wait_anim.length() > 0:
		return
	var animator = get_node("AnimationPlayer")
	var animation = animator.get_animation(anim)
	if anim.length() > 0 and animation != null:	
		if wait:
			wait_anim = anim
		animation.set_loop(false)
		animator.play(anim)
		return
		
func _on_anim_finished(anim_name):
	pass # implemented by child class

### hurt
func dead():
	pass # implemented by child class

func get_hurt(hurt_color):
	pass
