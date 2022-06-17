class_name Player
extends KinematicBody2D
# class_name Player

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var horizontal_speed = 250.0
export var vertical_speed = 250.0
export var color = Color(1.0, 1.0, 1.0, 1.0)
var velocity = Vector2.ZERO
var self_to_mouse = Vector2.ZERO
var angle = 0
var wait_anim = ""
var state = "Idle"
var is_hurting = false
onready var gun = get_node("Gun")
export var gun_radius = 20
export var gun_offset = Vector2(5, 15)
export var roll_distance = 400
export var hurt_time = 1
export var visible_internal = 0.2
var visible_recorder = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Util.set_color(get_node("PlayerSprite").material, color)
	$AnimationPlayer.connect("animation_finished", self, "_on_anim_finished")
	$HurtTimer.wait_time = hurt_time
	$HurtTimer.connect("timeout", self, "stop_hurt_timer")

func _physics_process(delta):
	move(delta)
	update_gun(delta)
	if not $HurtTimer.is_stopped():
		if visible_recorder > visible_internal + delta:
			set_visible(false)
			visible_recorder = 0
		else:
			set_visible(true)
			visible_recorder += delta
	elif not is_visible():
		set_visible(true)
	

func move(delta):
	if Input.is_action_just_pressed("roll"):
		roll()
	velocity = Vector2.ZERO
	if Input.get_action_strength("left"):
		velocity.x += -Input.get_action_strength("left") * horizontal_speed
	if Input.get_action_strength("right"):
		velocity.x += Input.get_action_strength("right") * horizontal_speed
	if Input.get_action_strength("up"):
		velocity.y += -Input.get_action_strength("up") * vertical_speed
	if Input.get_action_strength("down"):
		velocity.y += Input.get_action_strength("down") * vertical_speed
	if wait_anim.length() <= 0:
		move_and_slide(velocity)
		self_to_mouse = (get_global_mouse_position() - get_position()).normalized()
	elif wait_anim == "Roll" or wait_anim == "BackRoll":
		move_and_slide(self_to_mouse * roll_distance)
	
	angle = Vector2.UP.angle_to(self_to_mouse)
	if angle < 0:
		get_node("PlayerSprite").set_flip_h(true)
	else:
		get_node("PlayerSprite").set_flip_h(false)
	set_anim()
	
func update_gun(delta):
	if Input.is_action_pressed("shoot"):
		gun.createBullet()
	# gun position and rotation and layer
	var angle = Vector2.UP.angle_to(self_to_mouse)
	var offset = gun_offset
	if angle < 0:
		offset.x = -offset.x
	gun.set_global_position(get_global_position() + self_to_mouse * gun_radius + offset)
	if angle < 0:
		gun.set_scale(Vector2(1, -1))
	else:
		gun.set_scale(Vector2(1, 1))
	gun.set_rotation(angle - PI / 2)
	
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
	angle = Vector2.UP.angle_to(self_to_mouse)
	if angle < PI / 2 and angle > -1 * PI/2:
		anim += "Back"
	if velocity.length() > 0:
		anim += "Walk"
	else:
		anim += "Idle"
	if animator.get_animation(anim) != null and animator.get_current_animation() != anim:
		animator.play(anim)
		state = anim

func roll():
	$Gun.visible = false
	if angle < PI / 2 and angle > -1 * PI/2:
		set_anim("BackRoll", true)
	else:
		set_anim("Roll", true)


func _on_anim_finished(anim_name):
	if anim_name == wait_anim:
		wait_anim = "" # Replace with function body.
		$Gun.visible = true
		
func get_hurt(amount):
	if amount < 0:
		print("No Hurt Amount")
		return
	if not $HurtTimer.is_stopped():
		return
	var color = get_node("PlayerSprite").material.get_shader_param("color")
	color.a -= float(amount) / 100.0
	$HurtTimer.start()
	if color.a > 0:
		Util.set_color(get_node("PlayerSprite").material, color)
	else:
		queue_free()

func stop_hurt_timer():
	$HurtTimer.stop()
