class_name Actor
extends KinematicBody2D

var velocity = Vector2.ZERO
var angle = 0
var wait_anim = ""
var self_to_target = Vector2.ZERO
onready var animator = get_node("AnimationPlayer")
onready var gun = get_node("Gun")
onready var sprite = get_node("ActorSprite")
onready var manager = get_node("/root/World")
onready var navigation = get_node("/root/World/Navigation2D")
onready var generator = get_node("/root/World/Generator")
export var speed = 300
export var hurt_time = 0.1
export var gun_radius = 20
export var gun_offset = Vector2(5, 15)
export (float) var attack = 10
export (float) var defense = 20
export var color = Color(0, 0, 0, 1)
var state = ""
var is_falling = false

func _ready():
	Util.set_color(sprite.material, color)
	animator.connect("animation_finished", self, "_on_anim_finished")
	gun_radius *= get_scale().x
	gun_offset *= get_scale().x
	gun.power = attack
	add_user_signal("Death", [self])

func _process(delta):
	fall()

func fall():
	var cell = navigation.get_cell_by_pos(get_global_position())
	var cells = generator.island_cells[0]
	if not cells.has(cell) and not is_falling:
		is_falling = true
		var distance = INF
		var closest_pos = Vector2.ZERO
		yield(get_tree().create_timer(0.2), "timeout")
		set_process(false)
		set_physics_process(false)
		set_anim("Fall", true)
		gun.set_visible(false)
		for ok_cell in cells:
			var ok_pos = navigation.get_pos_by_cell(ok_cell)
			if navigation.get_cell_value(ok_cell.x, ok_cell.y) == 1 and (ok_pos - get_global_position()).length() < distance:
				distance = (ok_pos - get_global_position()).length()
				closest_pos = ok_pos
		yield(get_tree().create_timer(0.3), "timeout")
		set_global_position(closest_pos)
		get_hurt(Color(1, 1, 1, 1))
		set_process(true)
		set_physics_process(true)
		gun.set_visible(true)
		is_falling = false

func set_color(new_color):
	color.r = min(max(0, new_color.r), 1)
	color.g = min(max(0, new_color.g), 1)
	color.b = min(max(0, new_color.b), 1)
	color.a = min(max(0, new_color.a), 1)
	Util.set_color(sprite.material, color)

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
	if wait_anim.length() > 0 or not animator.has_animation(anim):
		return
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
