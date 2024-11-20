Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings
{
    float Time;
    float Scale;
    float2 Resolution;
    float4 Background;
};

// Preprocessor directives for settings (1 or 0)
#define DISTORTION_ENABLED 1      // Enable distortion
#define NOISE_ENABLED 1           // Turn on the noise
#define CHROMATIC_ENABLED 1       // Enable chromatic aberration
#define BLUR_ENABLED 1            // Enable blurring
#define SCANLINE_ENABLED 1        // Enable scan lines

// Settings for effects
#define DISTORTION_AMOUNT 0.06f               // Strength of lens distortion
#define NOISE_AMOUNT 0.2f                     // Noise power
#define CHROMATIC_SPREAD 0.8f                 // Chromatic aberration
#define SCANLINE_FACTOR 0.7f                  // Multiplier for scan lines
#define SCALED_SCANLINE_PERIOD Scale          // Period for scanning lines
#define SCALED_GAUSSIAN_SIGMA (1.5f * Scale)  // Sigma for Gaussian blur.
#define LINE_SPEED 0.3f                       // Lane speed
#define LINE_WIDTH 20.0f                      // Band width



#define TAU 6.28318530718
static const float M_PI = 3.14159265f;

float rand2dTo1d(float2 value, float2 dotDir = float2(12.9898f, 78.233f))
{
    float2 smallValue = sin(value + Time);
    float random = dot(smallValue, dotDir);
    random = frac(sin(random) * 143758.5453f);
    return random;
}

float4 Aberration(Texture2D input, float2 tex_coord)
{
    uint width, height;
    shaderTexture.GetDimensions(width, height);

    float texelWidth = 1.0f / width;
    float2 samplePosR = tex_coord + float2(CHROMATIC_SPREAD * texelWidth, 0);
    float2 samplePosB = tex_coord - float2(CHROMATIC_SPREAD * texelWidth, 0);

    float4 rColor = input.Sample(samplerState, samplePosR);
    float4 gColor = input.Sample(samplerState, tex_coord);
    float4 bColor = input.Sample(samplerState, samplePosB);

    return float4(rColor.r, gColor.g, bColor.b, gColor.a);
}

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

float2 LensDistortion(float2 uv)
{
    float2 center = float2(0.5, 0.5);
    uv = uv * 2.0 - 1.0;
    float dist = length(uv);
    uv *= 1.0 + dist * DISTORTION_AMOUNT;
    uv = uv * 0.5 + 0.5;
    return uv;
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

float2 ApplyDistortion(float2 texCoord)
{
    float lineWidth = LINE_WIDTH / Resolution.y;
    float linePosition = frac(Time * LINE_SPEED);
    if (texCoord.y > linePosition - lineWidth && texCoord.y < linePosition)
    {
        float distortionAmount = 0.02f;
        float wave = sin(texCoord.y * TAU * 5.0f + Time * 2.0f) * distortionAmount;
        texCoord.y += wave;
    }

    return texCoord;
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    if (DISTORTION_ENABLED == 1)
    {
        tex = LensDistortion(tex);
    }
    float4 color = shaderTexture.Sample(samplerState, tex);
    if (CHROMATIC_ENABLED == 1)
    {
        color = Aberration(shaderTexture, tex);
    }
    if (BLUR_ENABLED == 1)
    {
        color += Blur(shaderTexture, tex, SCALED_GAUSSIAN_SIGMA) * 0.3f;
    }
    if (SCANLINE_ENABLED == 1)
    {
        color = Scanline(color, pos);
    }
    if (NOISE_ENABLED == 1)
    {
        float noise = rand2dTo1d(tex) * NOISE_AMOUNT;
        color.rgb *= 1.0f - NOISE_AMOUNT + noise;
    }
    if (SCANLINE_ENABLED == 1)
    {
        float speed = LINE_SPEED;
        float linePosition = frac(Time * speed);
        float lineWidth = LINE_WIDTH / Resolution.y;

        if (tex.y > linePosition - lineWidth && tex.y < linePosition)
        {
            float2 distortedTex = ApplyDistortion(tex);
            
            color = shaderTexture.Sample(samplerState, distortedTex);
            color.a = 0.0;
        }
    }

    return color;
}
