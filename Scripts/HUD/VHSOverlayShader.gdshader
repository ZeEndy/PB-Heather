shader_type canvas_item;


const vec3 W = vec3(0.2126,0.7152,0.0722);

#define BLACK vec4(0.0, 0.0, 0.0, 1.0)
#define WHITE vec4(1.0)
#define DEFINE(a,iResolution) (iResolution.y / 450.0) * a


uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

//shader used https://www.shadertoy.com/view/sltBWM

float GetLuminance(vec3 color){
	float ret = W.r * color.r + W.g * color.g + W.b * color.b;
	return ret;
}

float BlendSoftLight(float base, float blend) 
{
	return (blend<0.5)?(2.0*base*blend+base*base*(1.0-2.0*blend)):(sqrt(base)*(2.0*blend-1.0)+2.0*base*(1.0-blend));
}
vec4 BlendSoftLight1(vec4 base, vec4 blend) 
{
	return vec4(BlendSoftLight(base.r,blend.r),BlendSoftLight(base.g,blend.g),BlendSoftLight(base.b,blend.b), 1.0);
}
vec4 BlendSoftLight2(vec4 base, vec4 blend, float opacity) 
{
	return (BlendSoftLight1(base, blend) * opacity + base * (1.0 - opacity));
}

vec4 Shrink(in vec2 fragCoord, const in float shrinkRatio, const in float bias, in vec2 ires, in vec2 uv)
{
    float scale = 1.0 / ires.x;
    float numBands = ires.x * shrinkRatio;
    float bandWidth = ires.x / numBands;
    
    // How far are we along the band
    float t = mod(fragCoord.x, bandWidth) / bandWidth;
    
    // Sample current band in lower res
    fragCoord.x = floor(fragCoord.x * shrinkRatio) / shrinkRatio;
    vec4 colorA = texture(SCREEN_TEXTURE, uv, bias);

    // Sample next band for interpolation
    uv.x += bandWidth * scale; 
    vec4 colorB = texture(SCREEN_TEXTURE, uv, bias);

    return mix(colorA, colorB, t);
}

// Based on https://printtechnologies.org/wp-content/uploads/2020/03/pdf-reference-1.6-addendum-blend-modes.pdf
vec3 ClipColor(in vec3 c)
{
    float l = GetLuminance(c);
    float n = min(min(c.r, c.g), c.b);
    float x = max(max(c.r, c.g), c.b);
    
    if (n < 0.0)
    {
        c.r = l + (((c.r - l) * l) / (l - n));
        c.g = l + (((c.g - l) * l) / (l - n));
        c.b = l + (((c.b - l) * l) / (l - n));
    }
    
    if (x > 1.0)
    {
        c.r = l + (((c.r - l) * (1.0 - l)) / (x - l));
        c.g = l + (((c.g - l) * (1.0 - l)) / (x - l));
        c.b = l + (((c.b - l) * (1.0 - l)) / (x - l));
    }
    
    
    return c;
}

vec3 SetLum(in vec3 c, in float l)
{
    float d = l - GetLuminance(c);
    c += d;

    return ClipColor(c);
}

vec4 BlendColor(const in vec4 base, const in vec4 blend)
{
    vec3 c = SetLum(blend.rgb, GetLuminance(base.rgb));
    return vec4(c, blend.a);
}

vec4 BlendLuminosity(const in vec4 base, const in vec4 blend)
{
    vec3 c = SetLum(base.rgb, GetLuminance(blend.rgb));
    return vec4(c, blend.a);
}

float GoldNoise(const in vec2 xy, const in float seed)
{
    //return fract(tan(distance(xy * PHI, xy) * seed) * xy.x);
    return fract(sin(dot(xy * seed, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 Noise(const in float grainSize, const in bool monochromatic, in vec2 fragCoord, float fps)
{
    float seed = fps > 0.0 ? floor(fract(TIME) * fps) / fps : TIME;
    seed += 1.0;
    
    if (grainSize > 1.0)
    {
        fragCoord.x = floor(fragCoord.x / grainSize);
        fragCoord.y = floor(fragCoord.y / grainSize);
    }

    fragCoord.x += 1.0;
    
    float r = GoldNoise(fragCoord, seed);    
    float g = monochromatic ? r : GoldNoise(fragCoord, seed + 1.0);
    float b = monochromatic ? r : GoldNoise(fragCoord, seed + 2.0);
    
    
    return vec4(r, g, b, 1.0);
}

const float NOISE_BLEND = 0.05;





void fragment()
{
	float NOISE_GRAIN_SIZE = DEFINE(4.0,1.0/SCREEN_PIXEL_SIZE);
	vec2 flip_frag=vec2(FRAGCOORD.x+20.0,mod(-FRAGCOORD.y,1.0));
    vec4 luma = Shrink(flip_frag, 0.5, 0.0,1.0/SCREEN_PIXEL_SIZE,SCREEN_UV); // In VHS the luma band is half of the resolution
    luma = BlendLuminosity(vec4(0.5, 0.5, 0.5, 1.0), luma);
    vec2 screen_fix=vec2(SCREEN_UV.x-0.004,SCREEN_UV.y);
    vec4 chroma = Shrink(flip_frag,  1.0 / 8.0, 3.0,1.0/SCREEN_PIXEL_SIZE,screen_fix); // In VHS chroma band is a much lower resolution (technically 1/16th)
    chroma = BlendColor(luma, chroma);
    chroma = BlendSoftLight2(chroma,Noise(NOISE_GRAIN_SIZE, true, FRAGCOORD.xy, 24.0),NOISE_BLEND);
	
    COLOR = chroma; 
}