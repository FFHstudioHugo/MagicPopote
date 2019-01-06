#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor.ShaderGraph;
using System.Reflection;

[Title("Input", "Scene", "LightDirection")]
public class LightDirectionNode : CodeFunctionNode
{
    public override bool hasPreview { get { return false; } }


    private static string functionBodyForReals = @"{

float3 ff = 1;
float3 _MainLightPosition_ = 0;
#if SHADER_HINT_NICE_QUALITY
_MainLightPosition_ = _MainLightPosition;
#else
        _MainLightPosition_ = float3(0.02,0.02,0.02);i
#endif

LightDirection = _MainLightPosition_;
		}";


    private static string functionBodyPreview = @"{
			LightDirection = 1;
		}";

    private static bool isPreview;


    private static string functionBody
    {
        get
        {
            if (isPreview)
                return functionBodyPreview;
            else
                return functionBodyForReals;
        }
    }


    public LightDirectionNode()
    {
        name = "LightDirection";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("LightDirectionFunction", BindingFlags.Static | BindingFlags.NonPublic);
    }


    public override void GenerateNodeFunction(FunctionRegistry registry, GraphContext graphContext, GenerationMode generationMode)
    {
        isPreview = generationMode == GenerationMode.Preview;

        base.GenerateNodeFunction(registry, graphContext, generationMode);
    }


    private static string LightDirectionFunction(
    [Slot(0, Binding.None)] out Vector3 LightDirection)
    {
        LightDirection = Vector3.zero;
        return functionBody;
    }
}
#endif