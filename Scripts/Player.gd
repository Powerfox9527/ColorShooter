extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var horizontal_speed = 7.0
var vertical_speed = 7.0
var color = Color(1.0, 0.0, 1.0, 1.0)
var velocity = Vector2.ZERO
var self_to_mouse = Vector2.ZERO

var last_shoot_time = 0
export var shoot_interval = 0.3
# Called when the node enters the scene tree for the first time.
func _ready():
	Util.setColor(material, color)

func _process(delta):
	velocity = Vector2.ZERO
	if Input.get_action_strength("left"):
		velocity.x += -Input.get_action_strength("left") * horizontal_speed
	if Input.get_action_strength("right"):
		velocity.x += Input.get_action_strength("right") * horizontal_speed
	if Input.get_action_strength("up"):
		velocity.y += -Input.get_action_strength("up") * vertical_speed
	if Input.get_action_strength("down"):
		velocity.y += Input.get_action_strength("down") * vertical_speed
	translate(velocity)
	
	if Input.is_action_pressed("shoot"):
		createBullet()
	
	self_to_mouse = get_global_mouse_position() - get_position()
	set_rotation(Vector2.UP.angle_to(self_to_mouse))
	
	if last_shoot_time > 0:
		last_shoot_time -= delta
	# setColor(color + Color(delta * 3, delta * 4, delta * 5, 0))
	
func createBullet():
	if last_shoot_time > 0:
		return
	last_shoot_time = shoot_interval
	var bullet = preload("res://Scenes/Bullet.tscn").instance()
	get_node("/root").add_child(bullet)
	Util.setColor(bullet.material, color)
	bullet.set_global_position(get_position())
	bullet.velocity = self_to_mouse / self_to_mouse.length()
