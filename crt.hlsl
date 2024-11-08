Texture2D shaderTexture;
SamplerState samplerState;


cbuffer PixelShaderSettings
{
    float Time; 
    float Scale; 
    float2 Resolution; 
    float4 Background; 
};

#define TAU 6.28318530718
#define SCANLINE_FACTOR 0.5f
#define SCALED_SCANLINE_PERIOD Scale
#define SCALED_GAUSSIAN_SIGMA (2.0f * Scale)
#define DISTORTION_AMOUNT 0.04f // Strength of lens distortion

static const float M_PI = 3.14159265f;

float Gaussian2D(float x, float y, float sigma)
{
    return 1 / (sigma * sqrt(2 * M_PI)) * exp(-0.5 * (x * x + y * y) / sigma / sigma);
}

float4 Blur(Texture2D input, float2 tex_coord, float sigma)
{
    float width, height;
    shaderTexture.GetDimensions(width, height);

    float texelWidth = 1.0f / width;
    float texelHeight = 1.0f / height;

    float4 color = float4(0, 0, 0, 0);
    float sampleCount = 13;

    for (float x = 0; x < sampleCount; x++)
    {
        float2 samplePos = float2(0, 0);
        samplePos.x = tex_coord.x + (x - sampleCount / 2.0f) * texelWidth;

        for (float y = 0; y < sampleCount; y++)
        {
            samplePos.y = tex_coord.y + (y - sampleCount / 2.0f) * texelHeight;
            color += input.Sample(samplerState, samplePos) * Gaussian2D(x - sampleCount / 2.0f, y - sampleCount / 2.0f, sigma);
        }
    }

    return color;
}

float SquareWave(float y)
{
    return 1.0f - (floor(y / SCALED_SCANLINE_PERIOD) % 2.0f) * SCANLINE_FACTOR;
}

float4 Scanline(float4 color, float4 pos)
{
    float wave = SquareWave(pos.y);
    return color * wave;
}

float2 LensDistortion(float2 uv)
{
    float2 center = float2(0.5, 0.5); 
    uv = uv * 2.0 - 1.0; 
    float dist = length(uv);
    uv *= 1.0 + dist * DISTORTION_AMOUNT; 
    uv = uv * 0.5 + 0.5; 
    return uv;
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    tex = LensDistortion(tex);

    float4 color = shaderTexture.Sample(samplerState, tex);

    float linePosition = fmod(Time, 5.0); // Line position (in time)
    float lineWidth = 10.0 / Resolution.y; // Line width

    if (tex.y > linePosition - lineWidth && tex.y < linePosition)
    {
        color.rgb = Background.rgb;
        color.a = 0.0;
    }
    color += Blur(shaderTexture, tex, SCALED_GAUSSIAN_SIGMA) * 0.3f;
    color = Scanline(color, pos);

    return color;
}
