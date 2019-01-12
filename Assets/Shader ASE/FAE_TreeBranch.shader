// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FAE/Tree Branch"
{
    Properties
    {
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		_HueVariation("Hue Variation", Color) = (1,0.5,0,0.184)
		[NoScaleOffset]_BumpMap("BumpMap", 2D) = "bump" {}
		_TransmissionColor("Transmission Color", Color) = (1,1,1,0)
		_AmbientOcclusion("AmbientOcclusion", Range( 0 , 1)) = 0
		_MaxWindStrength("MaxWindStrength", Range( 0 , 1)) = 0.1164738
		_FlatLighting("FlatLighting", Range( 0 , 1)) = 0
		_WindVectors("_WindVectors", 2D) = "white" {}
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 1
		_GradientBrightness("GradientBrightness", Range( 0 , 2)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_mAINcoLOR("mAINcoLOR", Color) = (0.2705589,0.6037736,0.3368931,0)
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
			Offset 0 , 0
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
        	#define _AlphaClip 1


        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"

            CBUFFER_START(UnityPerMaterial)
			sampler2D _WindVectors;
			float _WindAmplitudeMultiplier;
			float _MaxWindStrength;
			float _FlatLighting;
			float4 _mAINcoLOR;
			sampler2D _MainTex;
			float _GradientBrightness;
			float4 _HueVariation;
			float _WindDebug;
			sampler2D _BumpMap;
			float4 _TransmissionColor;
			float _Smoothness;
			float _AmbientOcclusion;
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
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            	UNITY_VERTEX_OUTPUT_STEREO
            };


            GraphVertexOutput vert (GraphVertexInput v)
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 temp_cast_0 = (0.1).xx;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float temp_output_60_0 = ( ( 0.1 * 0.05 ) * 0.0 );
				float4 _WindDirection = float4(1.14,0.95,-1,1.33);
				float3 appendResult249 = (float3(_WindDirection.x , _WindDirection.y , _WindDirection.z));
				float2 panner341 = ( 0.05 * _Time.y * temp_cast_0 + ( ( _WindAmplitudeMultiplier * 1.0 * ( ase_worldPos * 0.01 ) ) + ( temp_output_60_0 * appendResult249 ) ).xy);
				float3 WindVectors99 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( panner341, 0, 0.0) ), 1.0f );
				float3 appendResult250 = (float3(_WindDirection.x , _WindDirection.y , _WindDirection.z));
				float3 _Vector2 = float3(1,1,1);
				float3 break282 = ( (float3( 0,0,0 ) + (sin( ( ( temp_output_60_0 * ( 10.0 / _SinTime.x ) ) * appendResult250 ) ) - ( float3(-1,-1,-1) + 0.5 )) * (_Vector2 - float3( 0,0,0 )) / (_Vector2 - ( float3(-1,-1,-1) + 0.5 ))) * v.ase_color.a );
				float3 appendResult283 = (float3(break282.x , 0.0 , break282.z));
				float3 temp_output_123_0 = ( ( ( WindVectors99 * v.ase_color.g ) * _MaxWindStrength * 1.0 ) + appendResult283 );
				
				float3 lerpResult94 = lerp( v.ase_normal , float3(0,1,0) , _FlatLighting);
				
				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				v.vertex.xyz += temp_output_123_0;
				v.ase_normal = lerpResult94;

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
    
				float2 uv_MainTex19 = IN.ase_texcoord7.xy;
				float4 tex2DNode19 = tex2D( _MainTex, uv_MainTex19 );
				float4 lerpResult246 = lerp( ( tex2DNode19 * _GradientBrightness ) , tex2DNode19 , IN.ase_color.b);
				float4 lerpResult20 = lerp( lerpResult246 , _HueVariation , ( _HueVariation.a * 0.0 ));
				float4 temp_cast_0 = (1.0).xxxx;
				float4 clampResult55 = clamp( lerpResult20 , float4( 0,0,0,0 ) , temp_cast_0 );
				float4 Color56 = clampResult55;
				float2 temp_cast_1 = (0.1).xx;
				float temp_output_60_0 = ( ( 0.1 * 0.05 ) * 0.0 );
				float4 _WindDirection = float4(1.14,0.95,-1,1.33);
				float3 appendResult249 = (float3(_WindDirection.x , _WindDirection.y , _WindDirection.z));
				float2 panner341 = ( 0.05 * _Time.y * temp_cast_1 + ( ( _WindAmplitudeMultiplier * 1.0 * ( WorldSpacePosition * 0.01 ) ) + ( temp_output_60_0 * appendResult249 ) ).xy);
				float3 WindVectors99 = UnpackNormalmapRGorAG( tex2D( _WindVectors, panner341 ), 1.0f );
				float4 lerpResult97 = lerp( ( _mAINcoLOR * Color56 ) , float4( WindVectors99 , 0.0 ) , _WindDebug);
				
				float2 uv_BumpMap62 = IN.ase_texcoord7.xy;
				
				float3 normalizeResult236 = normalize( _MainLightPosition.xyz );
				float dotResult36 = dot( normalizeResult236 , ( 1.0 - WorldSpaceViewDirection ) );
				float4 SSS45 = ( ( ( (0.0 + (dotResult36 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) * IN.ase_color.b ) * _TransmissionColor.a ) * ( _TransmissionColor * _MainLightColor ) );
				
				float lerpResult53 = lerp( 1.0 , 0.0 , ( _AmbientOcclusion * ( 1.0 - IN.ase_color.r ) ));
				float AmbientOcclusion218 = lerpResult53;
				
				float Alpha31 = tex2DNode19.a;
				float lerpResult101 = lerp( Alpha31 , 1.0 , _WindDebug);
				
				
		        float3 Albedo = lerpResult97.rgb;
				float3 Normal = UnpackNormalmapRGorAG( tex2D( _BumpMap, uv_BumpMap62 ), 1.0f );
				float3 Emission = SSS45.rgb;
				float3 Specular = float3(0.5, 0.5, 0.5);
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = AmbientOcclusion218;
				float Alpha = lerpResult101;
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
			sampler2D _WindVectors;
			float _WindAmplitudeMultiplier;
			float _MaxWindStrength;
			float _FlatLighting;
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

				float2 temp_cast_0 = (0.1).xx;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float temp_output_60_0 = ( ( 0.1 * 0.05 ) * 0.0 );
				float4 _WindDirection = float4(1.14,0.95,-1,1.33);
				float3 appendResult249 = (float3(_WindDirection.x , _WindDirection.y , _WindDirection.z));
				float2 panner341 = ( 0.05 * _Time.y * temp_cast_0 + ( ( _WindAmplitudeMultiplier * 1.0 * ( ase_worldPos * 0.01 ) ) + ( temp_output_60_0 * appendResult249 ) ).xy);
				float3 WindVectors99 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( panner341, 0, 0.0) ), 1.0f );
				float3 appendResult250 = (float3(_WindDirection.x , _WindDirection.y , _WindDirection.z));
				float3 _Vector2 = float3(1,1,1);
				float3 break282 = ( (float3( 0,0,0 ) + (sin( ( ( temp_output_60_0 * ( 10.0 / _SinTime.x ) ) * appendResult250 ) ) - ( float3(-1,-1,-1) + 0.5 )) * (_Vector2 - float3( 0,0,0 )) / (_Vector2 - ( float3(-1,-1,-1) + 0.5 ))) * v.ase_color.a );
				float3 appendResult283 = (float3(break282.x , 0.0 , break282.z));
				float3 temp_output_123_0 = ( ( ( WindVectors99 * v.ase_color.g ) * _MaxWindStrength * 1.0 ) + appendResult283 );
				
				float3 lerpResult94 = lerp( v.ase_normal , float3(0,1,0) , _FlatLighting);
				
				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;

				v.vertex.xyz += temp_output_123_0;
				v.ase_normal = lerpResult94;

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

               float2 uv_MainTex19 = IN.ase_texcoord7.xy;
               float4 tex2DNode19 = tex2D( _MainTex, uv_MainTex19 );
               float Alpha31 = tex2DNode19.a;
               float lerpResult101 = lerp( Alpha31 , 1.0 , _WindDebug);
               

				float Alpha = lerpResult101;
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
			sampler2D _WindVectors;
			float _WindAmplitudeMultiplier;
			float _MaxWindStrength;
			float _FlatLighting;
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

				float2 temp_cast_0 = (0.1).xx;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float temp_output_60_0 = ( ( 0.1 * 0.05 ) * 0.0 );
				float4 _WindDirection = float4(1.14,0.95,-1,1.33);
				float3 appendResult249 = (float3(_WindDirection.x , _WindDirection.y , _WindDirection.z));
				float2 panner341 = ( 0.05 * _Time.y * temp_cast_0 + ( ( _WindAmplitudeMultiplier * 1.0 * ( ase_worldPos * 0.01 ) ) + ( temp_output_60_0 * appendResult249 ) ).xy);
				float3 WindVectors99 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( panner341, 0, 0.0) ), 1.0f );
				float3 appendResult250 = (float3(_WindDirection.x , _WindDirection.y , _WindDirection.z));
				float3 _Vector2 = float3(1,1,1);
				float3 break282 = ( (float3( 0,0,0 ) + (sin( ( ( temp_output_60_0 * ( 10.0 / _SinTime.x ) ) * appendResult250 ) ) - ( float3(-1,-1,-1) + 0.5 )) * (_Vector2 - float3( 0,0,0 )) / (_Vector2 - ( float3(-1,-1,-1) + 0.5 ))) * v.ase_color.a );
				float3 appendResult283 = (float3(break282.x , 0.0 , break282.z));
				float3 temp_output_123_0 = ( ( ( WindVectors99 * v.ase_color.g ) * _MaxWindStrength * 1.0 ) + appendResult283 );
				
				float3 lerpResult94 = lerp( v.ase_normal , float3(0,1,0) , _FlatLighting);
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;

				v.vertex.xyz += temp_output_123_0;
				v.ase_normal = lerpResult94;

        	    o.clipPos = TransformObjectToHClip(v.vertex.xyz);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

				float2 uv_MainTex19 = IN.ase_texcoord.xy;
				float4 tex2DNode19 = tex2D( _MainTex, uv_MainTex19 );
				float Alpha31 = tex2DNode19.a;
				float lerpResult101 = lerp( Alpha31 , 1.0 , _WindDebug);
				

				float Alpha = lerpResult101;
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
			sampler2D _WindVectors;
			float _WindAmplitudeMultiplier;
			float _MaxWindStrength;
			float _FlatLighting;
			float4 _mAINcoLOR;
			sampler2D _MainTex;
			float _GradientBrightness;
			float4 _HueVariation;
			float _WindDebug;
			float4 _TransmissionColor;
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
                float4 ase_texcoord : TEXCOORD0;
                float4 ase_color : COLOR;
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
				float2 temp_cast_0 = (0.1).xx;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float temp_output_60_0 = ( ( 0.1 * 0.05 ) * 0.0 );
				float4 _WindDirection = float4(1.14,0.95,-1,1.33);
				float3 appendResult249 = (float3(_WindDirection.x , _WindDirection.y , _WindDirection.z));
				float2 panner341 = ( 0.05 * _Time.y * temp_cast_0 + ( ( _WindAmplitudeMultiplier * 1.0 * ( ase_worldPos * 0.01 ) ) + ( temp_output_60_0 * appendResult249 ) ).xy);
				float3 WindVectors99 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( panner341, 0, 0.0) ), 1.0f );
				float3 appendResult250 = (float3(_WindDirection.x , _WindDirection.y , _WindDirection.z));
				float3 _Vector2 = float3(1,1,1);
				float3 break282 = ( (float3( 0,0,0 ) + (sin( ( ( temp_output_60_0 * ( 10.0 / _SinTime.x ) ) * appendResult250 ) ) - ( float3(-1,-1,-1) + 0.5 )) * (_Vector2 - float3( 0,0,0 )) / (_Vector2 - ( float3(-1,-1,-1) + 0.5 ))) * v.ase_color.a );
				float3 appendResult283 = (float3(break282.x , 0.0 , break282.z));
				float3 temp_output_123_0 = ( ( ( WindVectors99 * v.ase_color.g ) * _MaxWindStrength * 1.0 ) + appendResult283 );
				
				float3 lerpResult94 = lerp( v.ase_normal , float3(0,1,0) , _FlatLighting);
				
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;

				v.vertex.xyz += temp_output_123_0;
				v.ase_normal = lerpResult94;
				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float2 uv_MainTex19 = IN.ase_texcoord.xy;
           		float4 tex2DNode19 = tex2D( _MainTex, uv_MainTex19 );
           		float4 lerpResult246 = lerp( ( tex2DNode19 * _GradientBrightness ) , tex2DNode19 , IN.ase_color.b);
           		float4 lerpResult20 = lerp( lerpResult246 , _HueVariation , ( _HueVariation.a * 0.0 ));
           		float4 temp_cast_0 = (1.0).xxxx;
           		float4 clampResult55 = clamp( lerpResult20 , float4( 0,0,0,0 ) , temp_cast_0 );
           		float4 Color56 = clampResult55;
           		float2 temp_cast_1 = (0.1).xx;
           		float3 ase_worldPos = IN.ase_texcoord1.xyz;
           		float temp_output_60_0 = ( ( 0.1 * 0.05 ) * 0.0 );
           		float4 _WindDirection = float4(1.14,0.95,-1,1.33);
           		float3 appendResult249 = (float3(_WindDirection.x , _WindDirection.y , _WindDirection.z));
           		float2 panner341 = ( 0.05 * _Time.y * temp_cast_1 + ( ( _WindAmplitudeMultiplier * 1.0 * ( ase_worldPos * 0.01 ) ) + ( temp_output_60_0 * appendResult249 ) ).xy);
           		float3 WindVectors99 = UnpackNormalmapRGorAG( tex2D( _WindVectors, panner341 ), 1.0f );
           		float4 lerpResult97 = lerp( ( _mAINcoLOR * Color56 ) , float4( WindVectors99 , 0.0 ) , _WindDebug);
           		
           		float3 normalizeResult236 = normalize( _MainLightPosition.xyz );
           		float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
           		ase_worldViewDir = SafeNormalize( ase_worldViewDir );
           		float dotResult36 = dot( normalizeResult236 , ( 1.0 - ase_worldViewDir ) );
           		float4 SSS45 = ( ( ( (0.0 + (dotResult36 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) * IN.ase_color.b ) * _TransmissionColor.a ) * ( _TransmissionColor * _MainLightColor ) );
           		
           		float Alpha31 = tex2DNode19.a;
           		float lerpResult101 = lerp( Alpha31 , 1.0 , _WindDebug);
           		
				
		        float3 Albedo = lerpResult97.rgb;
				float3 Emission = SSS45.rgb;
				float Alpha = lerpResult101;
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
7.2;0.8;1461;835;2600.794;1703.368;3.398444;True;False
Node;AmplifyShaderEditor.CommentaryNode;238;-3972.506,-2089.813;Float;False;2833.298;786.479;Comment;11;210;209;59;341;10;237;99;5;106;342;102;Leaf wind animation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-3922.506,-1624.636;Float;False;Constant;_WindSpeed;_WindSpeed;7;0;Create;True;0;0;False;0;0.1;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-3866.337,-1392.731;Float;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;False;0;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;239;-3957.72,-1217.98;Float;False;2848.898;709.3215;Comment;4;206;250;142;283;Global wind animation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;85;-3626.292,489.3988;Float;False;2725.568;616.9805;Subsurface;3;33;34;45;Transmission;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;241;-3107.428,-410.5003;Float;False;1876.535;746.0209;Comment;2;245;19;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-3891.262,-1720.818;Float;False;Constant;_Float7;Float 7;10;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;343;-3723.139,-633.2321;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-3819.227,-1971.172;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;87;-4002.667,-1163.272;Float;False;Constant;_WindDirection;_WindDirection;9;0;Create;True;0;0;False;0;1.14,0.95,-1,1.33;1,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;142;-3906.859,-802.9371;Float;False;Constant;_TrunkWindSpeed;_TrunkWindSpeed;10;0;Create;True;0;0;False;0;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-3544.246,-1617.813;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-3322.042,-2039.813;Float;False;Property;_WindAmplitudeMultiplier;WindAmplitudeMultiplier;8;0;Create;True;0;0;False;0;1;0.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;34;-3572.92,760.2396;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;33;-3603.792,532.3994;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-3322.006,-1569.036;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;249;-3089.01,-1338.466;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-2930.195,-149.8801;Float;False;Property;_GradientBrightness;GradientBrightness;9;0;Create;True;0;0;False;0;1;0.48;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-3047.296,-359.2004;Float;True;Property;_MainTex;MainTex;0;1;[NoScaleOffset];Create;True;0;0;False;0;None;956dbb72bf2073b4eac5c62ca0964c4b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;315;-3291.345,-1955.613;Float;False;Constant;_WindAmplitude;_WindAmplitude;12;0;Create;True;0;0;False;0;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;194;-3632.326,-890.6907;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-3267.658,-1819.793;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;83;-2473.749,-110.3892;Float;False;Property;_HueVariation;Hue Variation;1;0;Create;True;0;0;False;0;1,0.5,0,0.184;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;245;-3037.995,-52.28011;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;236;-3336.135,536.0207;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;330;-3326.007,693.1129;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-3001.746,-1583.413;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;250;-3580.585,-1104.491;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;-2999.042,-1900.813;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-3342.022,-1167.98;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;247;-2533.993,-368.9799;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;36;-3137.692,548.1992;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2164.695,78.19921;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-3067.625,-1119.186;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-2765.946,-1767.013;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-3197.828,-798.7911;Float;False;Constant;_TrunkWindSwinging;_TrunkWindSwinging;10;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-2936.735,762.0214;Float;False;Constant;_Float4;Float 4;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;231;-2937.638,656.3201;Float;False;Constant;_Float9;Float 9;11;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;246;-2311.794,-314.0801;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;154;-3111.927,-969.0889;Float;False;Constant;_Vector1;Vector 1;10;0;Create;True;0;0;False;0;-1,-1,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;20;-1943.796,-123.3005;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;40;-2871.99,852.5;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;242;-2888.98,-732.9907;Float;False;Constant;_Vector2;Vector 2;10;0;Create;True;0;0;False;0;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;341;-2605.24,-1785.958;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;0.05;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;170;-2873.828,-908.7911;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;229;-2670.534,584.4202;Float;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1871.637,53.5219;Float;False;Constant;_Float3;Float 3;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;150;-2880.324,-1106.686;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;206;-2284.721,-773.8325;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;55;-1669.095,-113.7017;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;152;-2439.225,-1114.487;Float;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;2;FLOAT3;1,1,1;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;214;-2240.732,937.2216;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;-2384.838,567.6202;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;102;-2432.561,-1913.644;Float;True;Property;_WindVectors;_WindVectors;7;0;Create;True;0;0;False;0;None;6c795dd1d1d319e479e68164001557e8;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;213;-2398.831,721.1215;Float;False;Property;_TransmissionColor;Transmission Color;3;0;Create;True;0;0;False;0;1,1,1,0;0.4781763,0.5849056,0.1296722,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;10;-2243.634,-1609.706;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;225;-2005.338,565.3199;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-2136.922,-1771.871;Float;False;WindVectors;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-420.9563,-190.6743;Float;False;Global;_WindDebug;_WindDebug;10;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;215;-2015.23,749.321;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-1390.758,-107.8447;Float;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-1868.222,-1088.986;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;282;-1708.497,-1084.519;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1982.097,-261.8007;Float;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;-1767.439,561.4199;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;272;-155.1518,-497.8887;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;274;-109.1185,81.11133;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;-1857.104,-1736.955;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;307.7924,-795.8511;Float;False;56;Color;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1766.407,-1659.435;Float;False;Property;_MaxWindStrength;MaxWindStrength;5;0;Create;True;0;0;False;0;0.1164738;0.23;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;284;-1764.627,-1563.295;Float;False;Constant;_WindStrength;_WindStrength;12;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;339;319.3164,-990.36;Float;False;Property;_mAINcoLOR;mAINcoLOR;11;0;Create;True;0;0;False;0;0.2705589,0.6037736,0.3368931,0;0.1580631,0.3018865,0.1885711,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;338;686.4745,-851.3792;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;271;176.8815,94.11133;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-307.0379,32.42241;Float;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-1154.397,560.2985;Float;False;SSS;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;95;208.6328,558.2144;Float;False;Property;_FlatLighting;FlatLighting;6;0;Create;True;0;0;False;0;0;0.31;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-328.496,-44.40088;Float;False;31;Alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;93;-111.367,291.2144;Float;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;240;-2700.494,1188.223;Float;False;1461.06;358.5759;Comment;1;47;AO;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;284.0998,-712.3729;Float;False;99;WindVectors;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;273;-109.7907,-588.0359;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;96;272.633,208.2133;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1331.207,-1774.334;Float;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;283;-1339.63,-1070.413;Float;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-378.4811,-1378.025;Float;False;Wind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2409.993,1253.799;Float;False;Property;_AmbientOcclusion;AmbientOcclusion;4;0;Create;True;0;0;False;0;0;0.21;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;49;-2329.393,1396.799;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;342;-3505.826,-1900.183;Float;False;FLOAT2;0;0;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;-1520.435,1371.92;Float;False;AmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;123;-869.729,-1375.275;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;97;626.5228,-673.5649;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-2069.393,1351.298;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;7.430328,-312.6622;Float;False;45;SSS;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;62;-88.8763,-501.9734;Float;True;Property;_BumpMap;BumpMap;2;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;53;-1805.494,1291.499;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-54.78961,-161.1802;Float;False;218;AmbientOcclusion;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;624.2745,22.64254;Float;False;17;Wind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;254;-89.41714,-236.6956;Float;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;False;0;0;0.28;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-2002.035,1238.223;Float;False;Constant;_Float5;Float 5;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;337;783.6008,-97.00641;Float;False;Constant;_Float2;Float 2;14;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;94;613.6323,307.2142;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;101;253.4392,-43.74419;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;47;-2650.494,1344.798;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;336;946.35,-313.3243;Float;False;False;2;Float;ASEMaterialInspector;0;4;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;335;946.35,-313.3243;Float;False;False;2;Float;ASEMaterialInspector;0;4;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;334;946.35,-313.3243;Float;False;False;2;Float;ASEMaterialInspector;0;4;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;333;991.1499,-295.7243;Half;False;True;2;Half;ASEMaterialInspector;0;4;FAE/Tree Branch;1976390536c6c564abb90fe41f6ee334;0;0;Base;11;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;;0;0;Standard;1;_FinalColorxAlpha;0;11;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;0
WireConnection;90;0;59;0
WireConnection;90;1;106;0
WireConnection;60;0;90;0
WireConnection;249;0;87;1
WireConnection;249;1;87;2
WireConnection;249;2;87;3
WireConnection;194;0;142;0
WireConnection;194;1;343;1
WireConnection;209;0;5;0
WireConnection;209;1;210;0
WireConnection;236;0;33;0
WireConnection;330;0;34;0
WireConnection;89;0;60;0
WireConnection;89;1;249;0
WireConnection;250;0;87;1
WireConnection;250;1;87;2
WireConnection;250;2;87;3
WireConnection;212;0;211;0
WireConnection;212;1;315;0
WireConnection;212;2;209;0
WireConnection;141;0;60;0
WireConnection;141;1;194;0
WireConnection;247;0;19;0
WireConnection;247;1;248;0
WireConnection;36;0;236;0
WireConnection;36;1;330;0
WireConnection;30;0;83;4
WireConnection;148;0;141;0
WireConnection;148;1;250;0
WireConnection;91;0;212;0
WireConnection;91;1;89;0
WireConnection;246;0;247;0
WireConnection;246;1;19;0
WireConnection;246;2;245;3
WireConnection;20;0;246;0
WireConnection;20;1;83;0
WireConnection;20;2;30;0
WireConnection;341;0;91;0
WireConnection;341;2;59;0
WireConnection;170;0;154;0
WireConnection;170;1;171;0
WireConnection;229;0;36;0
WireConnection;229;1;231;0
WireConnection;229;2;232;0
WireConnection;229;4;232;0
WireConnection;150;0;148;0
WireConnection;55;0;20;0
WireConnection;55;2;105;0
WireConnection;152;0;150;0
WireConnection;152;1;170;0
WireConnection;152;2;242;0
WireConnection;152;4;242;0
WireConnection;224;0;229;0
WireConnection;224;1;40;3
WireConnection;102;1;341;0
WireConnection;225;0;224;0
WireConnection;225;1;213;4
WireConnection;99;0;102;0
WireConnection;215;0;213;0
WireConnection;215;1;214;0
WireConnection;56;0;55;0
WireConnection;118;0;152;0
WireConnection;118;1;206;4
WireConnection;282;0;118;0
WireConnection;31;0;19;4
WireConnection;226;0;225;0
WireConnection;226;1;215;0
WireConnection;272;0;100;0
WireConnection;274;0;100;0
WireConnection;237;0;99;0
WireConnection;237;1;10;2
WireConnection;338;0;339;0
WireConnection;338;1;57;0
WireConnection;271;0;274;0
WireConnection;45;0;226;0
WireConnection;273;0;272;0
WireConnection;15;0;237;0
WireConnection;15;1;16;0
WireConnection;15;2;284;0
WireConnection;283;0;282;0
WireConnection;283;2;282;2
WireConnection;17;0;123;0
WireConnection;49;0;47;1
WireConnection;342;0;5;0
WireConnection;218;0;53;0
WireConnection;123;0;15;0
WireConnection;123;1;283;0
WireConnection;97;0;338;0
WireConnection;97;1;98;0
WireConnection;97;2;273;0
WireConnection;51;0;50;0
WireConnection;51;1;49;0
WireConnection;53;0;108;0
WireConnection;53;2;51;0
WireConnection;94;0;96;0
WireConnection;94;1;93;0
WireConnection;94;2;95;0
WireConnection;101;0;32;0
WireConnection;101;1;103;0
WireConnection;101;2;271;0
WireConnection;333;0;97;0
WireConnection;333;1;62;0
WireConnection;333;2;46;0
WireConnection;333;4;254;0
WireConnection;333;5;217;0
WireConnection;333;6;101;0
WireConnection;333;7;337;0
WireConnection;333;8;123;0
WireConnection;333;10;94;0
ASEEND*/
//CHKSM=FE9B38A375B9353411C6E6E6A1C51EE7B95ABE72