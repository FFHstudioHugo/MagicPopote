using UnityEngine;
#if UNITY_EDITOR
using UnityEditor.ShaderGraph;
using System.Reflection;
[Title("Input", "Geometry", "PerturbedNormals")]
public class PerturbedNormalsNode : CodeFunctionNode
{
    public PerturbedNormalsNode()
    {
        name = "PerturbedNormals";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("PerturbedNormalsFunction",
            BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string PerturbedNormalsFunction(
        [Slot(0, Binding.None)] Vector3 NormalMap,
        [Slot(1, Binding.WorldSpaceTangent)] Vector3 Tangent,
        [Slot(2, Binding.None)] Vector3 BitangentDir,
        [Slot(3, Binding.WorldSpaceNormal)] Vector3 WorldNormal,
        [Slot(4, Binding.None)] out Vector3 Out)
    {
        Out = Vector3.zero;

        return
            @"
{

float3x3 tangentTransform = float3x3(Tangent, BitangentDir, WorldNormal);
 Out = normalize(mul( NormalMap, tangentTransform )); 
} 
";
    }
}
#endif




