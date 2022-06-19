extends Sprite

var last_shoot_time = 0
export var shoot_interval = 0.1
export var bullet_speed = 300
export (float) var ammo_expense = 10
export var power = 5
export var bullet_path = "res://Scenes/Guns/Bullet.tscn"
onready var player = get_node("..")
onready var animator = get_node("AnimationPlayer")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var animation = animator.get_animation("Shoot")
	if animation:
		animation.set_loop(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	var angle = Vector2.UP.angle_to(get_node("..").self_to_target)
	var anim = ""
#	if abs(angle) < PI / 2:
#		anim += "Back"
	if last_shoot_time > 0:
		last_shoot_time -= delta

func create_bullet(velocity, ignore_interval = false):
	if last_shoot_time > 0 and !ignore_interval:
		return
	if !ignore_interval:
		last_shoot_time = shoot_interval
	var bullet = load(bullet_path).instance()
	get_node("/root/World/BulletGroup").add_child(bullet)
	bullet.init(player)
	bullet.set_global_position(get_global_position())
	bullet.linear_velocity = velocity.normalized()* bullet_speed
	# anim
	if animator.get_current_animation() != "Shoot":
		animator.set_current_animation("Shoot")
