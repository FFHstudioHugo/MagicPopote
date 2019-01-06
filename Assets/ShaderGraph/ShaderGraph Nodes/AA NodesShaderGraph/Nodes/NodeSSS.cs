using UnityEngine;
#if UNITY_EDITOR
using UnityEditor.ShaderGraph;
using System.Reflection;
        [Title("Artistic", "SSS","SSS")]
        public class NodeSSS : CodeFunctionNode
{
    public NodeSSS()
    {
        name = "SSS";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("SSSFunction",
            BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string SSSFunction(
        [Slot(0, Binding.WorldSpaceNormal)] Vector3 Normal,
        [Slot(1, Binding.None)] DynamicDimensionVector Depth,
        [Slot(2, Binding.None)] Vector3 ColorSSS1,
        [Slot(3, Binding.None)] Vector3 ColorSSS2,
        [Slot(4, Binding.None)] Vector3 ColorSSS3,
        [Slot(5, Binding.None)] DynamicDimensionVector LevelColor1,
        [Slot(6, Binding.None)] DynamicDimensionVector LevelColor2,
        [Slot(7, Binding.None)] DynamicDimensionVector Transmission,
        [Slot(8, Binding.None)] DynamicDimensionVector Intensity,
        [Slot(9, Binding.None)] Vector3 lightDirection,
        [Slot(10, Binding.None)] out Vector3 Out) 
	{
        Out = Vector3.zero;

        return
            @"
{

 float remap1 = ((Depth)*4.0+-3.0);

float nulll = 0.0;

float M_ = (-1.0);

float _Gradient = saturate((nulll + ( ((dot(Normal,lightDirection)*(1.0 - remap1)) - M_) * (1.0 - nulll) ) / (2.0 - M_)));

float Gr = (1.0 - (_Gradient*0.9+0.1));

float3 _ColorSSS_ = lerp(lerp(ColorSSS1.rgb,ColorSSS2.rgb,saturate((0.0 + ( (_Gradient - 1.0) * (1.0 - 0.0) ) / (LevelColor1 - 1.0)))),ColorSSS3.rgb,saturate((0.0 + ( (_Gradient - LevelColor2) * (1.0 - 0.0) ) / (0.0 - LevelColor2))));

float3 FinalResult = (lerp((_ColorSSS_*saturate(lerp(_Gradient,(_Gradient*Gr),(_Gradient*(Transmission+0.3))))),_ColorSSS_,Transmission)*(Intensity*3.0));


Out = FinalResult;
} 
";
	}
}

#endif