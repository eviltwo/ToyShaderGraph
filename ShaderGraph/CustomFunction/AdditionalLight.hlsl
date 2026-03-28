#ifndef TOYSHADER_ADDITIONALLIGHT_INCLUDED
#define TOYSHADER_ADDITIONALLIGHT_INCLUDED

#ifndef SHADERGRAPH_PREVIEW
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#endif

#pragma multi_compile _ _ADDITIONAL_LIGHTS
#pragma multi_compile _ _CLUSTER_LIGHT_LOOP

#ifndef SHADERGRAPH_PREVIEW
float3 CalculateLighting(Light light, float3 normalWS)
{
    float NdotL = dot(normalWS, normalize(light.direction));
    NdotL = (NdotL + 1) * 0.5;
    return saturate(NdotL) * light.color * light.distanceAttenuation * light.shadowAttenuation;
}
#endif

void GetAdditionalLightColor_float(float3 positionWS, float2 screenPosition, float3 normalWS, float step, out float3 color)
{
    #ifdef SHADERGRAPH_PREVIEW
    color = float3(1, 1, 1);
    #else

    color = float3(0, 0, 0);
    #if defined(_ADDITIONAL_LIGHTS)
    /*
    // Additional light loop for non-main directional lights. This block is specific to Forward+.
    #if USE_CLUSTER_LIGHT_LOOP
    UNITY_LOOP for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
    {
        Light light = GetAdditionalLight(lightIndex, positionWS, half4(1, 1, 1, 1));
        color += CalculateLighting(light, normalWS);
    }
    #endif
    */

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
        color += CalculateLighting(light, normalWS);
    }
    LIGHT_LOOP_END
    #endif

    color = round(color / step) * step;

    #endif
}

#endif
