class_name Player
extends Actor

export var roll_distance = 400

func _ready():
	$HurtTimer.connect("timeout", self, "_on_hurt_timeout")
	$RollTimer.connect("timeout", self, "_on_roll_timeout")
func _physics_process(delta):
	move(delta)
	update_gun(delta)

### move
func move(delta):
	if Input.is_action_just_pressed("roll"):
		roll()
	velocity = Vector2.ZERO
	if Input.get_action_strength("left"):
		velocity.x += -Input.get_action_strength("left")
	if Input.get_action_strength("right"):
		velocity.x += Input.get_action_strength("right")
	if Input.get_action_strength("up"):
		velocity.y += -Input.get_action_strength("up")
	if Input.get_action_strength("down"):
		velocity.y += Input.get_action_strength("down")
	if wait_anim.length() <= 0:
		velocity = velocity.normalized() * speed
		move_and_slide(velocity)
		self_to_target = (get_global_mouse_position() - get_position()).normalized()
		.set_move_anim()
	
	if !$RollTimer.is_stopped():
		move_and_slide(self_to_target * roll_distance)
	
	angle = Vector2.UP.angle_to(self_to_target)
	if angle < 0:
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)

func update_gun(delta):
	if Input.is_action_pressed("shoot"):
		gun.create_bullet(self_to_target)
	.update_gun(delta)
	

func roll():
	gun.visible = false
	if angle < PI / 2 and angle > -1 * PI/2:
		set_anim("BackRoll", true)
	else:
		set_anim("Roll", true)
	set_collision_layer(8)
	var length = animator.get_animation("Roll").get_length()
	$RollTimer.set_wait_time(length - 0.1)
	$RollTimer.start()

func _on_roll_timeout():
	$RollTimer.stop()

### anim
func _on_anim_finished(anim_name):
	if anim_name == wait_anim:
		wait_anim = "" # Replace with function body.
		gun.visible = true
		set_collision_layer(1)

### hurt
func get_hurt(hurt_color):
	if !$HurtTimer.is_stopped():
		# print("It's in hurting")
		return
	if hurt_color.gray() <= 0:
		print("No Hurt Amount")
		return
	if wait_anim.length() > 0:
		print("It's in wait_anim")
		return
	if angle < PI / 2 and angle > -1 * PI/2:
		set_anim("BackHurt", true)
	else:
		set_anim("Hurt", true)
	set_color(Util.get_hurt_amount(color, hurt_color / defense))
	if color.a <= 0:
		dead()
	$HurtTimer.start()

func _on_hurt_timeout():
	$HurtTimer.stop()


func dead():
	gun.set_visible(false)
