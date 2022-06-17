shader_type canvas_item;

render_mode blend_mix;
uniform vec4 color: hint_color;

void fragment() {
	if (texture(TEXTURE, UV).r != texture(TEXTURE, UV).g)
	{
		COLOR = vec4(texture(TEXTURE, UV).rgb, texture(TEXTURE, UV).a * color.a);
	}
	else
	{
		COLOR = vec4(color.rgb * texture(TEXTURE, UV).rgb, texture(TEXTURE, UV).a * color.a);
	}
}