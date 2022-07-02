class_name Mouse
extends Enemy

var ran_pos = null
func _ready():
	var shape = $CollisionShape2D.get_shape()
	nav_offset = 10

func _physics_process(delta):
	pass
### state
func generate_state():
	$StateTimer.wait_time = randi() % 3 + 3 # 每3-5s换一次模式
	var value = randf()
	if value < 0.6:
		state =  "simple_shoot"
	elif value < 0.9:
		state = "random_walk"
	elif value < 1:
		state =  "chase"
	state = "random_walk"
	# print(state)

func simple_shoot():
	for i in range(5):
		self_to_target = (player.get_global_position() - get_global_position()).normalized()
		var ran_time = rand_range(1, 1.8)
		yield(get_tree().create_timer(ran_time), "timeout")
		shoot([self_to_target])
	is_in_state = false

func random_walk():
	if ran_pos == null or (get_global_position() - ran_pos).length() <= 10.0:
		ran_pos = navigation.get_ran_neighbor(get_global_position())
	if ran_pos == null:
		is_in_state = false
		return
	velocity = ran_pos - get_global_position()
	move_and_slide(velocity.normalized() * speed)
	is_in_state = false
