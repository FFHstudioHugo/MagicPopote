// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FAE/Grass"
{
    Properties
    {
		_ColorTop("ColorTop", Color) = (0.3001064,0.6838235,0,1)
		_ColorBottom("Color Bottom", Color) = (0.232,0.5,0,1)
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset][Normal]_BumpMap("BumpMap", 2D) = "bump" {}
		_ColorVariation("ColorVariation", Range( 0 , 0.2)) = 0.05
		_AmbientOcclusion("AmbientOcclusion", Range( 0 , 1)) = 0
		_TransmissionSize("Transmission Size", Range( 0 , 20)) = 1
		_TransmissionAmount("Transmission Amount", Range( 0 , 10)) = 2.696819
		_MaxWindStrength("Max Wind Strength", Range( 0 , 1)) = 0.126967
		_WindSwinging("WindSwinging", Range( 0 , 1)) = 0.25
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 1
		_PigmentMapInfluence("PigmentMapInfluence", Range( 0 , 1)) = 0
		_PigmentMapHeight("PigmentMapHeight", Range( 0 , 1)) = 0
		_BendingTint("BendingTint", Range( -0.1 , 0.1)) = -0.05
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
    }

    SubShader
    {
        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Cull Off
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		
        Pass
        {
			
        	Tags { "LightMode"="LightweightForward" }

        	Name "Base"
			Blend Off
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
            
        	HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

        	// -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            
        	// -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
        	#pragma fragment frag

        	#define _NORMALMAP 1
        	#define _SPECULAR_SETUP 1
        	#define _AlphaClip 1


        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"

            CBUFFER_START(UnityPerMaterial)
			float _MaxWindStrength;
			float _WindStrength;
			sampler2D _WindVectors;
			float _WindAmplitudeMultiplier;
			float _WindAmplitude;
			float _WindSpeed;
			float4 _WindDirection;
			float _WindSwinging;
			float4 _ColorTop;
			float4 _ColorBottom;
			sampler2D _MainTex;
			sampler2D _PigmentMap;
			float4 _TerrainUV;
			float _PigmentMapHeight;
			float _PigmentMapInfluence;
			float _ColorVariation;
			float _TransmissionSize;
			float _TransmissionAmount;
			float _BendingTint;
			float _AmbientOcclusion;
			float _WindDebug;
			sampler2D _BumpMap;
			CBUFFER_END
			
			
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct GraphVertexOutput
            {
                float4 clipPos                : SV_POSITION;
                float4 lightmapUVOrVertexSH	  : TEXCOORD0;
        		half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
            	float4 shadowCoord            : TEXCOORD2;
				float4 tSpace0					: TEXCOORD3;
				float4 tSpace1					: TEXCOORD4;
				float4 tSpace2					: TEXCOORD5;
				float4 ase_color : COLOR;
				float4 ase_texcoord7 : TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            	UNITY_VERTEX_OUTPUT_STEREO
            };


            GraphVertexOutput vert (GraphVertexInput v)
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float WindStrength522 = _WindStrength;
				float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
				float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( 1.0 * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.z ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
				float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 * v.ase_color.r ) , float3( 0,0,0 ) , ( 1.0 - v.ase_color.r ));
				float3 Wind84 = lerpResult74;
				float3 break437 = Wind84;
				float3 appendResult391 = (float3(break437.x , 0.0 , break437.z));
				float3 VertexOffset330 = appendResult391;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				v.vertex.xyz += VertexOffset330;
				v.ase_normal = float3(0,1,0);

        		// Vertex shader outputs defined by graph
                float3 lwWNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 lwWTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 lwWBinormal = normalize(cross(lwWNormal, lwWTangent) * v.ase_tangent.w);
				o.tSpace0 = float4(lwWTangent.x, lwWBinormal.x, lwWNormal.x, lwWorldPos.x);
				o.tSpace1 = float4(lwWTangent.y, lwWBinormal.y, lwWNormal.y, lwWorldPos.y);
				o.tSpace2 = float4(lwWTangent.z, lwWBinormal.z, lwWNormal.z, lwWorldPos.z);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                
         		// We either sample GI from lightmap or SH.
        	    // Lightmap UV and vertex SH coefficients use the same interpolator ("float2 lightmapUV" for lightmap or "half3 vertexSH" for SH)
                // see DECLARE_LIGHTMAP_OR_SH macro.
        	    // The following funcions initialize the correct variable with correct data
        	    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
        	    OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz);

        	    half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
        	    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
        	    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
        	    o.clipPos = vertexInput.positionCS;

        	#ifdef _MAIN_LIGHT_SHADOWS
        		o.shadowCoord = GetShadowCoord(vertexInput);
        	#endif
        		return o;
        	}

        	half4 frag (GraphVertexOutput IN ) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(IN);

        		float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = SafeNormalize( _WorldSpaceCameraPos.xyz  - WorldSpacePosition );
    
				float4 lerpResult363 = lerp( _ColorTop , _ColorBottom , ( 1.0 - IN.ase_color.r ));
				float2 uv_MainTex97 = IN.ase_texcoord7.xy;
				float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
				float4 BaseColor551 = ( lerpResult363 * tex2DNode97 );
				float4 TopColor549 = _ColorTop;
				float2 appendResult483 = (float2(_TerrainUV.z , _TerrainUV.w));
				float2 TerrainUV324 = ( ( ( 1.0 - appendResult483 ) / _TerrainUV.x ) + ( ( _TerrainUV.x / ( _TerrainUV.x * _TerrainUV.x ) ) * (WorldSpacePosition).xz ) );
				float4 PigmentMapTex320 = tex2D( _PigmentMap, TerrainUV324 );
				float lerpResult416 = lerp( ( 1.0 - IN.ase_color.r ) , 1.0 , _PigmentMapHeight);
				float4 lerpResult376 = lerp( TopColor549 , PigmentMapTex320 , lerpResult416);
				float4 lerpResult290 = lerp( BaseColor551 , lerpResult376 , _PigmentMapInfluence);
				float4 PigmentMapColor526 = lerpResult290;
				float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
				float3 WindVector91 = UnpackNormalmapRGorAG( tex2D( _WindVectors, ( ( ( 1.0 * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.z ) * appendResult469 ) ) ), 1.0f );
				float3 break240 = WindVector91;
				float WindStrength522 = _WindStrength;
				float WindTint523 = saturate( ( ( ( break240.x * break240.y ) * IN.ase_color.r ) * _ColorVariation * WindStrength522 ) );
				float3 Color161 = ( (PigmentMapColor526).rgb + WindTint523 );
				float dotResult141 = dot( -WorldSpaceViewDirection , _MainLightPosition.xyz );
				float Heightmap518 = (PigmentMapTex320).a;
				float Subsurface153 = saturate( ( ( ( ( pow( max( dotResult141 , 0.0 ) , _TransmissionSize ) * _TransmissionAmount ) * IN.ase_color.r ) * Heightmap518 ) * 1 ) );
				float3 lerpResult106 = lerp( Color161 , ( Color161 * 2.0 ) , Subsurface153);
				float3 temp_cast_0 = (( 0 * _BendingTint )).xxx;
				float clampResult302 = clamp( ( ( IN.ase_color.r * 1.33 ) * _AmbientOcclusion ) , 0.0 , 1.0 );
				float lerpResult115 = lerp( 1.0 , clampResult302 , _AmbientOcclusion);
				float AmbientOcclusion207 = lerpResult115;
				float3 FinalColor205 = ( ( lerpResult106 - temp_cast_0 ) * AmbientOcclusion207 );
				float3 lerpResult310 = lerp( FinalColor205 , WindVector91 , _WindDebug);
				
				float2 uv_BumpMap172 = IN.ase_texcoord7.xy;
				float3 Normals174 = UnpackNormalmapRGorAG( tex2D( _BumpMap, uv_BumpMap172 ), 1.0 );
				
				float4 color683 = IsGammaSpace() ? float4(0.07058824,0,0.1058824,0) : float4(0.006048833,0,0.0109601,0);
				half3 temp_cast_1 = (color683.b).xxx;
				
				float Alpha98 = tex2DNode97.a;
				float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
				
				
		        float3 Albedo = lerpResult310;
				float3 Normal = Normals174;
				float3 Emission = 0;
				float3 Specular = temp_cast_1;
				float Metallic = 0;
				float Smoothness = color683.r;
				float Occlusion = 1;
				float Alpha = lerpResult313;
				float AlphaClipThreshold = 0.5;

        		InputData inputData;
        		inputData.positionWS = WorldSpacePosition;

        #ifdef _NORMALMAP
        	    inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal)));
        #else
            #if !SHADER_HINT_NICE_QUALITY
                inputData.normalWS = WorldSpaceNormal;
            #else
        	    inputData.normalWS = normalize(WorldSpaceNormal);
            #endif
        #endif

        #if !SHADER_HINT_NICE_QUALITY
        	    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
        	    inputData.viewDirectionWS = WorldSpaceViewDirection;
        #else
        	    inputData.viewDirectionWS = normalize(WorldSpaceViewDirection);
        #endif

        	    inputData.shadowCoord = IN.shadowCoord;

        	    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
        	    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
        	    inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS);

        		half4 color = LightweightFragmentPBR(
        			inputData, 
        			Albedo, 
        			Metallic, 
        			Specular, 
        			Smoothness, 
        			Occlusion, 
        			Emission, 
        			Alpha);

			#ifdef TERRAIN_SPLAT_ADDPASS
				color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
			#else
				color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
			#endif

        #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

		#if ASE_LW_FINAL_COLOR_ALPHA_MULTIPLY
				color.rgb *= color.a;
		#endif
        		return color;
            }

        	ENDHLSL
        }

		
        Pass
        {
			
        	Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #define _NORMALMAP 1
            #define _AlphaClip 1


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            CBUFFER_START(UnityPerMaterial)
			float _MaxWindStrength;
			float _WindStrength;
			sampler2D _WindVectors;
			float _WindAmplitudeMultiplier;
			float _WindAmplitude;
			float _WindSpeed;
			float4 _WindDirection;
			float _WindSwinging;
			sampler2D _MainTex;
			float _WindDebug;
			CBUFFER_END
			
			
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord7 : TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
        	};

            // x: global clip space bias, y: normal world space bias
            float4 _ShadowBias;
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(GraphVertexInput v)
        	{
        	    VertexOutput o;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

				float WindStrength522 = _WindStrength;
				float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
				float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( 1.0 * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.z ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
				float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 * v.ase_color.r ) , float3( 0,0,0 ) , ( 1.0 - v.ase_color.r ));
				float3 Wind84 = lerpResult74;
				float3 break437 = Wind84;
				float3 appendResult391 = (float3(break437.x , 0.0 , break437.z));
				float3 VertexOffset330 = appendResult391;
				
				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;

				v.vertex.xyz += VertexOffset330;
				v.ase_normal = float3(0,1,0);

        	    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

                float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
                float scale = invNdotL * _ShadowBias.y;

                // normal bias is negative since we want to apply an inset normal offset
                positionWS = normalWS * scale.xxx + positionWS;
                float4 clipPos = TransformWorldToHClip(positionWS);

                // _ShadowBias.x sign depens on if platform has reversed z buffer
                clipPos.z += _ShadowBias.x;

        	#if UNITY_REVERSED_Z
        	    clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#else
        	    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#endif
                o.clipPos = clipPos;

        	    return o;
        	}

            half4 ShadowPassFragment(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

               float2 uv_MainTex97 = IN.ase_texcoord7.xy;
               float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
               float Alpha98 = tex2DNode97.a;
               float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
               

				float Alpha = lerpResult313;
				float AlphaClipThreshold = 0.5;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }

            ENDHLSL
        }

		
        Pass
        {
			
        	Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }

            ZWrite On
			ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            #define _NORMALMAP 1
            #define _AlphaClip 1


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			CBUFFER_START(UnityPerMaterial)
			float _MaxWindStrength;
			float _WindStrength;
			sampler2D _WindVectors;
			float _WindAmplitudeMultiplier;
			float _WindAmplitude;
			float _WindSpeed;
			float4 _WindDirection;
			float _WindSwinging;
			sampler2D _MainTex;
			float _WindDebug;
			CBUFFER_END
			
			
           
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float WindStrength522 = _WindStrength;
				float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
				float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( 1.0 * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.z ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
				float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 * v.ase_color.r ) , float3( 0,0,0 ) , ( 1.0 - v.ase_color.r ));
				float3 Wind84 = lerpResult74;
				float3 break437 = Wind84;
				float3 appendResult391 = (float3(break437.x , 0.0 , break437.z));
				float3 VertexOffset330 = appendResult391;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				v.vertex.xyz += VertexOffset330;
				v.ase_normal = float3(0,1,0);

        	    o.clipPos = TransformObjectToHClip(v.vertex.xyz);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

				float2 uv_MainTex97 = IN.ase_texcoord.xy;
				float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
				float Alpha98 = tex2DNode97.a;
				float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
				

				float Alpha = lerpResult313;
				float AlphaClipThreshold = 0.5;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
		
        Pass
        {
			
        	Name "Meta"
            Tags { "LightMode"="Meta" }

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

            #pragma vertex vert
            #pragma fragment frag


            #define _NORMALMAP 1
            #define _AlphaClip 1


			uniform float4 _MainTex_ST;

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			CBUFFER_START(UnityPerMaterial)
			float _MaxWindStrength;
			float _WindStrength;
			sampler2D _WindVectors;
			float _WindAmplitudeMultiplier;
			float _WindAmplitude;
			float _WindSpeed;
			float4 _WindDirection;
			float _WindSwinging;
			float4 _ColorTop;
			float4 _ColorBottom;
			sampler2D _MainTex;
			sampler2D _PigmentMap;
			float4 _TerrainUV;
			float _PigmentMapHeight;
			float _PigmentMapInfluence;
			float _ColorVariation;
			float _TransmissionSize;
			float _TransmissionAmount;
			float _BendingTint;
			float _AmbientOcclusion;
			float _WindDebug;
			CBUFFER_END
			
			
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature EDITOR_VISUALIZATION


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_color : COLOR;
                float4 ase_texcoord : TEXCOORD0;
                float4 ase_texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float WindStrength522 = _WindStrength;
				float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
				float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( 1.0 * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.z ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
				float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 * v.ase_color.r ) , float3( 0,0,0 ) , ( 1.0 - v.ase_color.r ));
				float3 Wind84 = lerpResult74;
				float3 break437 = Wind84;
				float3 appendResult391 = (float3(break437.x , 0.0 , break437.z));
				float3 VertexOffset330 = appendResult391;
				
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;

				v.vertex.xyz += VertexOffset330;
				v.ase_normal = float3(0,1,0);
				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float4 lerpResult363 = lerp( _ColorTop , _ColorBottom , ( 1.0 - IN.ase_color.r ));
           		float2 uv_MainTex97 = IN.ase_texcoord.xy;
           		float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
           		float4 BaseColor551 = ( lerpResult363 * tex2DNode97 );
           		float4 TopColor549 = _ColorTop;
           		float2 appendResult483 = (float2(_TerrainUV.z , _TerrainUV.w));
           		float3 ase_worldPos = IN.ase_texcoord1.xyz;
           		float2 TerrainUV324 = ( ( ( 1.0 - appendResult483 ) / _TerrainUV.x ) + ( ( _TerrainUV.x / ( _TerrainUV.x * _TerrainUV.x ) ) * (ase_worldPos).xz ) );
           		float4 PigmentMapTex320 = tex2D( _PigmentMap, TerrainUV324 );
           		float lerpResult416 = lerp( ( 1.0 - IN.ase_color.r ) , 1.0 , _PigmentMapHeight);
           		float4 lerpResult376 = lerp( TopColor549 , PigmentMapTex320 , lerpResult416);
           		float4 lerpResult290 = lerp( BaseColor551 , lerpResult376 , _PigmentMapInfluence);
           		float4 PigmentMapColor526 = lerpResult290;
           		float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
           		float3 WindVector91 = UnpackNormalmapRGorAG( tex2D( _WindVectors, ( ( ( 1.0 * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.z ) * appendResult469 ) ) ), 1.0f );
           		float3 break240 = WindVector91;
           		float WindStrength522 = _WindStrength;
           		float WindTint523 = saturate( ( ( ( break240.x * break240.y ) * IN.ase_color.r ) * _ColorVariation * WindStrength522 ) );
           		float3 Color161 = ( (PigmentMapColor526).rgb + WindTint523 );
           		float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
           		ase_worldViewDir = normalize(ase_worldViewDir);
           		float dotResult141 = dot( -ase_worldViewDir , _MainLightPosition.xyz );
           		float Heightmap518 = (PigmentMapTex320).a;
           		float Subsurface153 = saturate( ( ( ( ( pow( max( dotResult141 , 0.0 ) , _TransmissionSize ) * _TransmissionAmount ) * IN.ase_color.r ) * Heightmap518 ) * 1 ) );
           		float3 lerpResult106 = lerp( Color161 , ( Color161 * 2.0 ) , Subsurface153);
           		float3 temp_cast_0 = (( 0 * _BendingTint )).xxx;
           		float clampResult302 = clamp( ( ( IN.ase_color.r * 1.33 ) * _AmbientOcclusion ) , 0.0 , 1.0 );
           		float lerpResult115 = lerp( 1.0 , clampResult302 , _AmbientOcclusion);
           		float AmbientOcclusion207 = lerpResult115;
           		float3 FinalColor205 = ( ( lerpResult106 - temp_cast_0 ) * AmbientOcclusion207 );
           		float3 lerpResult310 = lerp( FinalColor205 , WindVector91 , _WindDebug);
           		
           		float Alpha98 = tex2DNode97.a;
           		float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
           		
				
		        float3 Albedo = lerpResult310;
				float3 Emission = 0;
				float Alpha = lerpResult313;
				float AlphaClipThreshold = 0.5;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = Albedo;
                metaInput.Emission = Emission;
                
                return MetaFragment(metaInput);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/InternalErrorShader"
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16105
512;6.4;842;795;-1955.3;1098.028;2.124108;True;False
Node;AmplifyShaderEditor.CommentaryNode;368;-4626.298,-1189.271;Float;False;2299.111;956.0105;Comment;16;91;410;222;298;221;72;297;79;520;469;308;384;69;67;319;383;Wind vectors;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;494;-4616.219,-36.44699;Float;False;1616.341;554.3467;Comment;11;324;491;489;490;484;487;485;486;488;483;493;TerrainUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;493;-4566.219,98.85242;Float;False;Global;_TerrainUV;_TerrainUV;2;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;383;-4473.01,-744.6186;Float;False;Constant;_Float7;Float 7;19;0;Create;True;0;0;False;0;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;319;-4571.499,-844.1255;Float;False;Global;_WindSpeed;_WindSpeed;11;0;Create;True;0;0;False;0;0.5;0.123;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;485;-4238.418,217.5534;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;483;-4236.418,14.55324;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-4142.394,-791.1456;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;384;-4261.245,-952.3274;Float;False;Constant;_Float8;Float 8;19;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;69;-4267.893,-645.5446;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;484;-4261.365,342.0453;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;308;-4253.298,-447.8275;Float;False;Global;_WindDirection;_WindDirection;13;0;Create;True;0;0;False;0;1,0,0,0;-0.9602937,0,-0.2789911,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;488;-4052.417,13.55305;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;520;-3931.458,-888.7498;Float;False;Global;_WindAmplitude;_WindAmplitude;20;0;Create;True;0;0;False;0;1;1.45;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;297;-3930.545,-974.5492;Float;False;Property;_WindAmplitudeMultiplier;WindAmplitudeMultiplier;11;0;Create;True;0;0;False;0;1;0.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;487;-4013.361,345.0453;Float;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-3930.196,-690.6456;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;469;-3949.837,-411.0562;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-4054.306,-1068.048;Float;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;486;-4015.417,165.5533;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;-3689.792,-564.3065;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;490;-3739.417,30.55324;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-3587.035,-1024.596;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;-3747.159,276.6454;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;222;-3383.589,-914.0057;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;371;-2159.553,-389.6831;Float;False;1807.377;845.9116;Comment;10;98;551;549;293;363;97;501;292;362;364;Base color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;491;-3506.654,157.7434;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;372;-2169.662,764.7435;Float;False;2290.708;651.5013;Comment;14;554;553;417;418;416;376;552;291;290;526;320;458;325;550;Pigment map;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;160;-2158.058,2130.086;Float;False;2711.621;557.9603;Subsurface scattering;16;153;147;148;146;145;141;143;139;140;138;454;455;517;580;591;677;Subsurface color simulation;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;410;-3145.582,-934.1251;Float;True;Global;_WindVectors;_WindVectors;8;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;6c795dd1d1d319e479e68164001557e8;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;364;-2104.4,156.0724;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;324;-3331.81,149.9584;Float;False;TerrainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;501;-1906.319,177.3479;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;-2093.259,862.8002;Float;False;324;TerrainUV;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-2817.208,-931.3988;Float;False;WindVector;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;362;-2105.6,-131.9273;Float;False;Property;_ColorBottom;Color Bottom;1;0;Create;True;0;0;False;0;0.232,0.5,0,1;0.4881234,0.735849,0.2464396,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;138;-2082.26,2183.486;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;373;-2151.307,1610.689;Float;False;1792.004;391.326;Comment;10;523;514;274;101;511;239;86;240;93;525;Color through wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;292;-2109.553,-339.6831;Float;False;Property;_ColorTop;ColorTop;0;0;Create;True;0;0;False;0;0.3001064,0.6838235,0,1;0.689903,0.9528301,0.4269754,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;140;-2110.257,2346.486;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexColorNode;553;-1730.855,1081.685;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;363;-1669.001,-181.4273;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2101.308,1660.688;Float;False;91;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;97;-1599.225,-27.15059;Float;True;Property;_MainTex;MainTex;2;1;[NoScaleOffset];Create;True;0;0;False;0;None;e3a9522ecae56444b9d4e7a0eb9d6e78;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;139;-1852.259,2187.486;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;369;-2173.667,-1224.785;Float;False;2670.73;665.021;Comment;16;277;248;16;247;83;249;66;70;74;84;385;408;495;500;521;522;Wind animations;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;458;-1818.367,841.5786;Float;True;Global;_PigmentMap;_PigmentMap;14;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;320;-1391.236,971.0171;Float;False;PigmentMapTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;418;-1553.225,1287.669;Float;False;Property;_PigmentMapHeight;PigmentMapHeight;13;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-1102.412,-1079.697;Float;False;Global;_WindStrength;_WindStrength;19;0;Create;True;0;0;False;0;1;0.66;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;367;-5009.526,-2311.25;Float;False;2652.407;770.0325;Comment;3;518;467;466;Grass length;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;417;-1381.084,1203.605;Float;False;Constant;_Float17;Float 17;22;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;141;-1650.26,2244.486;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;240;-1853.897,1663.845;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-1266.153,-190.7834;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;549;-1803.634,-324.2867;Float;False;TopColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;554;-1492.835,1104.332;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;86;-1620.504,1798.089;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;677;-1471.816,2277.8;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;416;-1150.131,1169.972;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;522;-875.6971,-1086.247;Float;False;WindStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;551;-916.9384,-188.8136;Float;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-1802.957,2520.286;Float;False;Property;_TransmissionSize;Transmission Size;6;0;Create;True;0;0;False;0;1;2.6;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;466;-4895.62,-2190.839;Float;False;320;PigmentMapTex;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;-1576.098,1662.443;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;550;-1041.996,914.0365;Float;False;549;TopColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;467;-4572.831,-2184.625;Float;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;525;-1320.113,1918.377;Float;False;522;WindStrength;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;145;-1268.258,2248.486;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;552;-606.5386,886.5524;Float;False;551;BaseColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;511;-1369.941,1663.164;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-1372.059,2403.886;Float;False;Property;_TransmissionAmount;Transmission Amount;7;0;Create;True;0;0;False;0;2.696819;5.4;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-844.2086,1132.682;Float;False;Property;_PigmentMapInfluence;PigmentMapInfluence;12;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-1383.694,1796.119;Float;False;Property;_ColorVariation;ColorVariation;4;0;Create;True;0;0;False;0;0.05;0;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;376;-764.7234,954.6284;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;290;-381.0104,925.5381;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;518;-4264.615,-2069.821;Float;False;Heightmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;521;-2129.14,-973.3709;Float;False;91;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-1049.659,2246.286;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;148;-870.4499,2347.415;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-967.168,1664.503;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;236;1488.743,-1237.9;Float;False;3425.277;437.2272;;16;205;519;208;534;106;532;530;295;531;161;296;513;527;524;542;589;Final color;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;277;-1874.768,-977.4964;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;526;-136.4222,922.5243;Float;False;PigmentMapColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;159;-2143.86,2840.496;Float;False;1813.59;398.8397;AO;11;207;115;114;117;301;118;113;111;302;381;382;Ambient Occlusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;580;-572.8826,2257.451;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;514;-797.2388,1667.527;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;455;-606.7513,2416.463;Float;False;518;Heightmap;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;495;-1579.352,-980.8199;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;408;-1488.413,-837.2699;Float;False;Constant;_Float14;Float 14;20;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;590;-160.5872,2995.596;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;523;-601.9745,1656.407;Float;False;WindTint;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;454;-320.7513,2265.364;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;111;-2093.859,2890.496;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;382;-1814.028,3002.569;Float;False;Constant;_Float6;Float 6;19;0;Create;True;0;0;False;0;1.33;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;527;1519.337,-1175.906;Float;False;526;PigmentMapColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;247;-1262.914,-943.2866;Float;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;589;1776.174,-1167.5;Float;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;591;-71.40287,2266.934;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-1124.974,-745.7667;Float;False;Property;_WindSwinging;WindSwinging;10;0;Create;True;0;0;False;0;0.25;0.51;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-2025.64,3098.476;Float;False;Property;_AmbientOcclusion;AmbientOcclusion;5;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;301;-1574.174,2911.218;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1152.243,-1165.787;Float;False;Property;_MaxWindStrength;Max Wind Strength;9;0;Create;True;0;0;False;0;0.126967;0.15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;524;1663.473,-1020.088;Float;False;523;WindTint;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;-1349.626,3147.969;Float;False;Constant;_Float5;Float 5;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;513;1975.78,-1093.37;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;249;-798.6658,-999.0773;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-1371.343,2935.675;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;517;129.3594,2268.925;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;118;-1256.54,3116.476;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-520.265,-1143.746;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;83;-521.2678,-946.241;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;296;2288.118,-1013.211;Float;False;Constant;_Float1;Float 1;21;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;2145.16,-1162.154;Float;False;Color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;500;-274.7222,-946.4897;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;327.6834,2271.676;Float;False;Subsurface;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;302;-1138.474,2918.418;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-252.8295,-1087.164;Float;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;117;-1218.442,3055.776;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;530;2443.737,-968.2028;Float;False;153;Subsurface;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;115;-856.2404,2935.676;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;74;-6.421254,-1078.501;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;532;2972.651,-977.2318;Float;False;Property;_BendingTint;BendingTint;15;0;Create;True;0;0;False;0;-0.05;0.1;-0.1;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;531;3035.332,-1052.988;Float;False;-1;;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;2487.116,-1075.211;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;374;1831.836,-489.6089;Float;False;2217.195;546.4841;Comment;5;85;330;426;437;391;Vertex function layer blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;247.4628,-1074.753;Float;False;Wind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;534;3485.771,-1019.796;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;106;2795.013,-1177.939;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;-636.6566,2929.231;Float;False;AmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;542;3706.971,-1153.228;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;4239.477,-1030.722;Float;False;207;AmbientOcclusion;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;1935.874,-422.8134;Float;False;84;Wind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;437;3225.992,-389.9932;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;519;4481.406,-1148.504;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;375;2964.505,1790.556;Float;False;352;249.0994;Comment;2;312;311;Debug switch;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;235;2843.666,889.9761;Float;False;452.9371;811.1447;Final;4;99;175;206;331;Outputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-1263.066,66.81864;Float;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;4658.84,-1159.965;Float;False;FinalColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;391;3551.427,-385.0264;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;406;3416.104,1297.26;Float;False;Constant;_Float12;Float 12;20;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;3096.573,1235.245;Float;False;98;Alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;3072.166,941.4243;Float;False;205;FinalColor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;237;-2119.915,3380.083;Float;False;978.701;287.5597;;3;174;172;419;Normal map;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;311;3014.505,1924.656;Float;False;Global;_WindDebug;_WindDebug;20;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;312;3073.705,1840.556;Float;False;91;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;330;3743.457,-384.6883;Float;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;451;3614.484,1439.282;Float;False;Constant;_UpNormalVector;UpNormalVector;21;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;313;3587.307,1254.955;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;3082.283,1039.971;Float;False;174;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;682;4090.609,1222.928;Float;False;Constant;_Float0;Float 0;22;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;310;3589.109,973.5546;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-1384.214,3430.082;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;3064.599,1369.667;Float;False;330;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;683;3873.845,1095.495;Float;False;Constant;_Color0;Color 0;21;0;Create;True;0;0;False;0;0.07058824,0,0.1058824,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;172;-1768.914,3434.642;Float;True;Property;_BumpMap;BumpMap;3;2;[NoScaleOffset];[Normal];Create;True;0;0;True;0;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;419;-2007.296,3508.627;Float;False;Constant;_Float18;Float 18;21;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;680;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;2;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;678;4279.866,1027.348;Half;False;True;2;Half;ASEMaterialInspector;0;4;FAE/Grass;1976390536c6c564abb90fe41f6ee334;0;0;Base;11;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;;0;0;Standard;1;_FinalColorxAlpha;0;11;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;679;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;2;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;681;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;2;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;202;-2142.645,-2259.974;Float;False;2627.3;775.1997;Bending;0;Foliage bending away from obstacle;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;426;2488.814,-319.9986;Float;False;219;183;Mask wind/bending by height;0;;1,1,1,1;0;0
WireConnection;485;0;493;1
WireConnection;485;1;493;1
WireConnection;483;0;493;3
WireConnection;483;1;493;4
WireConnection;67;0;319;0
WireConnection;67;1;383;0
WireConnection;488;0;483;0
WireConnection;487;0;484;0
WireConnection;79;0;67;0
WireConnection;79;1;69;3
WireConnection;469;0;308;1
WireConnection;469;1;308;3
WireConnection;72;1;384;0
WireConnection;486;0;493;1
WireConnection;486;1;485;0
WireConnection;221;0;79;0
WireConnection;221;1;469;0
WireConnection;490;0;488;0
WireConnection;490;1;493;1
WireConnection;298;0;72;0
WireConnection;298;1;297;0
WireConnection;298;2;520;0
WireConnection;489;0;486;0
WireConnection;489;1;487;0
WireConnection;222;0;298;0
WireConnection;222;1;221;0
WireConnection;491;0;490;0
WireConnection;491;1;489;0
WireConnection;410;1;222;0
WireConnection;324;0;491;0
WireConnection;501;0;364;1
WireConnection;91;0;410;0
WireConnection;363;0;292;0
WireConnection;363;1;362;0
WireConnection;363;2;501;0
WireConnection;139;0;138;0
WireConnection;458;1;325;0
WireConnection;320;0;458;0
WireConnection;141;0;139;0
WireConnection;141;1;140;0
WireConnection;240;0;93;0
WireConnection;293;0;363;0
WireConnection;293;1;97;0
WireConnection;549;0;292;0
WireConnection;554;0;553;1
WireConnection;677;0;141;0
WireConnection;416;0;554;0
WireConnection;416;1;417;0
WireConnection;416;2;418;0
WireConnection;522;0;385;0
WireConnection;551;0;293;0
WireConnection;239;0;240;0
WireConnection;239;1;240;1
WireConnection;467;0;466;0
WireConnection;145;0;677;0
WireConnection;145;1;143;0
WireConnection;511;0;239;0
WireConnection;511;1;86;1
WireConnection;376;0;550;0
WireConnection;376;1;320;0
WireConnection;376;2;416;0
WireConnection;290;0;552;0
WireConnection;290;1;376;0
WireConnection;290;2;291;0
WireConnection;518;0;467;0
WireConnection;147;0;145;0
WireConnection;147;1;146;0
WireConnection;274;0;511;0
WireConnection;274;1;101;0
WireConnection;274;2;525;0
WireConnection;277;0;521;0
WireConnection;526;0;290;0
WireConnection;580;0;147;0
WireConnection;580;1;148;1
WireConnection;514;0;274;0
WireConnection;495;0;277;0
WireConnection;495;2;277;1
WireConnection;523;0;514;0
WireConnection;454;0;580;0
WireConnection;454;1;455;0
WireConnection;247;0;495;0
WireConnection;247;1;408;0
WireConnection;589;0;527;0
WireConnection;591;0;454;0
WireConnection;591;1;590;0
WireConnection;301;0;111;1
WireConnection;301;1;382;0
WireConnection;513;0;589;0
WireConnection;513;1;524;0
WireConnection;249;0;247;0
WireConnection;249;1;495;0
WireConnection;249;2;248;0
WireConnection;114;0;301;0
WireConnection;114;1;113;0
WireConnection;517;0;591;0
WireConnection;118;0;113;0
WireConnection;66;0;16;0
WireConnection;66;1;522;0
WireConnection;161;0;513;0
WireConnection;500;0;83;1
WireConnection;153;0;517;0
WireConnection;302;0;114;0
WireConnection;302;2;381;0
WireConnection;70;0;66;0
WireConnection;70;1;249;0
WireConnection;70;2;83;1
WireConnection;117;0;118;0
WireConnection;115;0;381;0
WireConnection;115;1;302;0
WireConnection;115;2;117;0
WireConnection;74;0;70;0
WireConnection;74;2;500;0
WireConnection;295;0;161;0
WireConnection;295;1;296;0
WireConnection;84;0;74;0
WireConnection;534;0;531;0
WireConnection;534;1;532;0
WireConnection;106;0;161;0
WireConnection;106;1;295;0
WireConnection;106;2;530;0
WireConnection;207;0;115;0
WireConnection;542;0;106;0
WireConnection;542;1;534;0
WireConnection;437;0;85;0
WireConnection;519;0;542;0
WireConnection;519;1;208;0
WireConnection;98;0;97;4
WireConnection;205;0;519;0
WireConnection;391;0;437;0
WireConnection;391;2;437;2
WireConnection;330;0;391;0
WireConnection;313;0;99;0
WireConnection;313;1;406;0
WireConnection;313;2;311;0
WireConnection;310;0;206;0
WireConnection;310;1;312;0
WireConnection;310;2;311;0
WireConnection;174;0;172;0
WireConnection;172;5;419;0
WireConnection;678;0;310;0
WireConnection;678;1;175;0
WireConnection;678;9;683;3
WireConnection;678;4;683;1
WireConnection;678;6;313;0
WireConnection;678;7;682;0
WireConnection;678;8;331;0
WireConnection;678;10;451;0
ASEEND*/
//CHKSM=C60B30E2A85811F7A83C6EFC358E39F9E2879B28