class_name Enemy
extends Actor

var is_in_state = false
var is_in_colliding
var dest_pos = Vector2.ZERO
var start_pos = Vector2.ZERO
onready var player = get_node("/root/World/Player")

func _ready():
	generate_state()
	$StateTimer.connect("timeout", self, "generate_state")
func _draw():
	var player_pos = get_node("/root/World/Player").get_global_position()
	var shape = $CollisionShape2D.shape
	var point = Util.get_raycast_point(get_global_position(), player_pos, shape.get_extents() * 5)
	# draw_circle(point, 5, Color.black)


func _physics_process(delta):
	self_to_target = (player.get_global_position() - get_global_position()).normalized()
	if wait_anim.length() <= 0:
		set_move_anim()
	angle = Vector2.UP.angle_to(self_to_target)
	if angle <= 0:
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)
	update_gun(delta)
	if is_in_state:
		return
	is_in_state = true
	if state == "chase":
		chase(delta)
	elif state == "color_change":
		color_change()
	elif state == "simple_shoot":
		simple_shoot()
	elif state == "circle_shoot":
		circle_shoot()
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if collision and collision.collider is Player:
				collision.collider.get_hurt(color)

### state
func generate_state():
	$StateTimer.wait_time = randi() % 3 + 3 # 每3-5s换一次模式
	var value = randf()
	if value < 0.4:
		state =  "simple_shoot"
	elif value < 0.5:
		state =  "chase"
	elif value < 0.7:
		state =  "color_change"
	elif value < 1:
		state =  "circle_shoot"
	state = "chase"
	print(state)
		
func chase(delta):
	var navigation = get_node("/root/World/Navigation2D")
	var player_pos = get_node("/root/World/Player").get_global_position()
	self_to_target = player_pos - get_global_position()
	var shape = $CollisionShape2D.shape
	start_pos = get_global_position()
	var path = navigation.get_simple_path(start_pos, player_pos)
	if path.empty():
		is_in_state = false
		return
	for i in range(path.size()):
		velocity = path[0] - start_pos
		# $Line2D2.points = [velocity.normalized() * speed, Vector2.ZERO]
		# test two dimension collision and interpolate them
		if velocity.x > 0:
			$RayCast2D.set_cast_to(Vector2(shape.extents.x * scale.x + velocity.x * speed * delta, 0))
		elif velocity.x < 0:
			$RayCast2D.set_cast_to(Vector2(-shape.extents.x * scale.x - velocity.x * speed * delta, 0))
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding() and velocity.x != 0:
			velocity.x = 0
			
		if velocity.y > 0:
			$RayCast2D.set_cast_to(Vector2(0, shape.extents.y * scale.y + velocity.y * speed * delta))
		elif velocity.y > 0:
			$RayCast2D.set_cast_to(Vector2(0, -shape.extents.y * scale.y - velocity.y * speed * delta))
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding() and velocity.y != 0:
			velocity.y = 0
		$Line2D.points = [velocity.normalized() * speed, Vector2.ZERO]
		move_and_slide(velocity.normalized() * speed)
		path.remove(0)
	is_in_state = false

func color_change():
	var new_color = Color.black
	new_color.r = randi() % 2
	new_color.g = randi() % 2
	new_color.b = randi() % 2
	while new_color.r + new_color.g + new_color.b <= 0:
		new_color.r = randi() % 2
		new_color.g = randi() % 2
		new_color.b = randi() % 2
	new_color.a = color.a
	set_anim("Jump", true)
	yield(get_tree().create_timer(0.3), "timeout")
	set_color(new_color)
	generate_state()
	is_in_state = false

func shoot(bullet_velocitys):
	for bullet_velocity in bullet_velocitys:
		gun.create_bullet(bullet_velocity, true)
		
func circle_shoot():
	var bullet_velocities = []
	var bullet_velocity = Vector2.UP
	for i in range(24):
		bullet_velocity = bullet_velocity.rotated(2 * PI / 24)
		bullet_velocities.append(bullet_velocity)
	set_anim("Jump", true)
	yield(get_tree().create_timer(0.3), "timeout")
	shoot(bullet_velocities)
	generate_state()
	is_in_state = false

	
func simple_shoot():
	for i in range(5):
		self_to_target = (player.get_global_position() - get_global_position()).normalized()
		yield(get_tree().create_timer(0.3), "timeout")
		shoot([self_to_target])
	is_in_state = false

### hurt
func get_hurt(hurt_color):
	set_color(Util.get_hurt_amount(color, hurt_color / defense, true))
	if color.a > 0:
		if angle < PI / 2 and angle > -1 * PI/2:
			set_anim("BackHurt", true)
		else:
			set_anim("Hurt", true)
	else:
		dead()
		queue_free()

func dead():
	var bullet_velocities = []
	var bullet_velocity = Vector2.UP
	color.a = 1
	for i in range(6):
		bullet_velocity = bullet_velocity.rotated(2 * PI / 6)
		bullet_velocities.append(bullet_velocity)
	set_anim("Jump", true)
	shoot(bullet_velocities)
	generate_state()

### anim
func _on_anim_finished(anim_name):
	if anim_name == wait_anim:
		wait_anim = "" # Replace with function body.
