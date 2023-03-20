shader_type canvas_item;


varying vec2 v_vCameraPos;
varying vec2 v_vWorldPos;

#define CAMERA_FROM ( -CANVAS_MATRIX[3] * CANVAS_MATRIX )


void vertex(){
	v_vWorldPos = VERTEX.xy;
	v_vCameraPos = CAMERA_FROM.xy;
}

// FRAGMENT STUFF

uniform sampler2D u_pGlassEffect:repeat_enable,filter_nearest; 
uniform sampler2D u_pGlassMask:filter_nearest;

#define TEXTURE_SIZE 64.0 // size of the texture being drawn
#define TEXTURE_SCALE ( TEXTURE_SIZE / 32.0 ) // size of the effect texture

void fragment()
{
	vec4 vGlassColour = texture( u_pGlassEffect, ( ( v_vWorldPos.xy / TEXTURE_SIZE ) - ( v_vCameraPos * 0.00025 ) ) * TEXTURE_SCALE );
	vec4 fuck=texture( u_pGlassMask, UV.xy );
	fuck.a=0.0;
	COLOR -= ( vGlassColour * fuck );
}