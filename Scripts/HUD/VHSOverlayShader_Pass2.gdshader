shader_type canvas_item;


const vec3 W = vec3(0.2126,0.7152,0.0722);

#define BLACK vec4(0.0, 0.0, 0.0, 1.0)
#define WHITE vec4(1.0)
#define DEFINE(a,iResolution) (iResolution.y / 450.0) * a

float GetLuminance(vec3 color){
	float ret = W.r * color.r + W.g * color.g + W.b * color.b;
	return ret;
}

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,filter_linear_mipmap_anisotropic;

//shader used https://www.shadertoy.com/view/sltBWM
// Unsharp mask + balancing pass

vec4 UnsharpMask(in float amount, in float radius, in float threshold,  in float preBlurBias, in vec2 fragCoord,vec2 uv,vec2 iResolution)
{
    vec2 scale = vec2(1.0) / iResolution.xy;
    
    vec4 pixel = texture(SCREEN_TEXTURE, uv, preBlurBias);
    vec4 blurPixel =  texture(SCREEN_TEXTURE, uv, preBlurBias + 1.0);// Blur(radius, fragCoord, iResolution.xy, false, iChannel0, preBlurBias * 2.0);
    
    float lumDelta = abs(GetLuminance(pixel.rgb) - GetLuminance(blurPixel.rgb));
    
    if (lumDelta >= threshold)
        pixel = pixel + (pixel - blurPixel) * amount;
    
    return pixel;
}

vec4 ClampLevels(in vec4 pixel, const in float blackLevel, const in float whiteLevel)
{
    pixel = mix(pixel, BLACK, 1.0 - whiteLevel);
    pixel = mix(pixel, WHITE, blackLevel);
    
    return pixel;
}

vec4 Saturation(vec4 pixel, float adjustment)
{
    vec3 intensity = vec3(dot(pixel.rgb, W));
    return vec4(mix(intensity, pixel.rgb, adjustment), 1.0);
}

vec4 TintShadows(vec4 pixel, vec3 color)
{
    const float POWER = 1.5;
    
    // Curve is an approximation of Photoshop's color balance > shadows
    if (color.r > 0.0)
        pixel.r = mix(pixel.r, 1.0 - pow(abs(pixel.r - 1.0), POWER), color.r);
    if (color.g > 0.0)
        pixel.g = mix(pixel.g, 1.0 - pow(abs(pixel.g - 1.0), POWER), color.g);
    if (color.b > 0.0)
        pixel.b = mix(pixel.b, 1.0 - pow(abs(pixel.b - 1.0), POWER), color.b);
        
    return pixel;
}



void fragment()
{
const float PRE_BLUR_BIAS = 0.2;
const float UNSHARP_AMOUNT = 1.5;
const float UNSHARP_THRESHOLD = 0.0;
const float BLACK_LEVEL = 0.1;
const float WHITE_LEVEL = 0.9;
const float SATURATION_LEVEL = 0.75;
const vec3 SHADOW_TINT = vec3(0.7, 0.0, 0.9);
    float UNSHARP_RADIUS = DEFINE(20.0,1.0/SCREEN_PIXEL_SIZE);

    vec4 pixel = UnsharpMask(UNSHARP_AMOUNT, UNSHARP_RADIUS, UNSHARP_THRESHOLD, PRE_BLUR_BIAS, FRAGCOORD.xy,FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE),1.0/SCREEN_PIXEL_SIZE);
    
    pixel = ClampLevels(pixel, BLACK_LEVEL, WHITE_LEVEL);
    //pixel = TintShadows(pixel, SHADOW_TINT);
    pixel = Saturation(pixel, SATURATION_LEVEL);

    COLOR = pixel;
}