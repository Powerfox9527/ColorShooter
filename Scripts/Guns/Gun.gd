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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	var angle = Vector2.UP.angle_to(get_node("..").self_to_target)
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

func create_bullet(velocity):
	if last_shoot_time > 0:
		return
	last_shoot_time = shoot_interval
	var bullet = load(bullet_path).instance()
	get_node("/root/World/BulletGroup").add_child(bullet)
	var player = get_node("..")
	var color = player.color
	color.r -= min(ammo_expense / 100 * color.r, color.r)
	color.g -= min(ammo_expense / 100 * color.g, color.g)
	color.b -= min(ammo_expense / 100 * color.b, color.b)
	var self_to_target = player.self_to_target
	bullet.set_color(color)
	bullet.power = power
	bullet.set_global_position(get_global_position())
	bullet.linear_velocity = velocity.normalized()* bullet_speed
	bullet.set_collision_layer(player.get_collision_layer())
	bullet.set_collision_mask(player.get_collision_mask())
	bullet.sender = player
	if bullet.sender.has_method("set_color"):
		bullet.sender.set_color(color)
