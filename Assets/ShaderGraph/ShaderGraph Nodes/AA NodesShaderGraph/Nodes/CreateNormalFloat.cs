using UnityEngine;
#if UNITY_EDITOR
using UnityEditor.ShaderGraph;
using System.Reflection;
[Title("Artistic", "Normal", " CreateNormalFloat")]
public class CreateNormalFloat : CodeFunctionNode
{
    public CreateNormalFloat()
    {
        name = "CreateNormalHeight";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("CreateNormalFloatFunction",
            BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string CreateNormalFloatFunction(
        [Slot(0, Binding.None,0,0,0,0)] Vector1 Height,
        [Slot(1, Binding.None, 0, 0, 0, 0)] Vector1 HeightUV1,
        [Slot(2, Binding.None, 0, 0, 0, 0)] Vector1 HeightUV2,
        [Slot(3, Binding.None)] Vector1 Strength,
        [Slot(4, Binding.None)] out Vector3 Normal)
    {
        Normal = Vector3.zero;

        return
            @"
{

float3 appendResult13_g1 = (float3(1.0 , 0.0 , ( ( HeightUV1 - Height ) * Strength)));
float3 appendResult16_g1 = (float3(0.0 , 1.0 , ( ( HeightUV2 - Height ) * Strength)));

float3 FinalNormal = normalize( cross( appendResult13_g1 , appendResult16_g1 ) );

 Normal = FinalNormal; 
} 
";
    }
}




[Title("Custom", "UvCreateNormal1")]
public class UvCreateNormal1 : CodeFunctionNode
{
    public UvCreateNormal1()
    {
        name = "UvCreateNormal1";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("UvCreateNormal1Function",
            BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string UvCreateNormal1Function(
        [Slot(0, Binding.MeshUV0)] Vector2 uv,
        [Slot(1, Binding.None)] out Vector2 UV)
    {
        UV = Vector2.zero;

        return
            @"
{
float Pow_ = ( pow( 0.5 , 3.0 ) * 0.1 );

float2 uv__ = (float2(( uv.x + Pow_) , uv.y));

 UV = uv__; 
} 
";
    }
}

[Title("Custom", "UvCreateNormal2")]
public class UvCreateNormal2 : CodeFunctionNode
{
    public UvCreateNormal2()
    {
        name = "UvCreateNormal2";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("UvCreateNormal2Function",
            BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string UvCreateNormal2Function(
        [Slot(0, Binding.MeshUV0)] Vector2 uv,
        [Slot(1, Binding.None)] out Vector2 UV)
    {
        UV = Vector2.zero;

        return
            @"
{
float Pow_ = ( pow( 0.5 , 3.0 ) * 0.1 );

float2 uv__ = (float2(uv.x , ( uv.y + Pow_)));

 UV = uv__; 
} 
";
    }
}
#endif