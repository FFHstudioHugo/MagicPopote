// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SimpleWater"
{
    Properties
    {
		_WaterNormal("Water Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_ShalowColor("Shalow Color", Color) = (0.1393734,0.297808,0.3396226,0)
		_Distortion("Distortion", Float) = 0.5
		_WaterDepth("Water Depth", Float) = 0
		_WaterFalloff("Water Falloff", Float) = 0
		_Vector0("Vector 0", Vector) = (0,0,0,0)
		_Vector1("Vector 1", Vector) = (0,0,0,0)
		_SpecularColor("SpecularColor", Color) = (1,0,0,0)
		_Float0("Float 0", Range( 0 , 10)) = 10
		_PlanarRflection("PlanarRflection", Range( -1 , 1)) = 0
		_Float1("Float 1", Float) = 0
		_PlanarReflectionColorForce("PlanarReflection ColorForce", Range( 0 , 1)) = 0
		_Float2("Float 2", Float) = -0.24
		_Float3("Float 3", Range( 0 , 1)) = 0
		_EmissionDepth("EmissionDepth", Range( -5 , 5)) = 0
		_Color1("Color 1", Color) = (0,0,0,0)
    }

    SubShader
    {
        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Opaque" "Queue"="Transparent" }

		Cull Back
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
        	#define _SPECULAR_SETUP 1


        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"

            CBUFFER_START(UnityPerMaterial)
			sampler2D _PlanarReflectionTexture;
			sampler2D _WaterNormal;
			float _NormalScale;
			float4 _WaterNormal_ST;
			float _Distortion;
			float _PlanarReflectionColorForce;
			float _PlanarRflection;
			uniform sampler2D _CameraDepthTexture;
			float _WaterDepth;
			float _WaterFalloff;
			float2 _Vector0;
			sampler2D _GrabBlurTexture;
			float4 _ShalowColor;
			float _Float3;
			float4 _Color1;
			float _EmissionDepth;
			float4 _SpecularColor;
			float _Float0;
			float2 _Vector1;
			float _Float1;
			float _Float2;
			CBUFFER_END
			
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
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
				float4 ase_texcoord8 : TEXCOORD8;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            	UNITY_VERTEX_OUTPUT_STEREO
            };


            GraphVertexOutput vert (GraphVertexInput v)
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_texcoord8.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;
				v.vertex.xyz +=  float3( 0, 0, 0 ) ;
				v.ase_normal =  v.ase_normal ;

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
    
				float4 screenPos = IN.ase_texcoord7;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 uv_WaterNormal = IN.ase_texcoord8.xy * _WaterNormal_ST.xy + _WaterNormal_ST.zw;
				float2 panner275 = ( 0.8 * _Time.y * float2( 0.2,0.2 ) + uv_WaterNormal);
				float2 panner276 = ( 0.5 * _Time.y * float2( 0.05,-0.15 ) + uv_WaterNormal);
				float3 temp_output_24_0 = BlendNormal( UnpackNormalmapRGorAG( tex2D( _WaterNormal, panner275 ), _NormalScale ) , UnpackNormalmapRGorAG( tex2D( _WaterNormal, panner276 ), _NormalScale ) );
				float3 temp_output_98_0 = ( temp_output_24_0 * _Distortion );
				float2 temp_output_165_0 = (temp_output_98_0).xy;
				float4 temp_output_185_0 = ( ase_grabScreenPosNorm + float4( temp_output_165_0, 0.0 , 0.0 ) );
				float eyeDepth194 = LinearEyeDepth(tex2Dproj( _CameraDepthTexture, screenPos ).r,_ZBufferParams);
				float temp_output_190_0 = saturate( (_Vector0.x + (saturate( pow( ( abs( ( eyeDepth194 - screenPos.w ) ) + _WaterDepth ) , _WaterFalloff ) ) - 0.0) * (_Vector0.y - _Vector0.x) / (1.0 - 0.0)) );
				float depth259 = temp_output_190_0;
				float temp_output_270_0 = ( 1.0 - depth259 );
				float clampResult229 = clamp( ( _PlanarRflection + temp_output_270_0 ) , 0.0 , 1.0 );
				float4 lerpResult271 = lerp( float4( 0,0,0,0 ) , ( tex2D( _PlanarReflectionTexture, temp_output_185_0.xy ) * _PlanarReflectionColorForce ) , clampResult229);
				float clampResult285 = clamp( ( temp_output_270_0 + _Float3 ) , 0.0 , 0.8 );
				float4 lerpResult93 = lerp( tex2D( _GrabBlurTexture, temp_output_185_0.xy ) , _ShalowColor , clampResult285);
				
				float clampResult313 = clamp( ( depth259 + _EmissionDepth ) , 0.0 , 1.0 );
				float4 lerpResult304 = lerp( _Color1 , float4( 0,0,0,0 ) , clampResult313);
				float4 clampResult314 = clamp( lerpResult304 , float4( 0.02830189,0.02830189,0.02830189,0 ) , float4( 0.4811321,0.4811321,0.4811321,0 ) );
				
				float3 tanToWorld0 = float3( WorldSpaceTangent.x, WorldSpaceBiTangent.x, WorldSpaceNormal.x );
				float3 tanToWorld1 = float3( WorldSpaceTangent.y, WorldSpaceBiTangent.y, WorldSpaceNormal.y );
				float3 tanToWorld2 = float3( WorldSpaceTangent.z, WorldSpaceBiTangent.z, WorldSpaceNormal.z );
				float3 tanNormal233 = float3( ( (temp_output_98_0).xy * _Float0 ) ,  0.0 );
				float3 worldNormal233 = float3(dot(tanToWorld0,tanNormal233), dot(tanToWorld1,tanNormal233), dot(tanToWorld2,tanNormal233));
				float temp_output_191_0 = ( 1.0 - temp_output_190_0 );
				float clampResult221 = clamp( ( temp_output_191_0 + _Vector1.y ) , 0.0 , 1.0 );
				float clampResult240 = clamp( ( ( worldNormal233.x + worldNormal233.y ) * clampResult221 ) , 0.0 , 1.0 );
				float4 lerpResult235 = lerp( ( _SpecularColor * clampResult240 ) , float4( 0,0,0,0 ) , ( temp_output_191_0 * _Float1 ));
				float4 smoothstepResult274 = smoothstep( float4( 0.4056604,0.4056604,0.4056604,0 ) , float4( 0.5849056,0.5849056,0.5849056,0 ) , lerpResult235);
				float4 clampResult277 = clamp( ( ( 0.0 + ( 1.0 - depth259 ) ) * smoothstepResult274 ) , float4( 0,0,0,0 ) , float4( 0.3490566,0.3490566,0.3490566,0 ) );
				float4 clampResult282 = clamp( ( lerpResult235 + _Float2 ) , float4( 0,0,0,0 ) , float4( 0.3490566,0.3490566,0.3490566,0 ) );
				float4 temp_output_281_0 = saturate( ( clampResult277 + clampResult282 ) );
				
				
		        float3 Albedo = ( lerpResult271 + lerpResult93 ).rgb;
				float3 Normal = temp_output_24_0;
				float3 Emission = clampResult314.rgb;
				float3 Specular = temp_output_281_0.rgb;
				float Metallic = 0;
				float Smoothness = 0.5;
				float Occlusion = 1;
				float Alpha = depth259;
				float AlphaClipThreshold = 0;

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

            

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            CBUFFER_START(UnityPerMaterial)
			uniform sampler2D _CameraDepthTexture;
			float _WaterDepth;
			float _WaterFalloff;
			float2 _Vector0;
			CBUFFER_END
			
			
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
				
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

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				

				v.vertex.xyz +=  float3(0,0,0) ;
				v.ase_normal =  v.ase_normal ;

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

               float4 screenPos = IN.ase_texcoord7;
               float eyeDepth194 = LinearEyeDepth(tex2Dproj( _CameraDepthTexture, screenPos ).r,_ZBufferParams);
               float temp_output_190_0 = saturate( (_Vector0.x + (saturate( pow( ( abs( ( eyeDepth194 - screenPos.w ) ) + _WaterDepth ) , _WaterFalloff ) ) - 0.0) * (_Vector0.y - _Vector0.x) / (1.0 - 0.0)) );
               float depth259 = temp_output_190_0;
               

				float Alpha = depth259;
				float AlphaClipThreshold = AlphaClipThreshold;

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

            

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			CBUFFER_START(UnityPerMaterial)
			uniform sampler2D _CameraDepthTexture;
			float _WaterDepth;
			float _WaterFalloff;
			float2 _Vector0;
			CBUFFER_END
			
			
           
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
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

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				

				v.vertex.xyz +=  float3(0,0,0) ;
				v.ase_normal =  v.ase_normal ;

        	    o.clipPos = TransformObjectToHClip(v.vertex.xyz);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

				float4 screenPos = IN.ase_texcoord;
				float eyeDepth194 = LinearEyeDepth(tex2Dproj( _CameraDepthTexture, screenPos ).r,_ZBufferParams);
				float temp_output_190_0 = saturate( (_Vector0.x + (saturate( pow( ( abs( ( eyeDepth194 - screenPos.w ) ) + _WaterDepth ) , _WaterFalloff ) ) - 0.0) * (_Vector0.y - _Vector0.x) / (1.0 - 0.0)) );
				float depth259 = temp_output_190_0;
				

				float Alpha = depth259;
				float AlphaClipThreshold = AlphaClipThreshold;

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


            

			uniform float4 _MainTex_ST;

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			CBUFFER_START(UnityPerMaterial)
			sampler2D _PlanarReflectionTexture;
			sampler2D _WaterNormal;
			float _NormalScale;
			float4 _WaterNormal_ST;
			float _Distortion;
			float _PlanarReflectionColorForce;
			float _PlanarRflection;
			uniform sampler2D _CameraDepthTexture;
			float _WaterDepth;
			float _WaterFalloff;
			float2 _Vector0;
			sampler2D _GrabBlurTexture;
			float4 _ShalowColor;
			float _Float3;
			float4 _Color1;
			float _EmissionDepth;
			CBUFFER_END
			
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature EDITOR_VISUALIZATION


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
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
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;

				v.vertex.xyz +=  float3(0,0,0) ;
				v.ase_normal =  v.ase_normal ;
				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float4 screenPos = IN.ase_texcoord;
           		float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
           		float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
           		float2 uv_WaterNormal = IN.ase_texcoord1.xy * _WaterNormal_ST.xy + _WaterNormal_ST.zw;
           		float2 panner275 = ( 0.8 * _Time.y * float2( 0.2,0.2 ) + uv_WaterNormal);
           		float2 panner276 = ( 0.5 * _Time.y * float2( 0.05,-0.15 ) + uv_WaterNormal);
           		float3 temp_output_24_0 = BlendNormal( UnpackNormalmapRGorAG( tex2D( _WaterNormal, panner275 ), _NormalScale ) , UnpackNormalmapRGorAG( tex2D( _WaterNormal, panner276 ), _NormalScale ) );
           		float3 temp_output_98_0 = ( temp_output_24_0 * _Distortion );
           		float2 temp_output_165_0 = (temp_output_98_0).xy;
           		float4 temp_output_185_0 = ( ase_grabScreenPosNorm + float4( temp_output_165_0, 0.0 , 0.0 ) );
           		float eyeDepth194 = LinearEyeDepth(tex2Dproj( _CameraDepthTexture, screenPos ).r,_ZBufferParams);
           		float temp_output_190_0 = saturate( (_Vector0.x + (saturate( pow( ( abs( ( eyeDepth194 - screenPos.w ) ) + _WaterDepth ) , _WaterFalloff ) ) - 0.0) * (_Vector0.y - _Vector0.x) / (1.0 - 0.0)) );
           		float depth259 = temp_output_190_0;
           		float temp_output_270_0 = ( 1.0 - depth259 );
           		float clampResult229 = clamp( ( _PlanarRflection + temp_output_270_0 ) , 0.0 , 1.0 );
           		float4 lerpResult271 = lerp( float4( 0,0,0,0 ) , ( tex2D( _PlanarReflectionTexture, temp_output_185_0.xy ) * _PlanarReflectionColorForce ) , clampResult229);
           		float clampResult285 = clamp( ( temp_output_270_0 + _Float3 ) , 0.0 , 0.8 );
           		float4 lerpResult93 = lerp( tex2D( _GrabBlurTexture, temp_output_185_0.xy ) , _ShalowColor , clampResult285);
           		
           		float clampResult313 = clamp( ( depth259 + _EmissionDepth ) , 0.0 , 1.0 );
           		float4 lerpResult304 = lerp( _Color1 , float4( 0,0,0,0 ) , clampResult313);
           		float4 clampResult314 = clamp( lerpResult304 , float4( 0.02830189,0.02830189,0.02830189,0 ) , float4( 0.4811321,0.4811321,0.4811321,0 ) );
           		
				
		        float3 Albedo = ( lerpResult271 + lerpResult93 ).rgb;
				float3 Emission = clampResult314.rgb;
				float Alpha = depth259;
				float AlphaClipThreshold = 0;

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
	

	Fallback "0"
}
/*ASEBEGIN
Version=16105
658.4;852.8;1461;830;-6674.163;-46.47174;1.877907;True;False
Node;AmplifyShaderEditor.CommentaryNode;192;-1378.352,-557.2415;Float;False;828.5967;315.5001;Screen depth difference to get intersection and fading effect with terrain and objects;3;195;193;194;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;193;-1328.352,-453.7412;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;194;-1104.126,-444.1377;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;195;-898.9512,-410.9409;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;210;-287.4055,-417.1517;Float;False;1113.201;508.3005;Depths controls and colors;8;219;217;216;215;214;213;212;211;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;151;-935.9057,-1082.484;Float;False;1281.603;457.1994;Blend panning normals to fake noving ripples;7;23;24;21;17;48;275;276;;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;196;-351.9139,-369.6307;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-237.4052,-77.85056;Float;False;Property;_WaterDepth;Water Depth;7;0;Create;True;0;0;False;0;0;1.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;213;-55.70959,-154.2337;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-885.9058,-1005.185;Float;False;0;17;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;212;-59.9046,-28.85106;Float;False;Property;_WaterFalloff;Water Falloff;9;0;Create;True;0;0;False;0;0;-0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;275;-441.6641,-882.9688;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.2,0.2;False;1;FLOAT;0.8;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;215;120.4904,-67.83406;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;276;-434.4255,-740.0106;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.05,-0.15;False;1;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-569.5786,-784.6475;Float;False;Property;_NormalScale;Normal Scale;1;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;23;-269.2061,-1024.185;Float;True;Property;_Normal2;Normal2;0;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Instance;17;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;217;326.7919,-46.63486;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;188;1469.794,-398.785;Float;False;Property;_Vector0;Vector 0;10;0;Create;True;0;0;False;0;0,0;-1.08,0.84;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;17;-256.3054,-814.2847;Float;True;Property;_WaterNormal;Water Normal;0;0;Create;True;0;0;False;0;None;1a1e99c7f4bb0a4479e4e5c835fd6c98;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;187;1794.341,-467.4246;Float;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;150;2441.439,-487.4748;Float;False;1624.373;736.5544;Get screen color for refraction and disturbe it with normals;12;183;165;164;97;182;185;149;222;98;243;259;191;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BlendNormalsNode;24;170.697,-879.6849;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;97;2499.301,-307.4897;Float;False;Property;_Distortion;Distortion;4;0;Create;True;0;0;False;0;0.5;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;190;2170.35,-437.5302;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;149;2461.738,-174.5738;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;3504.625,148.9926;Float;True;depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;2787.971,-202.3498;Float;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;4353.997,34.83887;Float;False;259;depth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;165;3090.131,-255.9916;Float;True;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;164;2681.119,-425.5638;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;228;4342.355,-603.5021;Float;False;Property;_PlanarRflection;PlanarRflection;16;0;Create;True;0;0;False;0;0;-0.16;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;287;4408.708,-344.577;Float;False;Property;_Float3;Float 3;21;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;295;5704.07,-134.2508;Float;False;Property;_EmissionDepth;EmissionDepth;22;0;Create;True;0;0;False;0;0;-0.34;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;185;3596.986,-379.09;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;270;4506.795,-205.0187;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;225;4060.308,-1391.965;Float;True;Global;_PlanarReflectionTexture;_PlanarReflectionTexture;18;0;Create;True;0;0;False;0;None;;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;294;6662.7,-122.1072;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;227;4735.224,-825.1742;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;4547.627,-1323.854;Float;False;Property;_PlanarReflectionColorForce;PlanarReflection ColorForce;19;0;Create;True;0;0;False;0;0;0.917;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;224;4477.21,-1245.65;Float;True;Property;_TextureSample1;Texture Sample 1;12;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;286;4832.528,-458.4484;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;183;3584.08,-288.9532;Float;True;Global;_GrabBlurTexture;_GrabBlurTexture;13;0;Create;True;0;0;False;0;None;;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ColorNode;11;4123.931,-472.0628;Float;False;Property;_ShalowColor;Shalow Color;3;0;Create;True;0;0;False;0;0.1393734,0.297808,0.3396226,0;0.1421769,0.4245283,0.3802416,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;182;3805.875,-289.5328;Float;True;Property;_TextureSample0;Texture Sample 0;17;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;285;5175.092,-572.688;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;229;4948.883,-1010.16;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;272;4925.409,-1228.079;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;313;7014.696,-7.27002;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;305;7033.312,-632.3281;Float;False;Property;_Color1;Color 1;24;0;Create;True;0;0;False;0;0,0,0,0;0.07208968,0.1886792,0.1150437,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;93;5581.08,-600.3434;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;304;7298.191,-108.6525;Float;True;3;0;COLOR;1,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;271;5224.72,-1278.09;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;6195.649,903.239;Float;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;264;5767.603,110.108;Float;False;Constant;_SpecularDepth;SpecularDepth;19;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;274;6049.461,437.8017;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0.4056604,0.4056604,0.4056604,0;False;2;COLOR;0.5849056,0.5849056,0.5849056,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;243;3083.557,-13.21057;Float;True;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;171;5731.865,827.219;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;221;4770.926,886.1677;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;284;6055.355,1152.788;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;216;-121.2045,-367.1517;Float;False;Property;_DeepColor;Deep Color;2;0;Create;True;0;0;False;0;0,0,0,0;0,0.04310164,0.2499982,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;241;3499.53,491.3554;Float;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LightAttenuation;310;7395.548,587.9709;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;283;7522.152,477.3743;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.2641509,0.2641509,0.2641509,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;278;7100.883,485.1097;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;244;3368.363,2056.428;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;254;4241.564,730.2349;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;4539.732,684.9426;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;5432.308,766.1844;Float;False;Property;_WavesAmount;WavesAmount;8;0;Create;True;0;0;False;0;8.87;2.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;314;7795.268,476.512;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.02830189,0.02830189,0.02830189,0;False;2;COLOR;0.4811321,0.4811321,0.4811321,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;281;7336.125,497.8169;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;230;5869.661,-806.3717;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;311;6032.043,971.7805;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.5,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;236;3706.803,701.2761;Float;False;Property;_Fresnelbiasscalepower;Fresnel bias scale power;12;0;Create;True;0;0;False;0;0,0,0;-0.11,1.14,4.25;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;214;121.1964,-277.951;Float;False;Property;_Color0;Color 0;5;0;Create;True;0;0;False;0;1,1,1,0;0,0.8088232,0.8088235,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;242;2670.215,524.3224;Float;False;Property;_Float0;Float 0;15;0;Create;True;0;0;False;0;10;7.42;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;261;5781.402,355.9847;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;267;5746.324,1725.456;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;237;4847.135,372.0515;Float;False;Property;_SpecularColor;SpecularColor;14;0;Create;True;0;0;False;0;1,0,0,0;0.08392663,0.3781055,0.4339623,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;282;6890.478,589.8086;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.3490566,0.3490566,0.3490566,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;280;6287.24,669.6135;Float;False;Property;_Float2;Float 2;20;0;Create;True;0;0;False;0;-0.24;-2.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;5629.486,877.1552;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;6225.163,808.2018;Float;False;Property;_WavesAmplitude;WavesAmplitude;6;0;Create;True;0;0;False;0;0.1;35.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;240;4818.835,664.2395;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;248;4688.838,488.9344;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;263;5974.146,209.2139;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;166;5975.81,836.6159;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;5302.785,674.5059;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;223;3216.333,267.7398;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;222;2507.709,-66.5572;Float;False;Property;_Vector1;Vector 1;11;0;Create;True;0;0;False;0;0,0;-0.82,0.52;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;249;4098.221,534.3671;Float;False;Property;_Float1;Float 1;17;0;Create;True;0;0;False;0;0;-2.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;279;6572.189,581.9007;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;6308.376,317.1029;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;219;636.7964,-170.3506;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;306;6817.613,-433.8088;Float;False;Property;_Color2;Color 2;23;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;235;5648.094,502.8441;Float;True;3;0;COLOR;1.49,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;191;2442.141,-194.3778;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;167;5878.854,1097.197;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;168;5422.765,922.6964;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;233;3973.325,766.3309;Float;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;277;6656.163,336.2638;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.3490566,0.3490566,0.3490566,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;172;6562.643,779.7958;Float;True;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;176;8009.911,-47.18214;Float;False;True;2;Float;ASEMaterialInspector;0;4;SimpleWater;1976390536c6c564abb90fe41f6ee334;0;0;Base;11;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;True;2;0;True;0;1;False;-1;10;False;-1;0;5;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;0;5;=;=;=;=;=;0;Standard;1;_FinalColorxAlpha;0;11;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;177;2178.471,-533.4363;Float;False;False;2;Float;ASEMaterialInspector;0;4;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;178;2178.471,-533.4363;Float;False;False;2;Float;ASEMaterialInspector;0;4;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;179;2178.471,-533.4363;Float;False;False;2;Float;ASEMaterialInspector;0;4;Hidden/Templates/LightWeightSRPPBR;1976390536c6c564abb90fe41f6ee334;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
WireConnection;194;0;193;0
WireConnection;195;0;194;0
WireConnection;195;1;193;4
WireConnection;196;0;195;0
WireConnection;213;0;196;0
WireConnection;213;1;211;0
WireConnection;275;0;21;0
WireConnection;215;0;213;0
WireConnection;215;1;212;0
WireConnection;276;0;21;0
WireConnection;23;1;275;0
WireConnection;23;5;48;0
WireConnection;217;0;215;0
WireConnection;17;1;276;0
WireConnection;17;5;48;0
WireConnection;187;0;217;0
WireConnection;187;3;188;1
WireConnection;187;4;188;2
WireConnection;24;0;23;0
WireConnection;24;1;17;0
WireConnection;190;0;187;0
WireConnection;149;0;24;0
WireConnection;259;0;190;0
WireConnection;98;0;149;0
WireConnection;98;1;97;0
WireConnection;165;0;98;0
WireConnection;185;0;164;0
WireConnection;185;1;165;0
WireConnection;270;0;260;0
WireConnection;294;0;260;0
WireConnection;294;1;295;0
WireConnection;227;0;228;0
WireConnection;227;1;270;0
WireConnection;224;0;225;0
WireConnection;224;1;185;0
WireConnection;286;0;270;0
WireConnection;286;1;287;0
WireConnection;182;0;183;0
WireConnection;182;1;185;0
WireConnection;285;0;286;0
WireConnection;229;0;227;0
WireConnection;272;0;224;0
WireConnection;272;1;273;0
WireConnection;313;0;294;0
WireConnection;93;0;182;0
WireConnection;93;1;11;0
WireConnection;93;2;285;0
WireConnection;304;0;305;0
WireConnection;304;2;313;0
WireConnection;271;1;272;0
WireConnection;271;2;229;0
WireConnection;169;0;166;0
WireConnection;169;1;167;0
WireConnection;274;0;235;0
WireConnection;243;0;98;0
WireConnection;171;0;174;0
WireConnection;221;0;223;0
WireConnection;241;0;243;0
WireConnection;241;1;242;0
WireConnection;283;0;281;0
WireConnection;278;0;277;0
WireConnection;278;1;282;0
WireConnection;254;0;233;1
WireConnection;254;1;233;2
WireConnection;239;0;254;0
WireConnection;239;1;221;0
WireConnection;314;0;304;0
WireConnection;281;0;278;0
WireConnection;230;0;271;0
WireConnection;230;1;93;0
WireConnection;311;0;305;0
WireConnection;261;0;260;0
WireConnection;282;0;279;0
WireConnection;174;0;175;0
WireConnection;174;1;168;3
WireConnection;240;0;239;0
WireConnection;248;0;191;0
WireConnection;248;1;249;0
WireConnection;263;0;264;0
WireConnection;263;1;261;0
WireConnection;166;0;171;0
WireConnection;256;0;237;0
WireConnection;256;1;240;0
WireConnection;223;0;191;0
WireConnection;223;1;222;2
WireConnection;279;0;235;0
WireConnection;279;1;280;0
WireConnection;262;0;263;0
WireConnection;262;1;274;0
WireConnection;235;0;256;0
WireConnection;235;2;248;0
WireConnection;191;0;190;0
WireConnection;233;0;241;0
WireConnection;277;0;262;0
WireConnection;172;1;173;0
WireConnection;172;2;165;0
WireConnection;176;0;230;0
WireConnection;176;1;24;0
WireConnection;176;2;314;0
WireConnection;176;9;281;0
WireConnection;176;6;260;0
ASEEND*/
//CHKSM=100B6F15F5881C740720097AE577BCC6D180C87A