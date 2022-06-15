extends Sprite

var last_shoot_time = 0
export var shoot_interval = 0.1
export var bullet_speed = 300
onready var player = get_node("..")
onready var animator = get_node("AnimationPlayer")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	var angle = Vector2.UP.angle_to(get_node("..").self_to_mouse)
	var anim = ""
#	if abs(angle) < PI / 2:
#		anim += "Back"
	if last_shoot_time > 0:
		last_shoot_time -= delta

	if Input.is_action_pressed("shoot"):
		anim += "Shoot"
	else:
		anim += "Idle"
	if animator.get_current_animation() != anim:
		animator.set_current_animation(anim)

func createBullet():
	if last_shoot_time > 0:
		return
	last_shoot_time = shoot_interval
	var bullet = load("res://Scenes/Guns/Bullet.tscn").instance()
	get_node("/root/World").add_child(bullet)
	var color = get_node("..").color
	var self_to_mouse = get_node("..").self_to_mouse
	bullet.set_color(color)
	bullet.set_global_position(get_global_position())
	bullet.linear_velocity = self_to_mouse / self_to_mouse.length() * bullet_speed
	bullet.sender = get_node("..")
