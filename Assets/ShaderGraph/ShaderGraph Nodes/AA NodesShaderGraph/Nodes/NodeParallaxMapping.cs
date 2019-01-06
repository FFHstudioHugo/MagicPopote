using UnityEngine;
#if UNITY_EDITOR
using UnityEditor.ShaderGraph;
using System.Reflection;
[Title("UV", "ParallaxMapping")]
public class NodeParallaxMapping : CodeFunctionNode
{
    public NodeParallaxMapping()
    {
        name = "Parallax_Mapping";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("ParallaxMappingFunction",
        BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string ParallaxMappingFunction(
    [Slot(0, Binding.MeshUV0)] Vector2 UV,
    [Slot(1, Binding.TangentSpaceNormal)] Vector3 ViewDir_Tan,
    [Slot(2, Binding.None)] Vector1 Scale,
    [Slot(3, Binding.None)] Vector1 Height,
    [Slot(4, Binding.None)] Vector1 LWRP_HDRP_0_1,
    [Slot(5, Binding.None)] out Vector2 Out)
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
float2 Offset = ( ( Height - 1 ) * ViewDir.xy * Scale ) + UV; 
Out = Offset; 
} 
";
    }
}
#endif