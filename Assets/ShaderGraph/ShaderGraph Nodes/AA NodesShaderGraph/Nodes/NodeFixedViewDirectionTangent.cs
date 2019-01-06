using UnityEngine;
#if UNITY_EDITOR
using UnityEditor.ShaderGraph;
using System.Reflection;
[Title("Input","Geometry", "FixedViewDirectionTangent")]
public class NodeFixedViewDirectionTangent : CodeFunctionNode
{
    public NodeFixedViewDirectionTangent()
    {
        name = "FixedViewDirectionTangent";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("FixedViewDirectionTangentFunction",
        BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string FixedViewDirectionTangentFunction(
    [Slot(0, Binding.ObjectSpaceTangent)] Vector3 ObjectSpaceTangent,
    [Slot(1, Binding.WorldSpaceNormal)] Vector3 WorldSpaceNormal,
    [Slot(2, Binding.WorldSpaceBitangent)] Vector3 WorldSpaceBiTangent,
    [Slot(3, Binding.WorldSpaceViewDirection)] Vector3 WorldSpaceViewDirection,
    [Slot(4, Binding.None)] out Vector3 Out)
    {
        Out = Vector3.zero;

        return
        @" 
{ 
float3 WorldSpaceTangent = TransformObjectToWorldDir(ObjectSpaceTangent);
float3 tanToWorld0 = float3( WorldSpaceTangent.x, WorldSpaceBiTangent.x, WorldSpaceNormal.x );
float3 tanToWorld1 = float3( WorldSpaceTangent.y, WorldSpaceBiTangent.y, WorldSpaceNormal.y );
float3 tanToWorld2 = float3( WorldSpaceTangent.z, WorldSpaceBiTangent.z, WorldSpaceNormal.z );

float3 tanViewDir =  tanToWorld0 * WorldSpaceViewDirection.x + tanToWorld1 * WorldSpaceViewDirection.y  + tanToWorld2 * WorldSpaceViewDirection.z;

//tanViewDir = normalize(tanViewDir);

Out = tanViewDir;
} 
";
    }
    public override PreviewMode previewMode
    {
        get
        {
            return PreviewMode.Preview3D;
        }
    }
}
#endif