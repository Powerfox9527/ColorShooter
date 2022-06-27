class_name Player
extends Actor

export var roll_distance = 400
export var hit_frame_count = 0
export var hit_frame_max = 8

func _ready():
	$HurtTimer.connect("timeout", self, "_on_hurt_timeout")
	$RollTimer.connect("timeout", self, "_on_roll_timeout")
func _physics_process(delta):
	move(delta)
	update_gun(delta)
	update_hurt_visible()

### move
func _unhandled_input(event):
	if event.is_action_pressed("roll"):
		roll()

func move(delta):
	velocity = Vector2.ZERO
	if Input.get_action_strength("ui_left"):
		velocity.x += -Input.get_action_strength("ui_left")
	if Input.get_action_strength("ui_right"):
		velocity.x += Input.get_action_strength("ui_right")
	if Input.get_action_strength("ui_up"):
		velocity.y += -Input.get_action_strength("ui_up")
	if Input.get_action_strength("ui_down"):
		velocity.y += Input.get_action_strength("ui_down")
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

func update_hurt_visible():
	if $HurtTimer.is_stopped():
		set_visible(true)
		return
	hit_frame_count += 1
	if hit_frame_count > hit_frame_max:
		hit_frame_count = 0
	if hit_frame_count < hit_frame_max * 0.5:
		set_visible(false)
	else:
		set_visible(true)

func update_chase_direction(dir):
	$RayCast2D.set_cast_to(dir)
	var point = $RayCast2D.get_collision_point()
	return point

func roll():
	$RollTimer.stop()
	gun.visible = false
	if angle < PI / 2 and angle > -1 * PI/2:
		set_anim("BackRoll", true)
	else:
		set_anim("Roll", true)
	set_collision_layer(3)
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
		$RollTimer.stop()

### hurt
func get_hurt(hurt_color):
	if !$HurtTimer.is_stopped():
		# print("It's in hurting")
		return
	if hurt_color.gray() <= 0:
		return
	if wait_anim.length() > 0:
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
