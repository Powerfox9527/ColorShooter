shader_type canvas_item;

render_mode blend_mix;
uniform vec4 color: hint_color;

void fragment() {
	if (texture(TEXTURE, UV).rgb == vec3(1.0, 1.0, 1.0))
	{
		COLOR = texture(TEXTURE, UV);
	}
	else
	{
		COLOR = vec4(color.rgb * texture(TEXTURE, UV).rgb, texture(TEXTURE, UV).a);
	}
}