using UnityEngine;
#if UNITY_EDITOR
using UnityEditor.ShaderGraph;
using System.Reflection;
[Title("UV", "ParallaxIterationMapping")]
public class ParallaxMappingIterationNode : CodeFunctionNode
{
    public ParallaxMappingIterationNode()
    {
        name = "ParallaxIterationMapping";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("ParallaxIterationMappingFunction",
        BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string ParallaxIterationMappingFunction(
    [Slot(0, Binding.MeshUV0)] Vector2 UV,
    [Slot(1, Binding.TangentSpaceNormal)] Vector3 ViewDir_Tan,
    [Slot(2, Binding.None)] Vector1 Scale,
    [Slot(3, Binding.None)] Texture2D Height,
    [Slot(4, Binding.None)] Vector1 Iterations_Int,
    [Slot(5, Binding.None, 1.0f, 1.0f, 1.0f, 1.0f)] Vector1 UseChanel_1_4_RGBA,
    [Slot(6, Binding.None)] SamplerState Sampler_NECESSARY,
    [Slot(7, Binding.None)] Vector1 LWRP_HDRP_0_1,
    [Slot(8, Binding.None)] out Vector2 Out)
    {
        Out = Vector2.zero;

        return
        @" 
{ 
float3 ViewDir = 0;
if (LWRP_HDRP_0_1 == 0) {
ViewDir = ViewDir_Tan;
//ViewDir = (float3((0.0 + (ViewDir_Tan.x - 0.0) * (8.0 - 0.0) / (1.0 - 0.0)) , ( ViewDir_Tan.y * -1.0 ) , ( ViewDir_Tan.z * -1.0 )));
}
if (LWRP_HDRP_0_1 == 1) {
ViewDir = ViewDir_Tan;
}

int iterations = Iterations_Int;

float Scale_ = Scale;
if (iterations > 0.9) {
Scale_ = Scale / iterations;
}
float2 Offset = UV;   
if (UseChanel_1_4_RGBA > 0 && UseChanel_1_4_RGBA < 2) { //use Red
if (Iterations_Int > 0) { 
Offset = ( ( Height.Sample(Sampler_NECESSARY, UV).r - 1 ) * ViewDir.xy * Scale_ ) + UV;
}
for (int i = 0;i < iterations;i++) { 
Offset = ( ( Height.Sample(Sampler_NECESSARY, Offset).r - 1 ) * ViewDir.xy * Scale_ ) + Offset; 
} 
}

if (UseChanel_1_4_RGBA > 1 && UseChanel_1_4_RGBA < 3) {// use Green
if (Iterations_Int > 0) { 
Offset = ( ( Height.Sample(Sampler_NECESSARY, Offset).g - 1 ) * ViewDir.xy * Scale_ ) + UV;
}
for (int i = 0;i < iterations;i++) { 
Offset = ( ( Height.Sample(Sampler_NECESSARY, Offset).g - 1 ) * ViewDir.xy * Scale_ ) + Offset; 
} 
}

if (UseChanel_1_4_RGBA > 2 && UseChanel_1_4_RGBA < 4) {// use Blue
if (Iterations_Int > 0) { 
Offset = ( ( Height.Sample(Sampler_NECESSARY, Offset).b - 1 ) * ViewDir.xy * Scale_ ) + UV;
}
for (int i = 0;i < iterations;i++) { 
Offset = ( ( Height.Sample(Sampler_NECESSARY, Offset).b - 1 ) * ViewDir.xy * Scale_ ) + Offset; 
} 
}


if (UseChanel_1_4_RGBA > 3 && UseChanel_1_4_RGBA < 5) { // use Alpha
if (Iterations_Int > 0) { 
Offset = ( ( Height.Sample(Sampler_NECESSARY, Offset).a - 1 ) * ViewDir.xy * Scale_ ) + UV;
}
for (int i = 0;i < iterations;i++) { 
Offset = ( ( Height.Sample(Sampler_NECESSARY, Offset).a - 1 ) * ViewDir.xy * Scale_ ) + Offset; 
} 
}

Out = Offset; 
} 
";
    }
}
#endif