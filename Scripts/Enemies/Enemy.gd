class_name Enemy
extends KinematicBody2D
var velocity = Vector2.ZERO
var self_to_player = Vector2.ZERO
var angle = 0
var wait_anim = ""
var state = "chase"
var is_in_state = false
var color = Color(0, 0, 0, 0)
onready var gun = get_node("Gun")
export var gun_radius = 0
export var gun_offset = Vector2(100, 85)
onready var animator = get_node("AnimationPlayer")
export var hurt_time = 0.1 
export var speed = 3
export var bullet_speed = 200

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$StateTimer.connect("timeout", self, "generate_state")
	$AnimationPlayer.connect("animation_finished", self, "_on_anim_finished")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self_to_player = (get_node("/root/World/Player").get_global_position() - get_global_position()).normalized()
	set_anim()
	angle = Vector2.UP.angle_to(self_to_player)
	if angle < 0:
		get_node("Sprite").set_flip_h(true)
	else:
		get_node("Sprite").set_flip_h(false)
	color = get_node("Sprite").material.get_shader_param("color")
	update_gun(delta)
	if is_in_state:
		return
	is_in_state = true
	if state == "chase":
		chase()
	elif state == "color_change":
		color_change()
	elif state == "simple_shoot":
		simple_shoot()
	elif state == "circle_shoot":
		circle_shoot()
	
	
func update_gun(delta):
	# gun position and rotation and layer
	var angle = Vector2.UP.angle_to(self_to_player)
	var offset = gun_offset
	if angle < 0:
		offset.x = -offset.x
	gun.set_global_position(get_global_position() + self_to_player * gun_radius + offset)
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
		var animation = animator.get_animation(anim)
		animation.set_loop(false)
		animator.play(anim)
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

func get_hurt(amount):
	if amount < 0:
		print("No Hurt Amount")
	var color = get_node("Sprite").material.get_shader_param("color")
	color.a -= float(amount) / 100.0
	if color.a > 0:
		if angle < PI / 2 and angle > -1 * PI/2:
			set_anim("BackHurt", true)
		else:
			set_anim("Hurt", true)
		Util.set_color(get_node("Sprite").material, color)
	else:
		dead()
		queue_free()
	
func generate_state():
	$StateTimer.wait_time = randi() % 3 + 3 # 每3-5s换一次模式
	var value = randf()
	if value < 0.4:
		state =  "simple_shoot"
	elif value < 0.6:
		state =  "chase"
	elif value < 0.7:
		state =  "color_change"
	elif value < 1:
		state =  "circle_shoot"
	print(state)
		
func chase():
	self_to_player = (get_node("/root/World/Player").get_global_position() - get_global_position()).normalized()
	velocity = self_to_player * speed
	var collision = move_and_collide(velocity)
	if collision != null and collision.collider is Player:
		collision.collider.get_hurt(color)
	is_in_state = false

func color_change():
	color = get_node("Sprite").material.get_shader_param("color")
	color.r = randi() % 2
	color.g = randi() % 2
	color.b = randi() % 2
	while color.r + color.g + color.b <= 0:
		color.r = randi() % 2
		color.g = randi() % 2
		color.b = randi() % 2
	set_anim("Jump", true)
	yield(get_tree().create_timer(0.3), "timeout")
	Util.set_color(get_node("Sprite").material, color)
	generate_state()
	is_in_state = false

func shoot(bullet_velocitys):
	for velocity in bullet_velocitys:
		createBullet(velocity)
		
func circle_shoot():
	if wait_anim == "Jump":
		return
	var bullet_velocities = []
	var velocity = Vector2.UP
	for i in range(12):
		velocity = velocity.rotated(2 * PI / 12)
		bullet_velocities.append(velocity)
	set_anim("Jump", true)
	yield(get_tree().create_timer(0.3), "timeout")
	shoot(bullet_velocities)
	is_in_state = false
	generate_state()
	
func simple_shoot():
	for i in range(5):
		self_to_player = (get_node("/root/World/Player").get_global_position() - get_global_position()).normalized()
		yield(get_tree().create_timer(0.4), "timeout")
		shoot([self_to_player])
	is_in_state = false

func createBullet(velocity):
	var bullet = load("res://Scenes/Guns/EnemyBullet.tscn").instance()
	get_node("/root/World").add_child(bullet)
	var color = get_node("Sprite").material.get_shader_param("color")
	bullet.set_color(color)
	bullet.set_global_position(gun.get_global_position() + self_to_player * 50)
	bullet.linear_velocity = velocity * bullet_speed
	bullet.sender = self

func dead():
	var bullet_velocities = []
	var velocity = Vector2.UP
	for i in range(12):
		velocity = velocity.rotated(2 * PI / 12)
		bullet_velocities.append(velocity)
	set_anim("Jump", true)
	shoot(bullet_velocities)
	generate_state()

func _on_anim_finished(anim_name):
	if anim_name == wait_anim:
		wait_anim = "" # Replace with function body.
