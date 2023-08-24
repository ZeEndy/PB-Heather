shader_type canvas_item;

const float ammount=2.0;

void fragment() {
	vec2 pix_uv=round(UV*ammount)/ammount;
	
	vec4 text = texture(TEXTURE,UV);
	
	COLOR=text;
}
