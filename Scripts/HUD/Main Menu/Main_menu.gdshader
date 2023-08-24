shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
// Standard Variables

const float def_bend = 3.14;
const float vignette_size = .2;
const float vignette_smoothness = .6;
const float vignette_edgeRounding = .8;
const float grain_amount = .5;
const float sl_size= 4.0;

// Standard shader random function.

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

// Creates proper UV coords so that video is not warped.

vec2 transform_coords(vec2 uv, float bend)
{
	uv -= 0.5;
    uv *= 1.9;
    uv.x *= 1. + pow(abs(uv.y)/bend, 2.);
    uv.y *= 1. + pow(abs(uv.x)/bend, 2.);
    
    uv /= 2.;
    return uv + .5;
}

// Darkens side of screen, combines with the color via multiplication in order to achieve a bending vignette.

float vignette(vec2 uv, float size, float smoothness, float edgeRounding)
{
	uv = (uv-.5) * size;
    return smoothstep(0., smoothness, 1. - sqrt(pow(abs(uv.x), edgeRounding) + pow(abs(uv.y), edgeRounding)));
}


// Film Grain

float grain(float grain_amt, vec2 uv) {
    return grain_amt+rand(uv * TIME);
}

// Scanlines, uses trig in order to get uniformed scan lines.

vec3 scanline(vec2 uv ,vec2 sps) {
    vec2 color = vec2(sin(uv.y * sps.y * sl_size), cos(uv.y * sps.y * sl_size));
	return vec3(color.x, color.y, color.x);
}

vec3 srgbToLinear(const vec3 x){
    return 0.315206*x*((2.10545+x)*(0.0231872+x));
}

vec3 t(vec2 p,float m){
    return srgbToLinear(texture(SCREEN_TEXTURE,p,m).rgb);
}

vec3 fastBloom (vec2 p,vec2 r){
    float mip = 2.;
    float scale = exp2(mip);
    vec3 c =
        t((p+vec2(-1.5,-0.5)*scale)/r,mip)*.1+
        t((p+vec2( 0.5,-1.5)*scale)/r,mip)*.1+
        t((p+vec2( 1.5, 0.5)*scale)/r,mip)*.1+
        t((p+vec2(-0.5, 1.5)*scale)/r,mip)*.1+
        t((p)/r,mip)*.7+
        t(p/r,0.)*.7;
    return c;
}

vec3 jodieRobo2(const vec3 d){
    float c=dot(d,vec3(.2126,.7152,.0722));
    vec4 e=vec4(d,c)*inversesqrt(c*c+1.);
    vec3 a=e.rgb;
    float b=e.a;
    float f=max(max(max(e.r,e.g),e.b),1.);
    return (b*a-a-(f*b-b))/(b-f);
}



// First, we declare the uv coords, curve it using transform_coords, combine it with our video feed (iChannel0) (if using Unity, use actual game pixels)
// Then, we add vignette, add in the scanlines, output grain, and we are finished! 

void fragment()
{
    vec2 uv = SCREEN_UV;
    
    vec2 curved_uv = transform_coords(uv, 2.);

	vec4 final_output =  vec4(1.) * vec4(jodieRobo2(fastBloom(FRAGCOORD.xy,1.0 / SCREEN_PIXEL_SIZE)),1.0); 

	//final_output*=vignette(curved_uv, vignette_size, vignette_smoothness, vignette_edgeRounding);
	
	final_output*=vec4(scanline(uv,1.0 / SCREEN_PIXEL_SIZE), 1.0);
	
	final_output*=grain(grain_amount,uv);

    COLOR = final_output;
}
