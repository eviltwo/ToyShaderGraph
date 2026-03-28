#ifndef TOYSHADER_ADDITIONALLIGHT_INCLUDED
#define TOYSHADER_ADDITIONALLIGHT_INCLUDED

#ifndef SHADERGRAPH_PREVIEW
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#endif

#pragma multi_compile _ _ADDITIONAL_LIGHTS
#pragma multi_compile _ _CLUSTER_LIGHT_LOOP
#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS

#ifndef SHADERGRAPH_PREVIEW
float3 CalculateLighting(Light light, float3 normalWS)
{
    float NdotL = dot(normalWS, normalize(light.direction));
    NdotL = (NdotL + 1) * 0.5;
    return saturate(NdotL) * light.color * light.distanceAttenuation * (light.shadowAttenuation * light.shadowAttenuation);
}
#endif

void GetAdditionalLightColor_float(float3 positionWS, float2 screenPosition, float3 normalWS, float stepsRange, float steps, out float3 color)
{
    #ifdef SHADERGRAPH_PREVIEW
    color = float3(1, 1, 1);
    #else

    color = float3(0, 0, 0);
    #ifdef _ADDITIONAL_LIGHTS

    // Make InputData for LIGHT_LOOP (Forward+)
    #if USE_CLUSTER_LIGHT_LOOP
    InputData inputData = (InputData)0;
    inputData.positionWS = positionWS;
    inputData.normalizedScreenSpaceUV = screenPosition;
    #endif

    uint pixelLightCount = GetAdditionalLightsCount();
    LIGHT_LOOP_BEGIN(pixelLightCount)
    {
        Light light = GetAdditionalLight(lightIndex, positionWS);
        float shadowFade = GetAdditionalLightShadowFade(positionWS);
        light.shadowAttenuation = lerp(AdditionalLightRealtimeShadow(lightIndex, positionWS, light.direction), 1, shadowFade);
        color += CalculateLighting(light, normalWS);
    }
    LIGHT_LOOP_END
    #endif

    color = saturate(ceil(color / (stepsRange / steps)) * (1.0 / steps));

    #endif
}

#endif
