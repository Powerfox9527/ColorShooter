extends Sprite
# class_name Player

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var horizontal_speed = 7.0
var vertical_speed = 7.0
export var color = Color(1.0, 1.0, 1.0, 1.0)
var velocity = Vector2.ZERO
var self_to_mouse = Vector2.ZERO
onready var gun = get_node("Gun")
export var gunradius = 50
export var gunOffset = Vector2(0, 7)

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
		gun.createBullet()
	
	self_to_mouse = (get_global_mouse_position() - get_position()).normalized()
	var offset = Vector2(0, -10)
	gun.set_global_position(get_global_position() + self_to_mouse * gunradius + gunOffset)
	gun.set_rotation(Vector2.UP.angle_to(self_to_mouse) - PI / 2)
	
	setAnimation()

	# setColor(color + Color(delta * 3, delta * 4, delta * 5, 0))

	
func setAnimation(anim = ""):
	var animator = get_node("AnimationPlayer")
	if animator:
		if anim.length() > 0:
			animator.set_current_animation(anim)
			return
		var angle = Vector2.UP.angle_to(self_to_mouse)
		if angle < 0:
			set_flip_h(true)
		else:
			set_flip_h(false)
		
		if angle < PI / 2 and angle > -1 * PI/2:
			anim += "Back" 
		if velocity.length() > 0:
			anim += "Walk"
		else:
			anim += "Idle"
		animator.set_current_animation(anim)
		
		
