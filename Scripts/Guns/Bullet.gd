class_name Bullet
extends RigidBody2D

var power = 5
var color = Color.black
var sender

func _ready():
	connect("body_entered", self, "_on_RigidBody2D_body_entered")
	$Timer.connect("timeout", self, "disappear")

func set_color(new_color):
	color = new_color
	get_node("Light2D").color = new_color
	get_node("Sprite").material.set_shader_param("color", new_color)

func disappear():
	queue_free()

func init(player):
	var gun = player.gun
	var color = player.color
	color.r -= min(gun.ammo_expense / 100 * color.r, color.r)
	color.g -= min(gun.ammo_expense / 100 * color.g, color.g)
	color.b -= min(gun.ammo_expense / 100 * color.b, color.b)
	sender = player
	if player is Player:
		player.set_color(color)
	power = gun.power
	set_color(color)
	set_collision_mask(player.get_collision_mask())

func _on_RigidBody2D_body_entered(body):
	if body.has_method("get_hurt") and body != sender:
		body.get_hurt(Util.multiply_color(power, get_node("Light2D").color))
	disappear()
