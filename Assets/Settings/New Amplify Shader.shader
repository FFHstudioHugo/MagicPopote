// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "gHairShaderAmp"
{
    Properties
    {
        [HideInInspector] __dirty( "", Int ) = 1
        _MaskClipValue( "Mask Clip Value", Float ) = 0.25
        _MainTex("_MainTex", 2D) = "white" {}
        _NormalMap("_NormalMap", 2D) = "bump" {}
        _Specular("_Specular", Range( 0 , 0.5)) = 0.35
        _Emission("_Emission", Range( 0 , 0.2)) = 0.8
        _Smoothness("_Smoothness", Range( 0 , 1)) = 0.8
        _Color("_Color", Color) = (1,1,1,0)
        [HideInInspector] _texcoord( "", 2D ) = "white" {}
    }
 
    SubShader
    {
        Tags{ "RenderType" = "Overlay"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
        LOD 200
        Cull Off
        Blend One Zero , OneMinusDstColor One
        BlendOp Add , Add
        CGPROGRAM
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows
        struct Input
        {
            float2 uv_texcoord;
        };
 
        uniform sampler2D _NormalMap;
        uniform float4 _NormalMap_ST;
        uniform sampler2D _MainTex;
        uniform float4 _MainTex_ST;
        uniform float4 _Color;
        uniform float _Emission;
        uniform float _Specular;
        uniform float _Smoothness;
        uniform float _MaskClipValue = 0.25;
 
        void surf( Input i , inout SurfaceOutputStandardSpecular o )
        {
            float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
            float3 txNormalMap69 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
            o.Normal = txNormalMap69;
            float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
            float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
            float4 txMainTex40 = tex2DNode1;
            float4 cColor39 = _Color;
            float4 blendOpSrc17 = txMainTex40;
            float4 blendOpDest17 = cColor39;
            float4 blendOpSrc56 = float4(0.1985294,0.1985294,0.1985294,1);
            float4 blendOpDest56 = ( saturate( ( blendOpSrc17 * blendOpDest17 ) ));
            float4 blendOpSrc25 = ( saturate( ( blendOpDest56 > 0.5 ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest56 - 0.5 ) ) * ( 1.0 - blendOpSrc56 ) ) : ( 2.0 * blendOpDest56 * blendOpSrc56 ) ) ));
            float4 blendOpDest25 = txMainTex40;
            float4 cFinalColor62 = ( saturate( 2.0f*blendOpSrc25*blendOpDest25 + blendOpSrc25*blendOpSrc25*(1.0f - 2.0f*blendOpDest25) ));
            o.Albedo = cFinalColor62.xyz;
            o.Emission = ( cFinalColor62 * _Emission ).xyz;
            o.Specular = ( cFinalColor62 * _Specular ).xyz;
            o.Smoothness = ( txMainTex40 * _Smoothness ).x;
            float3 desaturateVar26 = lerp( txMainTex40.xyz,dot(txMainTex40.xyz,float3(0.299,0.587,0.114)),0.0);
            o.Occlusion = desaturateVar26.x;
            o.Alpha = 1;
            float txMainTexAlpha67 = tex2DNode1.a;
            clip( txMainTexAlpha67 - _MaskClipValue );
        }
 
        ENDCG
    }
    Fallback "Standard"
    Fallback "Diffuse"
    CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=12001
-1916;39;1901;909;2653.998;944.901;2.2;True;True
Node;AmplifyShaderEditor.ColorNode;16;-1366.405,-274.701;Float;False;Property;_Color;_Color;6;0;1,1,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;1;-1361.995,-101.3999;Float;True;Property;_MainTex;_MainTex;1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-1000.796,-101.503;Float;False;txMainTex;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.GetLocalVarNode;42;-1167.188,-490.4036;Float;False;39;0;1;COLOR
Node;AmplifyShaderEditor.GetLocalVarNode;41;-1167.188,-560.8038;Float;False;40;0;1;FLOAT4
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-1111.001,-274.7029;Float;False;cColor;-1;True;1;0;COLOR;0.0;False;1;COLOR
Node;AmplifyShaderEditor.BlendOpsNode;17;-890.9962,-556.603;Float;False;Multiply;True;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;61;-941.884,-719.404;Float;False;Constant;_Color0;Color 0;7;0;0.1985294,0.1985294,0.1985294,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.GetLocalVarNode;43;-662.9948,-623.8038;Float;False;40;0;1;FLOAT4
Node;AmplifyShaderEditor.BlendOpsNode;56;-647.2861,-714.7031;Float;False;Overlay;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.BlendOpsNode;25;-404.0996,-715.2054;Float;False;SoftLight;True;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;6;-578.0001,-90.60017;Float;False;Property;_Specular;_Specular;3;0;0.35;0;0.5;0;1;FLOAT
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-192.9076,-720.2026;Float;False;cFinalColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SamplerNode;2;-1364.893,98.39755;Float;True;Property;_NormalMap;_NormalMap;2;0;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;5;-584.0996,344;Float;False;Property;_Smoothness;_Smoothness;5;0;0.8;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.GetLocalVarNode;66;-533.8846,75.8983;Float;False;40;0;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;27;-577.4026,-235.1029;Float;False;Property;_Emission;_Emission;4;0;0.8;0;0.2;0;1;FLOAT
Node;AmplifyShaderEditor.GetLocalVarNode;65;-521.0936,269.7984;Float;False;40;0;1;FLOAT4
Node;AmplifyShaderEditor.GetLocalVarNode;64;-514.4081,-160.2046;Float;False;62;0;1;FLOAT4
Node;AmplifyShaderEditor.DesaturateOpNode;26;-284.9995,80.99825;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-238.8986,-107.899;Float;False;2;2;0;FLOAT4;0;False;1;FLOAT;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-237.4007,-200.3017;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.GetLocalVarNode;70;-85.99923,-217.7016;Float;False;69;0;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;63;-45.61165,-290.5042;Float;False;62;0;1;FLOAT4
Node;AmplifyShaderEditor.GetLocalVarNode;68;-24.1917,344.0987;Float;False;67;0;1;FLOAT
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-1005,103.9978;Float;False;txNormalMap;-1;True;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-248.3968,274.8994;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-1003.487,6.49826;Float;False;txMainTexAlpha;-1;True;1;0;FLOAT;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;416.7996,122.5;Float;False;True;2;Float;ASEMaterialInspector;200;StandardSpecular;gHairShaderAmp;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;True;Off;0;0;False;0;0;Custom;0.25;True;True;0;True;Overlay;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;SrcAlpha;SrcColor;5;OneMinusDstColor;One;Sub;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;200;Standard;0;-1;-1;-1;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;40;0;1;0
WireConnection;39;0;16;0
WireConnection;17;0;41;0
WireConnection;17;1;42;0
WireConnection;56;0;61;0
WireConnection;56;1;17;0
WireConnection;25;0;56;0
WireConnection;25;1;43;0
WireConnection;62;0;25;0
WireConnection;26;0;66;0
WireConnection;15;0;64;0
WireConnection;15;1;6;0
WireConnection;28;0;64;0
WireConnection;28;1;27;0
WireConnection;69;0;2;0
WireConnection;21;0;65;0
WireConnection;21;1;5;0
WireConnection;67;0;1;4
WireConnection;0;0;63;0
WireConnection;0;1;70;0
WireConnection;0;2;28;0
WireConnection;0;3;15;0
WireConnection;0;4;21;0
WireConnection;0;5;26;0
WireConnection;0;10;68;0
ASEEND*/
//CHKSM=394F433D6B2990C70BD2F34B7F741C37272CD844