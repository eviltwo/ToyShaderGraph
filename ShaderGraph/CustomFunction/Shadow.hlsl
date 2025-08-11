#ifndef TOYSHADER_SHADOW_INCLUDED
#define TOYSHADER_SHADOW_INCLUDED

#ifndef SHADERGRAPH_PREVIEW
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#endif

#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile _ _SHADOWS_SOFT

void CalculateShadow_float(float3 positionWS, float3 normalWS, float receivedShadowStep, float surfaceShadowStep, out float lighting)
{
    // Received shadow
    #ifdef SHADERGRAPH_PREVIEW
    lighting = 1;
    #else
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    float shadowAmount = MainLightRealtimeShadow(shadowCoord);
    float shadowFade = GetMainLightShadowFade(positionWS);
    lighting = step(receivedShadowStep, lerp(shadowAmount, 1, shadowFade));
    #endif

    // Surface shadow
    float3 lightDirection;
    #ifdef SHADERGRAPH_PREVIEW
    lightDirection = float3(0.5, 0.5, -0.5);
    normalize(lightDirection);
    #else
    Light light = GetMainLight();
    lightDirection = light.direction;
    #endif
    float surfaceShadow = clamp(step(surfaceShadowStep, dot(normalWS, lightDirection)), 0, 1);
    lighting = min(lighting, surfaceShadow);

    // Apply strength
    #ifndef SHADERGRAPH_PREVIEW
    lighting = max(lighting, 1 - _MainLightShadowParams.x);
    #endif
}

#endif