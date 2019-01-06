using UnityEngine;
#if UNITY_EDITOR
using UnityEditor.ShaderGraph;
using System.Reflection;
[Title("UV", "ParallaxOcclusionMapping")]
public class NodeParallaxOcclusionMapping : CodeFunctionNode
{
    public NodeParallaxOcclusionMapping()
    {
        name = "ParallaxOcclusionMapping";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("ParallaxOcclusionMappingFunction",
        BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string ParallaxOcclusionMappingFunction(
    [Slot(0, Binding.MeshUV0)] Vector2 UV,
    [Slot(1, Binding.None)] Texture2D Height,
    [Slot(2, Binding.None)] Vector1 Depth,
    [Slot(3, Binding.None,40.0f, 40.0f, 40.0f, 40.0f)] Vector1 MaxParallaxSamples,
    [Slot(4, Binding.None, 1.0f, 1.0f, 1.0f, 1.0f)] Vector1 UseChanel_1_4_RGBA,
    [Slot(5, Binding.None)] SamplerState Sampler_NECESSARY,
    [Slot(6, Binding.WorldSpaceTangent)] Vector3 WorldSpaceTangent,
    [Slot(7, Binding.WorldSpaceNormal)] Vector3 WorldSpaceNormal,
    [Slot(8, Binding.WorldSpaceBitangent)] Vector3 WorldSpaceBiTangent,
    [Slot(9, Binding.WorldSpacePosition)] Vector3 WorldPos,
    [Slot(10, Binding.None)] out Vector2 Out)
    {
        Out = Vector2.zero;

        return
        @" 
{ 
float3 tanToWorld0 = float3( WorldSpaceTangent.x, WorldSpaceBiTangent.x, WorldSpaceNormal.x );
float3 tanToWorld1 = float3( WorldSpaceTangent.y, WorldSpaceBiTangent.y, WorldSpaceNormal.y );
float3 tanToWorld2 = float3( WorldSpaceTangent.z, WorldSpaceBiTangent.z, WorldSpaceNormal.z );
float3 WorldSpaceViewDirection = normalize(_WorldSpaceCameraPos.xyz - WorldPos.xyz);
float3 viewDir =  tanToWorld0 * WorldSpaceViewDirection.x + tanToWorld1 * WorldSpaceViewDirection.y  + tanToWorld2 * WorldSpaceViewDirection.z;



float MaxParallaxSamples____ = MaxParallaxSamples;
if (MaxParallaxSamples < 6) {
MaxParallaxSamples____ = 6;
}
                float2 uv__;
			    uv__ = UV;
                float3 normalDirection = normalize(WorldSpaceNormal);
               
                float2 vParallaxDirection = normalize( viewDir.xy );
                float fLength = length( viewDir );
                float fParallaxLength = sqrt( fLength * fLength - viewDir.z * viewDir.z ) / viewDir.z;
                float2 vParallaxOffsetTS = vParallaxDirection * fParallaxLength * Depth ;   
                float nMinSamples = 6;
                float nMaxSamples = min(MaxParallaxSamples____, 100);
                int nNumSamples = (int)(lerp( nMinSamples, nMaxSamples, 1-dot(WorldSpaceViewDirection , WorldSpaceNormal ) ));
if (nNumSamples < 0) {
nNumSamples = 6;
}

if (nNumSamples > 100) {
nNumSamples = 100;
}

                float fStepSize = 1.0 / (float)nNumSamples;   
                int    nStepIndex = 0;
                float fCurrHeight = 0.0;
                float fPrevHeight = 1.0;
                float2 vTexOffsetPerStep = fStepSize * vParallaxOffsetTS;
                float2 vTexCurrentOffset = uv__;
                float  fCurrentBound     = 1.0;
                float  fParallaxAmount   = 0.0;
                float2 pt1 = 0;
                float2 pt2 = 0;
                float2 dx = ddx(uv__);
                float2 dy = ddy(uv__);
[unroll (100) ]
                for (nStepIndex = 0; nStepIndex < nNumSamples; nStepIndex++)
                {

                    vTexCurrentOffset -= vTexOffsetPerStep;

                  

if (UseChanel_1_4_RGBA > -0.01 && UseChanel_1_4_RGBA < 1.5) { //use Red
fCurrHeight = SAMPLE_TEXTURE2D (Height,Sampler_NECESSARY,vTexCurrentOffset).r;
}

if (UseChanel_1_4_RGBA > 1.5 && UseChanel_1_4_RGBA < 2.5) {// use Green
fCurrHeight = SAMPLE_TEXTURE2D (Height,Sampler_NECESSARY,vTexCurrentOffset).g;
}

if (UseChanel_1_4_RGBA > 2.5 && UseChanel_1_4_RGBA < 3.5) {// use Blue
fCurrHeight = SAMPLE_TEXTURE2D (Height,Sampler_NECESSARY,vTexCurrentOffset).b;
}
if (UseChanel_1_4_RGBA > 3.5) { // use Alpha
fCurrHeight = SAMPLE_TEXTURE2D (Height,Sampler_NECESSARY,vTexCurrentOffset).a;
}

                    fCurrentBound -= fStepSize;
                    if ( fCurrHeight > fCurrentBound ) 
                    {   
                        pt1 = float2( fCurrentBound, fCurrHeight );
                        pt2 = float2( fCurrentBound + fStepSize, fPrevHeight );
                        nStepIndex = nNumSamples + 1;   //Exit loop
                        fPrevHeight = fCurrHeight;
                    }
                    else
                    {
                        fPrevHeight = fCurrHeight;
                    }
                }  
                float fDelta2 = pt2.x - pt2.y;
                float fDelta1 = pt1.x - pt1.y;  
                float fDenominator = fDelta2 - fDelta1;
                if ( fDenominator == 0.0f )
                {
                    fParallaxAmount = 0.0f;
                }
                else
                {
                    fParallaxAmount = (pt1.x * fDelta2 - pt2.x * fDelta1 ) / fDenominator;
                }
                uv__ -= vParallaxOffsetTS * (1 - fParallaxAmount );



Out = uv__; 

} 
";
    }
}
#endif