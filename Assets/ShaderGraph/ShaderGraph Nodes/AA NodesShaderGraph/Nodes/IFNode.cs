using UnityEngine;
#if UNITY_EDITOR
using UnityEditor.ShaderGraph;
using System.Reflection;

[Title("Utility", "Logic", "If_Float")]
public class IFNode : CodeFunctionNode
{
    public IFNode()
    {
        name = "If_Float";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("IFNodeFloatFunction",
            BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string IFNodeFloatFunction(
        [Slot(0, Binding.None)] Vector1 A,
        [Slot(1, Binding.None)] Vector1 B,
        [Slot(2, Binding.None)] Vector1 A_Greater_B,
        [Slot(3, Binding.None)] Vector1 A_Equal_B,
        [Slot(4, Binding.None)] Vector1 A_Less_B,
        [Slot(5, Binding.None)] out Vector1 Out)
    {
        return
            @"
{
float out_;
if (A > B) {
out_ = A_Greater_B;
}
if (A == B) {
out_ = A_Equal_B;
}
if (A < B) {
out_ = A_Less_B;
}
 Out = out_;
} 
";
    }
}

[Title("Utility", "Logic", "If_Vector2")]
public class IFNodeVector2 : CodeFunctionNode
{
    public IFNodeVector2()
    {
        name = "If_Vector2";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("IFNodeVector2_Function",
            BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string IFNodeVector2_Function(
        [Slot(0, Binding.None)] Vector1 A,
        [Slot(1, Binding.None)] Vector1 B,
        [Slot(2, Binding.None)] Vector2 A_Greater_B,
        [Slot(3, Binding.None)] Vector2 A_Equal_B,
        [Slot(4, Binding.None)] Vector2 A_Less_B,
        [Slot(5, Binding.None)] out Vector2 Out)
    {
        Out = Vector2.zero;
        return
            @"
{
float2 out_;
if (A > B) {
out_ = A_Greater_B;
}
if (A == B) {
out_ = A_Equal_B;
}
if (A < B) {
out_ = A_Less_B;
}
 Out = out_;
} 
";
    }
}

[Title("Utility", "Logic", "If_Vector3")]
public class IFNodeVector3 : CodeFunctionNode
{
    public IFNodeVector3()
    {
        name = "If_Vector3";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("IFNodeVector3_Function",
            BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string IFNodeVector3_Function(
        [Slot(0, Binding.None)] Vector1 A,
        [Slot(1, Binding.None)] Vector1 B,
        [Slot(2, Binding.None)] Vector3 A_Greater_B,
        [Slot(3, Binding.None)] Vector3 A_Equal_B,
        [Slot(4, Binding.None)] Vector3 A_Less_B,
        [Slot(5, Binding.None)] out Vector3 Out)
    {
        Out = Vector3.zero;
        return
            @"
{
float3 out_;
if (A > B) {
out_ = A_Greater_B;
}
if (A == B) {
out_ = A_Equal_B;
}
if (A < B) {
out_ = A_Less_B;
}
 Out = out_;
} 
";
    }
}

[Title("Utility", "Logic", "If_Vector4")]
public class IFNode_Vector4 : CodeFunctionNode
{
    public IFNode_Vector4()
    {
        name = "If_Vector4";
    }

    protected override MethodInfo GetFunctionToConvert()
    {
        return GetType().GetMethod("IFNode_Vector4_Function",
            BindingFlags.Static | BindingFlags.NonPublic);
    }

    static string IFNode_Vector4_Function(
        [Slot(0, Binding.None)] Vector1 A,
        [Slot(1, Binding.None)] Vector1 B,
        [Slot(2, Binding.None)] Vector4 A_Greater_B,
        [Slot(3, Binding.None)] Vector4 A_Equal_B,
        [Slot(4, Binding.None)] Vector4 A_Less_B,
        [Slot(5, Binding.None)] out Vector4 Out)
    {
        Out = Vector4.zero;
        return
            @"
{
float4 out_;
if (A > B) {
out_ = A_Greater_B;
}
if (A == B) {
out_ = A_Equal_B;
}
if (A < B) {
out_ = A_Less_B;
}
 Out = out_;
} 
";
    }
    public override PreviewMode previewMode
    {
        get
        {
            return PreviewMode.Preview2D;
        }
    }
}
#endif