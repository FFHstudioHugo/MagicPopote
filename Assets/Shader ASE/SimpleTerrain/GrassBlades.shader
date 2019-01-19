// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GrassBlades"
{
	Properties
	{
		_TreeOffset("Tree Offset", Vector) = (0,5,0,0)
		_MainTex("MainTex", 2D) = "white" {}
		_TreeInstanceColor("TreeInstanceColor", Color) = (0,0,0,0)
		_TreeInstanceScale("_TreeInstanceScale", Vector) = (0,0,0,0)
		_SecondaryFactor("SecondaryFactor", Float) = 0
		_PrimaryFactor("PrimaryFactor", Float) = 0
		_EdgeFlutter("EdgeFlutter", Float) = 1
		_BranchPhase("BranchPhase", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 4.6
		#include "TerrainEngine.cginc"
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _BranchPhase;
		uniform float _EdgeFlutter;
		uniform float _PrimaryFactor;
		uniform float _SecondaryFactor;
		uniform float3 _TreeOffset;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;


		float4 WindAnimateVertex1_g1( float4 Pos , float3 Normal , float4 AnimParams )
		{
			return AnimateVertex(Pos,Normal,AnimParams);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_vertex4Pos = v.vertex;
			float4 Pos1_g1 = ase_vertex4Pos;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 Normal1_g1 = ase_vertexNormal;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 normalizeResult52 = normalize( ase_worldPos );
			float4 appendResult15 = (float4(_BranchPhase , ( _EdgeFlutter * ( (normalizeResult52).x + (normalizeResult52).z ) ) , _PrimaryFactor , _SecondaryFactor));
			float4 AnimParams1_g1 = appendResult15;
			float4 localWindAnimateVertex1_g1 = WindAnimateVertex1_g1( Pos1_g1 , Normal1_g1 , AnimParams1_g1 );
			v.vertex.xyz += ( ( localWindAnimateVertex1_g1 * _TreeInstanceScale ) + float4( _TreeOffset , 0.0 ) ).xyz;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = ( _TreeInstanceColor * tex2D( _MainTex, uv_MainTex ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16200
7.2;5.6;1461;830;2064.14;471.6387;1.799701;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;47;-1613.94,374.7962;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;52;-1433.848,405.8031;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;53;-1276.848,359.8031;Float;False;FLOAT;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;54;-1282.758,461.1884;Float;False;FLOAT;2;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-940.1017,344.933;Float;False;Property;_EdgeFlutter;EdgeFlutter;6;0;Create;True;0;0;False;0;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-1107.126,391.6696;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-855.2003,648.8994;Float;False;Property;_SecondaryFactor;SecondaryFactor;4;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-863.3002,544.9996;Float;False;Property;_PrimaryFactor;PrimaryFactor;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-873.9003,235.7;Float;False;Property;_BranchPhase;BranchPhase;7;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-781.8696,411.4852;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-609.5466,421.1271;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;31;-349.7917,473.8345;Float;False;Property;_TreeInstanceScale;_TreeInstanceScale;3;0;Fetch;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;57;-413.5,307;Float;False;Terrain Wind Animate Vertex;-1;;1;3bc81bd4568a7094daabf2ccd6a7e125;0;3;2;FLOAT4;0,0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;30;-210.4572,-369.9227;Float;False;Property;_TreeInstanceColor;TreeInstanceColor;2;0;Fetch;True;0;0;False;0;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-422.5,-168;Float;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;b3101af65b8fa814e8bbcda4070eef97;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;23;-46.3596,535.886;Float;False;Property;_TreeOffset;Tree Offset;0;0;Create;True;0;0;False;0;0,5,0;0,0.48,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-87.62848,267.1468;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;24.54279,-228.9227;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;27;-1096.637,111.2048;Float;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;26;-1101.637,-46.79521;Float;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;25;-1076.236,-207.5978;Float;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;24;-773.6367,-57.79521;Float;False;TerrainBillboardTree(Pos, Offset, OffsetZ)@$return@;7;False;3;True;Pos;FLOAT4;0,0,0,0;InOut;;Float;True;Offset;FLOAT2;0,0;In;;Float;True;OffsetZ;FLOAT;0;In;;Float;TerrainBillboardTree;True;False;0;4;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT4;2
Node;AmplifyShaderEditor.SimpleAddOpNode;22;94.68432,343.3854;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;62;313.7847,191.5575;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;GrassBlades;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;52;0;47;0
WireConnection;53;0;52;0
WireConnection;54;0;52;0
WireConnection;48;0;53;0
WireConnection;48;1;54;0
WireConnection;56;0;17;0
WireConnection;56;1;48;0
WireConnection;15;0;16;0
WireConnection;15;1;56;0
WireConnection;15;2;18;0
WireConnection;15;3;19;0
WireConnection;57;4;15;0
WireConnection;28;0;57;0
WireConnection;28;1;31;0
WireConnection;29;0;30;0
WireConnection;29;1;3;0
WireConnection;24;1;25;0
WireConnection;24;2;26;0
WireConnection;24;3;27;2
WireConnection;22;0;28;0
WireConnection;22;1;23;0
WireConnection;62;0;29;0
WireConnection;62;11;22;0
ASEEND*/
//CHKSM=35F73FAE3BD1B70C6FAD4AF28D7ECC5EAC1DF7F0