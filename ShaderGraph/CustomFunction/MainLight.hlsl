#ifndef TOYSHADER_MAINLIGHT_INCLUDED
#define TOYSHADER_MAINLIGHT_INCLUDED

#ifndef SHADERGRAPH_PREVIEW
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#endif

void GetMainLightColor_float(out float3 color)
{
    #ifdef SHADERGRAPH_PREVIEW
        color = float3(1, 1, 1);
    #else
        color = _MainLightColor;
    #endif
}

#endif