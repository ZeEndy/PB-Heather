shader_type canvas_item;
//ALL CREDIT FOR THE SAHDER GOES TO SP33S ON SHADER TOY
//
//shader used https://www.shadertoy.com/view/sltBWM

const vec3 W = vec3(0.2126,0.7152,0.0722);

#define BLACK vec4(0.0, 0.0, 0.0, 1.0)
#define WHITE vec4(1.0)
#define DEFINE(a,iResolution) (iResolution.y / 450.0) * a


uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,filter_linear_mipmap_anisotropic;


float GetLuminance(vec3 color)
{
    return W.r * color.r + W.g * color.g + W.b * color.b;
}


vec4 Shrink(in vec2 fragCoord, const in float shrinkRatio, const in float bias, in vec2 iResolution)
{
    float scale = 1.0 / iResolution.x;
    float numBands = iResolution.x * shrinkRatio;
    float bandWidth = iResolution.x / numBands;
    
    // How far are we along the band
    float t = mod(fragCoord.x, bandWidth) / bandWidth;
    
    // Sample current band in lower res
    fragCoord.x = floor(fragCoord.x * shrinkRatio) / shrinkRatio;
    vec2 uv = fragCoord / iResolution.xy;
    vec4 colorA = textureLod(SCREEN_TEXTURE, uv, bias);

    // Sample next band for interpolation
    uv.x += bandWidth * scale; 
    vec4 colorB = textureLod(SCREEN_TEXTURE, uv, bias);

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


void fragment()
{
    vec4 luma = Shrink(FRAGCOORD.xy, 0.5, 0.0,1.0/SCREEN_PIXEL_SIZE.xy); // In VHS the luma band is half of the resolution
    luma = BlendLuminosity(vec4(0.5, 0.5, 0.5, 1.0), luma);
    
    vec4 chroma = Shrink(FRAGCOORD.xy,  1.0/8.0, 2.0, 1.0/SCREEN_PIXEL_SIZE.xy); // In VHS chroma band is a much lower resolution (technically 1/16th)
    chroma = BlendColor(luma, chroma);
    
    COLOR = chroma; 
}