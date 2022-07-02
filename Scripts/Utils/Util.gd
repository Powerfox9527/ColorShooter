extends Node

class_name Util
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func set_color(material, new_color):
	new_color.r = min(1.0, new_color.r)
	new_color.g = min(1.0, new_color.g)
	new_color.b = min(1.0, new_color.b)
	material.set_shader_param("color", new_color)
	
static func get_hurt_amount(color, hurt_color, is_enemy = false):
	var amount = 0
	amount += max(hurt_color.r - color.r, 0)
	amount += max(hurt_color.g - color.g, 0)
	amount += max(hurt_color.b - color.b, 0)
	color.r -= min(color.r, hurt_color.r)
	color.g -= min(color.g, hurt_color.g)
	color.b -= min(color.b, hurt_color.b)
	if amount > 0:
		color.a -= min(amount, color.a)
	if is_enemy:
		color.a -= min(hurt_color.a, color.a)
	return color

static func multiply_color(multiplier, color, m_alpha = false):
	color.r *= multiplier
	color.g *= multiplier
	color.b *= multiplier
	if m_alpha:
		color.a *= multiplier
	return color

static func get_raycast_point(start, end, extents):
	if extents.x == 0 or extents.y == 0:
		return start
	if end.x == start.x:
		if end.y >= start.y:
			return Vector2(start.x, start.y + extents.y)
		else:
			return Vector2(start.x, start.y - extents.y)
	var slope = (end.y - start.y) / (end.x - start.x)
	var extents_slope = extents.y / extents.x
	if abs(slope) <= abs(extents_slope):
		if start.x <= end.x:
			return Vector2(extents.x, extents.x * slope) + start
		else:
			return Vector2(-1 * extents.x, -1 * extents.x * slope) + start
	else:
		if slope == 0:
			if start.x <= end.x:
				return Vector2(0, extents.y) + start
			else:
				return Vector2(0, -1 * extents.y) + start
		elif start.y <= end.y:
			return Vector2(extents.y / slope, extents.y) + start
		else:
			return Vector2(-1 * extents.y / slope, -1 * extents.y) + start
