// This includes the system header file provided by the engine.
// It contains all the necessary data to perform shading.
#include <neon>

// Global variables / uniforms
// These can be set up from Lua as well
float time;
float4 ambience;
float3 campos;
TLIGHT sun;
texture active_tile;

// Our global sampler state for the diffuse texture
sampler2D colorMap = sampler_state
{
	Texture = <diffuseTex>;
    MipFilter = ANISOTROPIC;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
};

sampler2D activeTileMap = sampler_state
{
    Texture = <active_tile>;
    MipFilter = ANISOTROPIC;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
};

TLIGHT lights[9];

// Pipeline structure used to pass calculated per-vertex
// data to the pixel shader and the rasterizer
struct VS_OUTPUT {
    float4 position : POSITION;
    float4 worldPos : TEXCOORD2;
    float4 color : COLOR0;
    float2 texCoord : TEXCOORD0;
    float3 normal : NORMAL;
    float depth : TEXCOORD1;
    float4 flatColor : TEXCOORD3;
};

float ComputeFogFactor(float d, float start, float end) 
{
    return clamp((d - start) / (end - start), 0, 1);
}

// Vertex shader, called per each vertex, here we perform transformations
// and calculate data that doesn't need per-pixel precision
VS_OUTPUT VS_Main(VS_INPUT IN)
{
    VS_OUTPUT OUT;
    OUT.position = mul(float4(IN.position, 1.0f), NEON.MVP);
    OUT.worldPos = mul(float4(IN.position, 1.0f), NEON.World);
    OUT.normal = mul(IN.normal, NEON.World);
    OUT.color = IN.color;
    OUT.texCoord = IN.texCoord * 0.5;
    OUT.depth = ComputeFogFactor(length(campos - OUT.worldPos), 300, 1000);

    float3 v = normalize(campos - OUT.worldPos);
    float3 n = normalize(OUT.normal);
    float3 l = normalize(-sun.Direction);
    float3 r = reflect(normalize(sun.Direction), normalize(n));
    float4 sunColor = float4(0.3, 0.15, 0.2, 1);

    OUT.flatColor = sunColor * pow(saturate(dot(r,v)), 2.0);

    // OUT.position.y += frac(sin(time/128+dot(OUT.worldPos.xy, float2(12.9898,78.233))) * 43758.5453)*8;
    OUT.position.y += saturate(sin(time*4+dot(OUT.worldPos.xy, float2(12.9898,78.233))))*2;

    return OUT;
}

// Pixel shader, called per each fragment, here we calculate resulting color
// from data calculated in the Vertex shader and/or uniforms
float4 PS_Main(VS_OUTPUT IN) : COLOR
{
    float4 OUT = float4(0,0,0,1);
    float4 texInactive = tex2D(colorMap, IN.texCoord * float2(10,10));
    float4 texActive = tex2D(activeTileMap, IN.texCoord * float2(10,10))*0.75;
    float4 brightPart = lerp(texInactive, texActive, max(0, IN.depth*sin(time/2)+log(-cos(time/2))+1));

    float4 colorNear = float4(0.5, 0.2, 0.4, 1);
    float4 colorFar = max(float4(0.1, 0.2, 0.4, 1), float4(0.1, 0.2, 0.4, 1)) /**sin(time*0.5)*2)*0.5*/;
    float4 colorMin = float4(0.05, 0.05, 0.1, 1);
    float4 iterm = lerp(colorNear, colorFar, IN.depth)*2.5;

    float3 n = normalize(IN.normal);
    float3 l = normalize(-sun.Direction);
    float diffuse = saturate(dot(n, l));

    OUT += brightPart.a * iterm * 2;
    OUT += colorMin * diffuse * 2;
    OUT += IN.flatColor;

    return OUT*0.75;
}

// Our rendering technique, each technique consists of single/multiple passes
// These passes are emitted from the Lua side
technique Main
{
    // Our render pass, passes consist of various shaders and can be named.
    // Multiple passes can be used to produce various image effects, such as
    // shadowing, ambient occlusion or multi-pass lighting
    pass Default {
        // [ShaderType] = compile [ShaderModel] [EntryPoint]
        VertexShader = compile vs_3_0 VS_Main();
        PixelShader = compile ps_3_0 PS_Main();
    }
}
