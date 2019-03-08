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
		_AmbientOcclusion("AmbientOcclusion", Range( 0 , 1)) = 0
		_MaxWindStrength("Max Wind Strength", Range( 0 , 1)) = 0.126967
		_WindSwinging("WindSwinging", Range( 0 , 1)) = 0.25
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 1
		_HeightmapInfluence("HeightmapInfluence", Range( 0 , 1)) = 0
		_MinHeight("MinHeight", Range( -1 , 0)) = -0.5
		_MaxHeight("MaxHeight", Range( -1 , 1)) = 0
		_BendingInfluence("BendingInfluence", Range( 0 , 1)) = 0
		_BendingTint("BendingTint", Range( -0.1 , 0.1)) = -0.05
		[Toggle(_VS_TOUCHBEND_ON)] _VS_TOUCHBEND("VS_TOUCHBEND", Float) = 0
		_AlphaClip("AlphaClip", Float) = 0.5
		_Thickness("Thickness", Range( 0 , 1)) = 0
		_Diffusion("Diffusion", Range( 0 , 5)) = 5
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
    }

    SubShader
    {        
		

		Tags { "RenderPipeline"="HDRenderPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Blend Off
		Cull Off
		ZTest LEqual
		ZWrite On
		ZClip [_ZClip]
		
		HLSLINCLUDE
			#pragma target 4.5
            #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
            #pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            
			struct GlobalSurfaceDescription
            {
                float3 Albedo;
                float3 Normal;
                float3 BentNormal;
				float3 Specular;
                float CoatMask;
                float Metallic;
                float3 Emission;
                float Smoothness;
                float Occlusion;
                float Alpha;
				float AlphaClipThreshold;
				float SpecularAAScreenSpaceVariance;
				float SpecularAAThreshold;
				float SpecularOcclusion;
				//Refraction
				float RefractionIndex;
                float3 RefractionColor;
                float RefractionDistance;
				//SSS/Translucent
				float Thickness;
				float SubsurfaceMask;
                float DiffusionProfile;
				//Anisotropy
				float Anisotropy;
				float3 Tangent;
				//Iridescent
				float IridescenceMask;
				float IridescenceThickness;
            };

			struct AlphaSurfaceDescription
            {
                float Alpha;
				float AlphaClipThreshold;
            };

			struct SmoothSurfaceDescription
            {
                float Smoothness;
                float Alpha;
				float AlphaClipThreshold;
            };

			struct DistortionSurfaceDescription
            {
                float Alpha;
                float2 Distortion;
                float DistortionBlur;
				float AlphaClipThreshold;
            };
		ENDHLSL
		
        Pass
        {
			
            Name "GBuffer"
            Tags { "LightMode"="GBuffer" }
           
			Stencil
			{
				Ref 34
				WriteMask 39
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

        
            HLSLPROGRAM

				#pragma vertex Vert
				#pragma fragment Frag
        
				#define ASE_SRP_VERSION 41000
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1
				#pragma shader_feature _VS_TOUCHBEND_ON


			    //#define UNITY_MATERIAL_LIT
            
				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
				#define OUTPUT_SPLIT_LIGHTING
				#endif
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
                #define SHADERPASS SHADERPASS_GBUFFER
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
                #pragma multi_compile _ LIGHT_LAYERS
        
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TANGENT_TO_WORLD
                #define VARYINGS_NEED_TEXCOORD1
                #define VARYINGS_NEED_TEXCOORD2
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"       
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
				
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 tangentOS : TANGENT;
					float4 uv1 : TEXCOORD1;
					float4 uv2 : TEXCOORD2;
					float4 ase_color : COLOR;
					float4 ase_texcoord : TEXCOORD0;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
        
				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float3 interp00 : TEXCOORD0;
					float3 interp01 : TEXCOORD1;
					float4 interp02 : TEXCOORD2;
					float4 interp03 : TEXCOORD3;
					float4 interp04 : TEXCOORD4;
					float4 ase_color : COLOR;
					float4 ase_texcoord5 : TEXCOORD5;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				float _MaxWindStrength;
				float _WindStrength;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _MinHeight;
				float _HeightmapInfluence;
				float _MaxHeight;
				float4 _ColorTop;
				float4 _ColorBottom;
				sampler2D _MainTex;
				float _BendingTint;
				float _AmbientOcclusion;
				float _WindDebug;
				sampler2D _BumpMap;
				float _Smoothness;
				float _AlphaClip;
				float _Thickness;
				float _Diffusion;

				    
				void BuildSurfaceData(FragInputs fragInputs, inout GlobalSurfaceDescription surfaceDescription, float3 V, out SurfaceData surfaceData, out float3 bentNormalWS)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
        
					surfaceData.baseColor =                 surfaceDescription.Albedo;
					surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
			#ifdef _SPECULAR_OCCLUSION_CUSTOM
					surfaceData.specularOcclusion =         surfaceDescription.SpecularOcclusion;
			#endif
					surfaceData.ambientOcclusion =          surfaceDescription.Occlusion;
					surfaceData.metallic =                  surfaceDescription.Metallic;
					surfaceData.coatMask =                  surfaceDescription.CoatMask;
			
			#ifdef _MATERIAL_FEATURE_IRIDESCENCE		
					surfaceData.iridescenceMask =           surfaceDescription.IridescenceMask;
					surfaceData.iridescenceThickness =      surfaceDescription.IridescenceThickness;
			#endif
					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
			#endif
			#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
			#endif
			#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
			#endif

			#ifdef ASE_LIT_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
			#endif

			#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
			#endif
			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.specularColor = surfaceDescription.Specular;
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
			#endif
        
			#if defined (_MATERIAL_FEATURE_SPECULAR_COLOR) && defined (_ENERGY_CONSERVING_SPECULAR)
					surfaceData.baseColor *= (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b));
			#endif
        
					float3 normalTS = float3(0.0f, 0.0f, 1.0f);
					normalTS = surfaceDescription.Normal;
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
        
					bentNormalWS = surfaceData.normalWS;
					surfaceData.geomNormalWS = fragInputs.worldToTangent[2];
			
			#ifdef ASE_BENT_NORMAL
					GetNormalWS(fragInputs, surfaceDescription.BentNormal, bentNormalWS,doubleSidedConstants);
			#endif
			
			#if defined(_HAS_REFRACTION) || defined(_MATERIAL_FEATURE_TRANSMISSION)
					surfaceData.thickness =	                 surfaceDescription.Thickness;
			#endif

			#ifdef _HAS_REFRACTION
					if (_EnableSSRefraction)
					{
						surfaceData.ior =                       surfaceDescription.RefractionIndex;
						surfaceData.transmittanceColor =        surfaceDescription.RefractionColor;
						surfaceData.atDistance =                surfaceDescription.RefractionDistance;
        
						surfaceData.transmittanceMask = (1.0 - surfaceDescription.Alpha);
						surfaceDescription.Alpha = 1.0;
					}
					else
					{
						surfaceData.ior = 1.0;
						surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
						surfaceData.atDistance = 1.0;
						surfaceData.transmittanceMask = 0.0;
						surfaceDescription.Alpha = 1.0;
					}
			#else
					surfaceData.ior = 1.0;
					surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
					surfaceData.atDistance = 1.0;
					surfaceData.transmittanceMask = 0.0;
			#endif

			#if defined(_HAS_REFRACTION) || defined(_MATERIAL_FEATURE_TRANSMISSION)
					surfaceData.thickness =	                 surfaceDescription.Thickness;
			#endif

			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.subsurfaceMask =            surfaceDescription.SubsurfaceMask;
					surfaceData.diffusionProfile =          surfaceDescription.DiffusionProfile;
			#endif

					surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
			#ifdef _MATERIAL_FEATURE_ANISOTROPY	
					surfaceData.anisotropy = surfaceDescription.Anisotropy;
					surfaceData.tangentWS = TransformTangentToWorld(surfaceDescription.Tangent, fragInputs.worldToTangent);
			#endif
					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
			
			#if defined(_SPECULAR_OCCLUSION_CUSTOM)
			#elif defined(_SPECULAR_OCCLUSION_FROM_AO_BENT_NORMAL)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData.normalWS, surfaceData.ambientOcclusion, PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness));
			#elif defined(_AMBIENT_OCCLUSION) && defined(_SPECULAR_OCCLUSION_FROM_AO)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
			#else
					surfaceData.specularOcclusion = 1.0;
			#endif
			#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceData.perceptualSmoothness = GeometricNormalFiltering(surfaceData.perceptualSmoothness, fragInputs.worldToTangent[2], surfaceDescription.SpecularAAScreenSpaceVariance, surfaceDescription.SpecularAAThreshold);
			#endif
				}
        
				void GetSurfaceAndBuiltinData(GlobalSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{
			#ifdef LOD_FADE_CROSSFADE
					uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx));
					LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
			#endif

			#ifdef _ALPHATEST_ON
					DoAlphaTest(surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold);
			#endif

					float3 bentNormalWS;
					BuildSurfaceData(fragInputs, surfaceDescription, V, surfaceData, bentNormalWS);
        
			#if HAVE_DECALS
					if (_EnableDecals)
					{
						DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
						ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
					}
			#endif
        
					InitBuiltinData(surfaceDescription.Alpha, bentNormalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
					builtinData.emissiveColor = surfaceDescription.Emission;
        
					builtinData.depthOffset = 0.0;
        
			#if (SHADERPASS == SHADERPASS_DISTORTION)
					builtinData.distortion = surfaceDescription.Distortion;
					builtinData.distortionBlur = surfaceDescription.DistortionBlur;
			#else
					builtinData.distortion = float2(0.0, 0.0);
					builtinData.distortionBlur = 0.0;
			#endif
        
					PostInitBuiltinData(V, posInput, surfaceData, builtinData);
				}
        
			PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

				float WindStrength522 = _WindStrength;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
				float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
				float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 ) , float3( 0,0,0 ) , ( 1.0 - inputMesh.ase_color.r ));
				float3 Wind84 = lerpResult74;
				float3 temp_output_571_0 = (_ObstaclePosition).xyz;
				float3 normalizeResult184 = normalize( ( temp_output_571_0 - ase_worldPos ) );
				float temp_output_186_0 = ( _BendingStrength * 0.1 );
				float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
				float clampResult192 = clamp( ( distance( temp_output_571_0 , ase_worldPos ) / _BendingRadius ) , 0.0 , 1.0 );
				float3 Bending201 = ( inputMesh.ase_color.r * -( ( ( normalizeResult184 * appendResult468 ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
				float3 temp_output_203_0 = ( Wind84 + Bending201 );
				float3 lerpResult508 = lerp( temp_output_203_0 , ( temp_output_203_0 * 0 ) , 0);
				float3 break437 = lerpResult508;
				float temp_output_499_0 = ( 1.0 - inputMesh.ase_color.r );
				float lerpResult344 = lerp( _MinHeight , 0.0 , temp_output_499_0);
				float lerpResult388 = lerp( _MaxHeight , 0.0 , temp_output_499_0);
				float GrassLength365 = ( ( lerpResult344 * _HeightmapInfluence ) + lerpResult388 );
				float3 appendResult391 = (float3(break437.x , GrassLength365 , break437.z));
				float3 VertexOffset330 = appendResult391;
				
				outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
				outputPackedVaryingsMeshToPS.ase_texcoord5.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord5.zw = 0;
				float3 vertexValue = VertexOffset330;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS = float3(0,1,0);

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
				outputPackedVaryingsMeshToPS.interp00.xyz =	positionRWS;
				outputPackedVaryingsMeshToPS.interp01.xyz =	normalWS;
				outputPackedVaryingsMeshToPS.interp02.xyzw = tangentWS;
				outputPackedVaryingsMeshToPS.interp03.xyzw = inputMesh.uv1;
				outputPackedVaryingsMeshToPS.interp04.xyzw = inputMesh.uv2;
			
				return outputPackedVaryingsMeshToPS;
			}

			void Frag(  PackedVaryingsMeshToPS packedInput,
						OUTPUT_GBUFFER(outGBuffer)
						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						 
						)
			{
				UNITY_SETUP_INSTANCE_ID( packedInput );
				FragInputs input;
				ZERO_INITIALIZE(FragInputs, input);
				input.worldToTangent = k_identity3x3;
				float3 positionRWS = packedInput.interp00.xyz;
				float3 normalWS = packedInput.interp01.xyz;
				float4 tangentWS = packedInput.interp02.xyzw;

				input.positionSS = packedInput.positionCS;
				input.positionRWS = positionRWS;
				input.worldToTangent = BuildWorldToTangent(tangentWS, normalWS);
				input.texCoord1 = packedInput.interp03.xyzw;
				input.texCoord2 = packedInput.interp04.xyzw;

				PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);
				float3 normalizedWorldViewDir = GetWorldSpaceNormalizeViewDir(input.positionRWS);
				SurfaceData surfaceData;
				BuiltinData builtinData;

				GlobalSurfaceDescription surfaceDescription = (GlobalSurfaceDescription)0;
				float4 lerpResult363 = lerp( _ColorTop , _ColorBottom , ( 1.0 - packedInput.ase_color.r ));
				float2 uv_MainTex97 = packedInput.ase_texcoord5.xy;
				float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
				float4 BaseColor551 = ( lerpResult363 * tex2DNode97 );
				float4 Color161 = BaseColor551;
				#ifdef _VS_TOUCHBEND_ON
				float staticSwitch659 = (float3( 0,0,0 )).y;
				#else
				float staticSwitch659 = 0.0;
				#endif
				float TouchBendPos613 = staticSwitch659;
				float4 temp_cast_0 = (( TouchBendPos613 * _BendingTint )).xxxx;
				float clampResult302 = clamp( ( ( packedInput.ase_color.r * 1.33 ) * _AmbientOcclusion ) , 0.0 , 1.0 );
				float lerpResult115 = lerp( 1.0 , clampResult302 , _AmbientOcclusion);
				float AmbientOcclusion207 = lerpResult115;
				float4 FinalColor205 = ( ( Color161 - temp_cast_0 ) * AmbientOcclusion207 );
				float3 ase_worldPos = GetAbsolutePositionWS( positionRWS );
				float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
				float3 WindVector91 = UnpackNormalmapRGorAG( tex2D( _WindVectors, ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ) ), 1.0f );
				float4 lerpResult310 = lerp( FinalColor205 , float4( WindVector91 , 0.0 ) , _WindDebug);
				
				float2 uv_BumpMap172 = packedInput.ase_texcoord5.xy;
				float3 Normals174 = UnpackNormalmapRGorAG( tex2D( _BumpMap, uv_BumpMap172 ), 1.0 );
				
				float Alpha98 = tex2DNode97.a;
				
                surfaceDescription.Albedo = lerpResult310.rgb;
                surfaceDescription.Normal = Normals174;
                surfaceDescription.BentNormal = float3( 0, 0, 1 );
                surfaceDescription.CoatMask = 0;
                surfaceDescription.Metallic = 0;
				
				#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceDescription.Specular = 0;
				#endif
                
				surfaceDescription.Emission = 0;
                surfaceDescription.Smoothness = _Smoothness;
                surfaceDescription.Occlusion = 1;
				surfaceDescription.Alpha = Alpha98;
				
				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = _AlphaClip;
				#endif

				#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
				surfaceDescription.SpecularAAScreenSpaceVariance = 0;
				surfaceDescription.SpecularAAThreshold = 0;
				#endif

				#ifdef _SPECULAR_OCCLUSION_CUSTOM
				surfaceDescription.SpecularOcclusion = 0;
				#endif

				#if defined(_HAS_REFRACTION) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceDescription.Thickness = _Thickness;
				#endif

				#ifdef _HAS_REFRACTION
				surfaceDescription.RefractionIndex = 1;
                surfaceDescription.RefractionColor = float3(1,1,1);
                surfaceDescription.RefractionDistance = 0;
				#endif

				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceDescription.SubsurfaceMask = 1;
                surfaceDescription.DiffusionProfile = _Diffusion;
				#endif

				#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceDescription.Anisotropy = 1;
				surfaceDescription.Tangent = float3(1,0,0);
				#endif

				#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceDescription.IridescenceMask = 0;
				surfaceDescription.IridescenceThickness = 0;
				#endif

				GetSurfaceAndBuiltinData(surfaceDescription,input, normalizedWorldViewDir, posInput, surfaceData, builtinData);
				ENCODE_INTO_GBUFFER(surfaceData, builtinData, posInput.positionSS, outGBuffer);
			#ifdef _DEPTHOFFSET_ON
				outputDepth = posInput.deviceDepth;
			#endif
			}
     
            ENDHLSL
        }  

		
        Pass
        {
			
            Name "META"
            Tags { "LightMode"="Meta" }
            Cull Off
            
            HLSLPROGRAM
        
				#pragma vertex Vert
				#pragma fragment Frag
        
				#define ASE_SRP_VERSION 41000
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1
				#pragma shader_feature _VS_TOUCHBEND_ON


				//#define UNITY_MATERIAL_LIT   

				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
				#define OUTPUT_SPLIT_LIGHTING
				#endif
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
				#define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
        
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define ATTRIBUTES_NEED_COLOR
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 tangentOS : TANGENT;
					float4 uv0 : TEXCOORD0;
					float4 uv1 : TEXCOORD1;
					float4 uv2 : TEXCOORD2;
					float4 color : COLOR;
					
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
        
				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position; 
					float4 ase_color : COLOR;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_texcoord1 : TEXCOORD1;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				float _MaxWindStrength;
				float _WindStrength;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _MinHeight;
				float _HeightmapInfluence;
				float _MaxHeight;
				float4 _ColorTop;
				float4 _ColorBottom;
				sampler2D _MainTex;
				float _BendingTint;
				float _AmbientOcclusion;
				float _WindDebug;
				sampler2D _BumpMap;
				float _Smoothness;
				float _AlphaClip;
				float _Thickness;
				float _Diffusion;
				
				                
				void BuildSurfaceData(FragInputs fragInputs, inout GlobalSurfaceDescription surfaceDescription, float3 V, out SurfaceData surfaceData, out float3 bentNormalWS)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
					surfaceData.baseColor =                 surfaceDescription.Albedo;
					surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
			#ifdef _SPECULAR_OCCLUSION_CUSTOM
					surfaceData.specularOcclusion =         surfaceDescription.SpecularOcclusion;
			#endif
					surfaceData.ambientOcclusion =          surfaceDescription.Occlusion;
					surfaceData.metallic =                  surfaceDescription.Metallic;
					surfaceData.coatMask =                  surfaceDescription.CoatMask;
		
			#ifdef _MATERIAL_FEATURE_IRIDESCENCE		
					surfaceData.iridescenceMask =           surfaceDescription.IridescenceMask;
					surfaceData.iridescenceThickness =      surfaceDescription.IridescenceThickness;
			#endif
					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
			#endif
			#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
			#endif
			#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
			#endif

        	#ifdef ASE_LIT_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
			#endif

			#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
			#endif
			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.specularColor = surfaceDescription.Specular;
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
			#endif
        
			#if defined (_MATERIAL_FEATURE_SPECULAR_COLOR) && defined (_ENERGY_CONSERVING_SPECULAR)
					surfaceData.baseColor *= (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b));
			#endif
					float3 normalTS = float3(0.0f, 0.0f, 1.0f);
					normalTS = surfaceDescription.Normal;
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);

					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
					bentNormalWS = surfaceData.normalWS;
					surfaceData.geomNormalWS = fragInputs.worldToTangent[2];
			
			#ifdef ASE_BENT_NORMAL
					GetNormalWS(fragInputs, surfaceDescription.BentNormal, bentNormalWS,doubleSidedConstants);
			#endif
			
			#ifdef _HAS_REFRACTION
					if (_EnableSSRefraction)
					{
						surfaceData.ior =                       surfaceDescription.RefractionIndex;
						surfaceData.transmittanceColor =        surfaceDescription.RefractionColor;
						surfaceData.atDistance =                surfaceDescription.RefractionDistance;
        
						surfaceData.transmittanceMask = (1.0 - surfaceDescription.Alpha);
						surfaceDescription.Alpha = 1.0;
					}
					else
					{
						surfaceData.ior = 1.0;
						surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
						surfaceData.atDistance = 1.0;
						surfaceData.transmittanceMask = 0.0;
						surfaceDescription.Alpha = 1.0;
					}
			#else
					surfaceData.ior = 1.0;
					surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
					surfaceData.atDistance = 1.0;
					surfaceData.transmittanceMask = 0.0;
			#endif

			#if defined(_HAS_REFRACTION) || defined(_MATERIAL_FEATURE_TRANSMISSION)
					surfaceData.thickness =	                 surfaceDescription.Thickness;
			#endif

			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.subsurfaceMask =            surfaceDescription.SubsurfaceMask;
					surfaceData.diffusionProfile =          surfaceDescription.DiffusionProfile;
			#endif

					surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
			#ifdef _MATERIAL_FEATURE_ANISOTROPY	
					surfaceData.anisotropy = surfaceDescription.Anisotropy;
					surfaceData.tangentWS = TransformTangentToWorld(surfaceDescription.Tangent, fragInputs.worldToTangent);
			#endif
					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
			#if defined(_SPECULAR_OCCLUSION_CUSTOM)
			#elif defined(_SPECULAR_OCCLUSION_FROM_AO_BENT_NORMAL)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData.normalWS, surfaceData.ambientOcclusion, PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness));
			#elif defined(_AMBIENT_OCCLUSION) && defined(_SPECULAR_OCCLUSION_FROM_AO)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
			#else
					surfaceData.specularOcclusion = 1.0;
			#endif
			#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceData.perceptualSmoothness = GeometricNormalFiltering(surfaceData.perceptualSmoothness, fragInputs.worldToTangent[2], surfaceDescription.SpecularAAScreenSpaceVariance, surfaceDescription.SpecularAAThreshold);
			#endif
        
				}
        
				void GetSurfaceAndBuiltinData(GlobalSurfaceDescription surfaceDescription,FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{
			#ifdef LOD_FADE_CROSSFADE
					uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx)); // Quantize V to _ScreenSize values
					LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
			#endif
        
					#ifdef _ALPHATEST_ON
						DoAlphaTest(surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold);
					#endif

					float3 bentNormalWS;
					BuildSurfaceData(fragInputs, surfaceDescription, V, surfaceData, bentNormalWS);
        
			#if HAVE_DECALS
					if (_EnableDecals)
					{
						DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
						ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
					}
			#endif
        
					InitBuiltinData(surfaceDescription.Alpha, bentNormalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
					builtinData.emissiveColor = surfaceDescription.Emission;
        
					builtinData.depthOffset = 0.0;                        
        
			#if (SHADERPASS == SHADERPASS_DISTORTION)
					builtinData.distortion = surfaceDescription.Distortion;
					builtinData.distortionBlur = surfaceDescription.DistortionBlur;
			#else
					builtinData.distortion = float2(0.0, 0.0);
					builtinData.distortionBlur = 0.0;
			#endif
        
					PostInitBuiltinData(V, posInput, surfaceData, builtinData);
				}
        
				CBUFFER_START(UnityMetaPass)
				bool4 unity_MetaVertexControl;
				bool4 unity_MetaFragmentControl;
				CBUFFER_END

				float unity_OneOverOutputBoost;
				float unity_MaxOutputValue;

				PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh  )
				{
					PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

					UNITY_SETUP_INSTANCE_ID(inputMesh);
					UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

					float WindStrength522 = _WindStrength;
					float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
					float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
					float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
					float3 break277 = WindVector91;
					float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
					float3 temp_cast_0 = (-1.0).xxx;
					float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
					float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 ) , float3( 0,0,0 ) , ( 1.0 - inputMesh.color.r ));
					float3 Wind84 = lerpResult74;
					float3 temp_output_571_0 = (_ObstaclePosition).xyz;
					float3 normalizeResult184 = normalize( ( temp_output_571_0 - ase_worldPos ) );
					float temp_output_186_0 = ( _BendingStrength * 0.1 );
					float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
					float clampResult192 = clamp( ( distance( temp_output_571_0 , ase_worldPos ) / _BendingRadius ) , 0.0 , 1.0 );
					float3 Bending201 = ( inputMesh.color.r * -( ( ( normalizeResult184 * appendResult468 ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
					float3 temp_output_203_0 = ( Wind84 + Bending201 );
					float3 lerpResult508 = lerp( temp_output_203_0 , ( temp_output_203_0 * 0 ) , 0);
					float3 break437 = lerpResult508;
					float temp_output_499_0 = ( 1.0 - inputMesh.color.r );
					float lerpResult344 = lerp( _MinHeight , 0.0 , temp_output_499_0);
					float lerpResult388 = lerp( _MaxHeight , 0.0 , temp_output_499_0);
					float GrassLength365 = ( ( lerpResult344 * _HeightmapInfluence ) + lerpResult388 );
					float3 appendResult391 = (float3(break437.x , GrassLength365 , break437.z));
					float3 VertexOffset330 = appendResult391;
					
					outputPackedVaryingsMeshToPS.ase_texcoord1.xyz = ase_worldPos;
					
					outputPackedVaryingsMeshToPS.ase_color = inputMesh.color;
					outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.uv0.xy;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord1.w = 0;
					float3 vertexValue = VertexOffset330;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
					#else
					inputMesh.positionOS.xyz += vertexValue;
					#endif
					
					inputMesh.normalOS = float3(0,1,0);

					float2 uv;

					if (unity_MetaVertexControl.x)
					{
						uv = inputMesh.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					}
					else if (unity_MetaVertexControl.y)
					{
						uv = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
					}

					outputPackedVaryingsMeshToPS.positionCS = float4(uv * 2.0 - 1.0, inputMesh.positionOS.z > 0 ? 1.0e-4 : 0.0, 1.0);
					return outputPackedVaryingsMeshToPS;
				}

				float4 Frag(PackedVaryingsMeshToPS packedInput  ) : SV_Target
				{			
					UNITY_SETUP_INSTANCE_ID( packedInput );
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
					input.worldToTangent = k_identity3x3;
					input.positionSS = packedInput.positionCS;
         
					PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);
					float3 V = float3(1.0, 1.0, 1.0);

					SurfaceData surfaceData;
					BuiltinData builtinData;
					GlobalSurfaceDescription surfaceDescription = (GlobalSurfaceDescription)0;
					float4 lerpResult363 = lerp( _ColorTop , _ColorBottom , ( 1.0 - packedInput.ase_color.r ));
					float2 uv_MainTex97 = packedInput.ase_texcoord.xy;
					float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
					float4 BaseColor551 = ( lerpResult363 * tex2DNode97 );
					float4 Color161 = BaseColor551;
					#ifdef _VS_TOUCHBEND_ON
					float staticSwitch659 = (float3( 0,0,0 )).y;
					#else
					float staticSwitch659 = 0.0;
					#endif
					float TouchBendPos613 = staticSwitch659;
					float4 temp_cast_0 = (( TouchBendPos613 * _BendingTint )).xxxx;
					float clampResult302 = clamp( ( ( packedInput.ase_color.r * 1.33 ) * _AmbientOcclusion ) , 0.0 , 1.0 );
					float lerpResult115 = lerp( 1.0 , clampResult302 , _AmbientOcclusion);
					float AmbientOcclusion207 = lerpResult115;
					float4 FinalColor205 = ( ( Color161 - temp_cast_0 ) * AmbientOcclusion207 );
					float3 ase_worldPos = packedInput.ase_texcoord1.xyz;
					float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
					float3 WindVector91 = UnpackNormalmapRGorAG( tex2D( _WindVectors, ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ) ), 1.0f );
					float4 lerpResult310 = lerp( FinalColor205 , float4( WindVector91 , 0.0 ) , _WindDebug);
					
					float2 uv_BumpMap172 = packedInput.ase_texcoord.xy;
					float3 Normals174 = UnpackNormalmapRGorAG( tex2D( _BumpMap, uv_BumpMap172 ), 1.0 );
					
					float Alpha98 = tex2DNode97.a;
					
					surfaceDescription.Albedo = lerpResult310.rgb;
					surfaceDescription.Normal = Normals174;
					surfaceDescription.BentNormal = float3( 0, 0, 1 );
					surfaceDescription.CoatMask = 0;
					surfaceDescription.Metallic = 0;
					
					#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceDescription.Specular = 0;
					#endif
					
					surfaceDescription.Emission = 0;
					surfaceDescription.Smoothness = _Smoothness;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Alpha = Alpha98;
					
					#ifdef _ALPHATEST_ON
					surfaceDescription.AlphaClipThreshold = _AlphaClip;
					#endif

					#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceDescription.SpecularAAScreenSpaceVariance = 0;
					surfaceDescription.SpecularAAThreshold = 0;
					#endif

					#ifdef _SPECULAR_OCCLUSION_CUSTOM
					surfaceDescription.SpecularOcclusion = 0;
					#endif

					#if defined(_HAS_REFRACTION) || defined(_MATERIAL_FEATURE_TRANSMISSION)
					surfaceDescription.Thickness = _Thickness;
					#endif

					#ifdef _HAS_REFRACTION
					surfaceDescription.RefractionIndex = 1;
					surfaceDescription.RefractionColor = float3(1,1,1);
					surfaceDescription.RefractionDistance = 0;
					#endif

					#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceDescription.SubsurfaceMask = 1;
					surfaceDescription.DiffusionProfile = _Diffusion;
					#endif

					#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceDescription.Anisotropy = 1;
					surfaceDescription.Tangent = float3(1,0,0);
					#endif

					#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceDescription.IridescenceMask = 0;
					surfaceDescription.IridescenceThickness = 0;
					#endif

					GetSurfaceAndBuiltinData(surfaceDescription,input, V, posInput, surfaceData, builtinData);

					BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);
					LightTransportData lightTransportData = GetLightTransportData(surfaceData, builtinData, bsdfData);

					float4 res = float4(0.0, 0.0, 0.0, 1.0);
					if (unity_MetaFragmentControl.x)
					{
						res.rgb = clamp(pow(abs(lightTransportData.diffuseColor), saturate(unity_OneOverOutputBoost)), 0, unity_MaxOutputValue);
					}

					if (unity_MetaFragmentControl.y)
					{
						res.rgb = lightTransportData.emissiveColor;
					}

					return res;
				}

            ENDHLSL
        }

		
		Pass
        {
			
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }
			ColorMask 0
        
            HLSLPROGRAM
				#pragma vertex Vert
				#pragma fragment Frag
        
				#define ASE_SRP_VERSION 41000
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1


				//#define UNITY_MATERIAL_LIT
        
				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
				#define OUTPUT_SPLIT_LIGHTING
				#endif
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
                #define SHADERPASS SHADERPASS_SHADOWS
                #define USE_LEGACY_UNITY_MATRIX_VARIABLES
        
			    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
        
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 ase_color : COLOR;
					float4 ase_texcoord : TEXCOORD0;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif 
				};
        
				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float4 ase_texcoord : TEXCOORD0;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				float _MaxWindStrength;
				float _WindStrength;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _MinHeight;
				float _HeightmapInfluence;
				float _MaxHeight;
				sampler2D _MainTex;
				float _AlphaClip;
				
				                
				void BuildSurfaceData(FragInputs fragInputs, inout AlphaSurfaceDescription surfaceDescription, float3 V, out SurfaceData surfaceData, out float3 bentNormalWS)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
        
					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
			#endif
			#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
			#endif
			#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
			#endif
        
			#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
			#endif
			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
			#endif
        
			#if defined (_MATERIAL_FEATURE_SPECULAR_COLOR) && defined (_ENERGY_CONSERVING_SPECULAR)
					surfaceData.baseColor *= (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b));
			#endif
        
					float3 normalTS = float3(0.0f, 0.0f, 1.0f);
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
					bentNormalWS = surfaceData.normalWS;
					surfaceData.geomNormalWS = fragInputs.worldToTangent[2];
        
			#ifdef _HAS_REFRACTION
					if (_EnableSSRefraction)
					{
        
						surfaceData.transmittanceMask = (1.0 - surfaceDescription.Alpha);
						surfaceDescription.Alpha = 1.0;
					}
					else
					{
						surfaceData.ior = 1.0;
						surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
						surfaceData.atDistance = 1.0;
						surfaceData.transmittanceMask = 0.0;
						surfaceDescription.Alpha = 1.0;
					}
			#else
					surfaceData.ior = 1.0;
					surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
					surfaceData.atDistance = 1.0;
					surfaceData.transmittanceMask = 0.0;
		 #endif
        
					surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
			#if defined(_SPECULAR_OCCLUSION_CUSTOM)
			#elif defined(_SPECULAR_OCCLUSION_FROM_AO_BENT_NORMAL)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData.normalWS, surfaceData.ambientOcclusion, PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness));
			#elif defined(_AMBIENT_OCCLUSION) && defined(_SPECULAR_OCCLUSION_FROM_AO)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
			#else
					surfaceData.specularOcclusion = 1.0;
			#endif
			#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceData.perceptualSmoothness = GeometricNormalFiltering(surfaceData.perceptualSmoothness, fragInputs.worldToTangent[2], surfaceDescription.SpecularAAScreenSpaceVariance, surfaceDescription.SpecularAAThreshold);
			#endif
        
				}
        
            void GetSurfaceAndBuiltinData(AlphaSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
        #ifdef LOD_FADE_CROSSFADE
                uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx));
                LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
        #endif
    
		#ifdef _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
		#endif
                float3 bentNormalWS;
                BuildSurfaceData(fragInputs, surfaceDescription, V, surfaceData, bentNormalWS);
        
        #if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
        #endif
        
                InitBuiltinData(surfaceDescription.Alpha, bentNormalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
                builtinData.depthOffset = 0.0;
        
        #if (SHADERPASS == SHADERPASS_DISTORTION)
                builtinData.distortion = surfaceDescription.Distortion;
                builtinData.distortionBlur = surfaceDescription.DistortionBlur;
        #else
                builtinData.distortion = float2(0.0, 0.0);
                builtinData.distortionBlur = 0.0;
        #endif
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);
            }
        
			PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh  )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;
				
				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

				float WindStrength522 = _WindStrength;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
				float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
				float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 ) , float3( 0,0,0 ) , ( 1.0 - inputMesh.ase_color.r ));
				float3 Wind84 = lerpResult74;
				float3 temp_output_571_0 = (_ObstaclePosition).xyz;
				float3 normalizeResult184 = normalize( ( temp_output_571_0 - ase_worldPos ) );
				float temp_output_186_0 = ( _BendingStrength * 0.1 );
				float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
				float clampResult192 = clamp( ( distance( temp_output_571_0 , ase_worldPos ) / _BendingRadius ) , 0.0 , 1.0 );
				float3 Bending201 = ( inputMesh.ase_color.r * -( ( ( normalizeResult184 * appendResult468 ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
				float3 temp_output_203_0 = ( Wind84 + Bending201 );
				float3 lerpResult508 = lerp( temp_output_203_0 , ( temp_output_203_0 * 0 ) , 0);
				float3 break437 = lerpResult508;
				float temp_output_499_0 = ( 1.0 - inputMesh.ase_color.r );
				float lerpResult344 = lerp( _MinHeight , 0.0 , temp_output_499_0);
				float lerpResult388 = lerp( _MaxHeight , 0.0 , temp_output_499_0);
				float GrassLength365 = ( ( lerpResult344 * _HeightmapInfluence ) + lerpResult388 );
				float3 appendResult391 = (float3(break437.x , GrassLength365 , break437.z));
				float3 VertexOffset330 = appendResult391;
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				float3 vertexValue = VertexOffset330;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif 
				inputMesh.normalOS = float3(0,1,0);

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS.xyz);
				outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
				return outputPackedVaryingsMeshToPS;
			}

			void Frag(  PackedVaryingsMeshToPS packedInput
						#ifdef WRITE_NORMAL_BUFFER
						, out float4 outNormalBuffer : SV_Target0
							#ifdef WRITE_MSAA_DEPTH
						, out float1 depthColor : SV_Target1
							#endif
						#endif

						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						
					)
			{
				UNITY_SETUP_INSTANCE_ID( packedInput );
				FragInputs input;
				ZERO_INITIALIZE(FragInputs, input);
				input.worldToTangent = k_identity3x3;
				input.positionSS = packedInput.positionCS;
			
				PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);
				float3 V = float3(1.0, 1.0, 1.0);

				SurfaceData surfaceData;
				BuiltinData builtinData;
				AlphaSurfaceDescription surfaceDescription = (AlphaSurfaceDescription)0;
				float2 uv_MainTex97 = packedInput.ase_texcoord.xy;
				float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
				float Alpha98 = tex2DNode97.a;
				
				surfaceDescription.Alpha = Alpha98;

				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = _AlphaClip;
				#endif

				GetSurfaceAndBuiltinData(surfaceDescription, input, V, posInput, surfaceData, builtinData);

			#ifdef _DEPTHOFFSET_ON
				outputDepth = posInput.deviceDepth;
			#endif

			#ifdef WRITE_NORMAL_BUFFER
				EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);
				#ifdef WRITE_MSAA_DEPTH
				depthColor = packedInput.positionCS.z;
				#endif
			#endif
			}

            ENDHLSL
        }

			
		Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }
            ColorMask 0
        	
            HLSLPROGRAM
				#pragma vertex Vert
				#pragma fragment Frag
        
				#define ASE_SRP_VERSION 41000
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1


				//#define UNITY_MATERIAL_LIT
        
				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
				#define OUTPUT_SPLIT_LIGHTING
				#endif
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            
                #define SHADERPASS SHADERPASS_DEPTH_ONLY
                #define SCENESELECTIONPASS
        
			    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
				int _ObjectId;
				int _PassValue;
        
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 ase_color : COLOR;
					float4 ase_texcoord : TEXCOORD0;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
        
				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float4 ase_texcoord : TEXCOORD0;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				float _MaxWindStrength;
				float _WindStrength;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _MinHeight;
				float _HeightmapInfluence;
				float _MaxHeight;
				sampler2D _MainTex;
				float _AlphaClip;

				        
				void BuildSurfaceData(FragInputs fragInputs, inout AlphaSurfaceDescription surfaceDescription, float3 V, out SurfaceData surfaceData, out float3 bentNormalWS)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);

					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
			#endif
			#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
			#endif
			#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
			#endif
        
			#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
			#endif
			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
			#endif
        
			#if defined (_MATERIAL_FEATURE_SPECULAR_COLOR) && defined (_ENERGY_CONSERVING_SPECULAR)
					surfaceData.baseColor *= (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b));
			#endif
        
					float3 normalTS = float3(0.0f, 0.0f, 1.0f);
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
        
					bentNormalWS = surfaceData.normalWS;
					surfaceData.geomNormalWS = fragInputs.worldToTangent[2];
        
			#ifdef _HAS_REFRACTION
					if (_EnableSSRefraction)
					{
        
						surfaceData.transmittanceMask = (1.0 - surfaceDescription.Alpha);
						surfaceDescription.Alpha = 1.0;
					}
					else
					{
						surfaceData.ior = 1.0;
						surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
						surfaceData.atDistance = 1.0;
						surfaceData.transmittanceMask = 0.0;
						surfaceDescription.Alpha = 1.0;
					}
			#else
					surfaceData.ior = 1.0;
					surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
					surfaceData.atDistance = 1.0;
					surfaceData.transmittanceMask = 0.0;
			#endif
        
					surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
			#if defined(_SPECULAR_OCCLUSION_CUSTOM)
			#elif defined(_SPECULAR_OCCLUSION_FROM_AO_BENT_NORMAL)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData.normalWS, surfaceData.ambientOcclusion, PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness));
			#elif defined(_AMBIENT_OCCLUSION) && defined(_SPECULAR_OCCLUSION_FROM_AO)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
			#else
					surfaceData.specularOcclusion = 1.0;
			#endif
			#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceData.perceptualSmoothness = GeometricNormalFiltering(surfaceData.perceptualSmoothness, fragInputs.worldToTangent[2], surfaceDescription.SpecularAAScreenSpaceVariance, surfaceDescription.SpecularAAThreshold);
			#endif

				}
        
            void GetSurfaceAndBuiltinData(AlphaSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
        #ifdef LOD_FADE_CROSSFADE 
                uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx));
                LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
        #endif
        
		#ifdef _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
		#endif

                float3 bentNormalWS;
                BuildSurfaceData(fragInputs, surfaceDescription, V, surfaceData, bentNormalWS);
        
        #if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
        #endif
        
                InitBuiltinData(surfaceDescription.Alpha, bentNormalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
                builtinData.depthOffset = 0.0;
        
        #if (SHADERPASS == SHADERPASS_DISTORTION)
                builtinData.distortion = surfaceDescription.Distortion;
                builtinData.distortionBlur = surfaceDescription.DistortionBlur;
        #else
                builtinData.distortion = float2(0.0, 0.0);
                builtinData.distortionBlur = 0.0;
        #endif
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);
            }
        
			PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh  )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;
				
				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

				float WindStrength522 = _WindStrength;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
				float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
				float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 ) , float3( 0,0,0 ) , ( 1.0 - inputMesh.ase_color.r ));
				float3 Wind84 = lerpResult74;
				float3 temp_output_571_0 = (_ObstaclePosition).xyz;
				float3 normalizeResult184 = normalize( ( temp_output_571_0 - ase_worldPos ) );
				float temp_output_186_0 = ( _BendingStrength * 0.1 );
				float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
				float clampResult192 = clamp( ( distance( temp_output_571_0 , ase_worldPos ) / _BendingRadius ) , 0.0 , 1.0 );
				float3 Bending201 = ( inputMesh.ase_color.r * -( ( ( normalizeResult184 * appendResult468 ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
				float3 temp_output_203_0 = ( Wind84 + Bending201 );
				float3 lerpResult508 = lerp( temp_output_203_0 , ( temp_output_203_0 * 0 ) , 0);
				float3 break437 = lerpResult508;
				float temp_output_499_0 = ( 1.0 - inputMesh.ase_color.r );
				float lerpResult344 = lerp( _MinHeight , 0.0 , temp_output_499_0);
				float lerpResult388 = lerp( _MaxHeight , 0.0 , temp_output_499_0);
				float GrassLength365 = ( ( lerpResult344 * _HeightmapInfluence ) + lerpResult388 );
				float3 appendResult391 = (float3(break437.x , GrassLength365 , break437.z));
				float3 VertexOffset330 = appendResult391;
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				float3 vertexValue = VertexOffset330;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif 
				inputMesh.normalOS = float3(0,1,0);

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
				outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
				return outputPackedVaryingsMeshToPS;
			}

			void Frag(  PackedVaryingsMeshToPS packedInput
						#ifdef WRITE_NORMAL_BUFFER
						, out float4 outNormalBuffer : SV_Target0
							#ifdef WRITE_MSAA_DEPTH
						, out float1 depthColor : SV_Target1
							#endif
						#elif defined(SCENESELECTIONPASS)
						, out float4 outColor : SV_Target0
						#endif

						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						
					)
			{
				UNITY_SETUP_INSTANCE_ID( packedInput );
				FragInputs input;
				ZERO_INITIALIZE(FragInputs, input);
				input.worldToTangent = k_identity3x3;
				input.positionSS = packedInput.positionCS;

				PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

				float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0

				SurfaceData surfaceData;
				BuiltinData builtinData;
				AlphaSurfaceDescription surfaceDescription = (AlphaSurfaceDescription)0;
				float2 uv_MainTex97 = packedInput.ase_texcoord.xy;
				float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
				float Alpha98 = tex2DNode97.a;
				
				surfaceDescription.Alpha = Alpha98;
				
				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = _AlphaClip;
				#endif

				GetSurfaceAndBuiltinData(surfaceDescription,input, V, posInput, surfaceData, builtinData);

			#ifdef _DEPTHOFFSET_ON
				outputDepth = posInput.deviceDepth;
			#endif

			#ifdef WRITE_NORMAL_BUFFER
				EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);
				#ifdef WRITE_MSAA_DEPTH
				depthColor = packedInput.positionCS.z;
				#endif
			#elif defined(SCENESELECTIONPASS)
				outColor = float4(_ObjectId, _PassValue, 1.0, 1.0);
			#endif
			}

            ENDHLSL
        } 

		
        Pass
        {
			
            Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }
        
            HLSLPROGRAM
				#pragma vertex Vert
				#pragma fragment Frag
        
				#define ASE_SRP_VERSION 41000
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1


				//#define UNITY_MATERIAL_LIT
        
				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
				#define OUTPUT_SPLIT_LIGHTING
				#endif
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
                #define SHADERPASS SHADERPASS_DEPTH_ONLY
                #pragma multi_compile _ WRITE_NORMAL_BUFFER
                #pragma multi_compile _ WRITE_MSAA_DEPTH
        
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define ATTRIBUTES_NEED_TEXCOORD3
                #define ATTRIBUTES_NEED_COLOR
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TANGENT_TO_WORLD
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_TEXCOORD1
                #define VARYINGS_NEED_TEXCOORD2
                #define VARYINGS_NEED_TEXCOORD3
                #define VARYINGS_NEED_COLOR
        
        
			    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 tangentOS : TANGENT;
					float4 uv0 : TEXCOORD0;
					float4 uv1 : TEXCOORD1;
					float4 uv2 : TEXCOORD2;
					float4 uv3 : TEXCOORD3;
					float4 color : COLOR;
					
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
        
				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float3 interp00 : TEXCOORD0;
					float3 interp01 : TEXCOORD1;
					float4 interp02 : TEXCOORD2;
					float4 interp03 : TEXCOORD3;
					float4 interp04 : TEXCOORD4;
					float4 interp05 : TEXCOORD5;
					float4 interp06 : TEXCOORD6;
					float4 interp07 : TEXCOORD7;
					
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
      
				float _MaxWindStrength;
				float _WindStrength;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _MinHeight;
				float _HeightmapInfluence;
				float _MaxHeight;
				float _Smoothness;
				sampler2D _MainTex;
				float _AlphaClip;

				                    
				void BuildSurfaceData(FragInputs fragInputs, inout SmoothSurfaceDescription surfaceDescription, float3 V, out SurfaceData surfaceData, out float3 bentNormalWS)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
					surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
                
					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
			#endif
			#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
			#endif
			#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
			#endif
        
			#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
			#endif
			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
			#endif
        
			#if defined (_MATERIAL_FEATURE_SPECULAR_COLOR) && defined (_ENERGY_CONSERVING_SPECULAR)
					surfaceData.baseColor *= (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b));
			#endif
        
					float3 normalTS = float3(0.0f, 0.0f, 1.0f);
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
					bentNormalWS = surfaceData.normalWS;
					surfaceData.geomNormalWS = fragInputs.worldToTangent[2];

			#ifdef _HAS_REFRACTION
					surfaceData.transmittanceMask = 1.0 - surfaceDescription.Alpha;
					surfaceDescription.Alpha = 1.0;
			#endif
        
					surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
			#if defined(_SPECULAR_OCCLUSION_CUSTOM)
			#elif defined(_SPECULAR_OCCLUSION_FROM_AO_BENT_NORMAL)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData.normalWS, surfaceData.ambientOcclusion, PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness));
			#elif defined(_AMBIENT_OCCLUSION) && defined(_SPECULAR_OCCLUSION_FROM_AO)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
			#else
					surfaceData.specularOcclusion = 1.0;
			#endif
			#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceData.perceptualSmoothness = GeometricNormalFiltering(surfaceData.perceptualSmoothness, fragInputs.worldToTangent[2], surfaceDescription.SpecularAAScreenSpaceVariance, surfaceDescription.SpecularAAThreshold);
			#endif
        
				}
        
            void GetSurfaceAndBuiltinData(SmoothSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
        #ifdef LOD_FADE_CROSSFADE
                uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx)); 
                LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
        #endif
        
		#ifdef _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
		#endif

                float3 bentNormalWS;
                BuildSurfaceData(fragInputs, surfaceDescription, V, surfaceData, bentNormalWS);
        
        #if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
        #endif
        
                InitBuiltinData(surfaceDescription.Alpha, bentNormalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
                builtinData.depthOffset = 0.0;
        
        #if (SHADERPASS == SHADERPASS_DISTORTION)
                builtinData.distortion = surfaceDescription.Distortion;
                builtinData.distortionBlur = surfaceDescription.DistortionBlur;
        #else
                builtinData.distortion = float2(0.0, 0.0);
                builtinData.distortionBlur = 0.0;
        #endif
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);
            }
        
			PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;
				
				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);
				
				float WindStrength522 = _WindStrength;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
				float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
				float3 break277 = WindVector91;
				float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
				float3 temp_cast_0 = (-1.0).xxx;
				float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
				float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 ) , float3( 0,0,0 ) , ( 1.0 - inputMesh.color.r ));
				float3 Wind84 = lerpResult74;
				float3 temp_output_571_0 = (_ObstaclePosition).xyz;
				float3 normalizeResult184 = normalize( ( temp_output_571_0 - ase_worldPos ) );
				float temp_output_186_0 = ( _BendingStrength * 0.1 );
				float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
				float clampResult192 = clamp( ( distance( temp_output_571_0 , ase_worldPos ) / _BendingRadius ) , 0.0 , 1.0 );
				float3 Bending201 = ( inputMesh.color.r * -( ( ( normalizeResult184 * appendResult468 ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
				float3 temp_output_203_0 = ( Wind84 + Bending201 );
				float3 lerpResult508 = lerp( temp_output_203_0 , ( temp_output_203_0 * 0 ) , 0);
				float3 break437 = lerpResult508;
				float temp_output_499_0 = ( 1.0 - inputMesh.color.r );
				float lerpResult344 = lerp( _MinHeight , 0.0 , temp_output_499_0);
				float lerpResult388 = lerp( _MaxHeight , 0.0 , temp_output_499_0);
				float GrassLength365 = ( ( lerpResult344 * _HeightmapInfluence ) + lerpResult388 );
				float3 appendResult391 = (float3(break437.x , GrassLength365 , break437.z));
				float3 VertexOffset330 = appendResult391;
				
				float3 vertexValue = VertexOffset330;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif 

				inputMesh.normalOS = float3(0,1,0);

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
				outputPackedVaryingsMeshToPS.interp00.xyz = positionRWS;
				outputPackedVaryingsMeshToPS.interp01.xyz = normalWS;
				outputPackedVaryingsMeshToPS.interp02.xyzw = tangentWS;
				outputPackedVaryingsMeshToPS.interp03.xyzw = inputMesh.uv0;
				outputPackedVaryingsMeshToPS.interp04.xyzw = inputMesh.uv1;
				outputPackedVaryingsMeshToPS.interp05.xyzw = inputMesh.uv2;
				outputPackedVaryingsMeshToPS.interp06.xyzw = inputMesh.uv3;
				outputPackedVaryingsMeshToPS.interp07.xyzw = inputMesh.color;
				
				return outputPackedVaryingsMeshToPS;
			}

			void Frag(  PackedVaryingsMeshToPS packedInput
						#ifdef WRITE_NORMAL_BUFFER
						, out float4 outNormalBuffer : SV_Target0
							#ifdef WRITE_MSAA_DEPTH
						, out float1 depthColor : SV_Target1
							#endif
						#endif

						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						
					)
			{
				UNITY_SETUP_INSTANCE_ID( packedInput );

				float3 positionRWS  = packedInput.interp00.xyz;
				float3 normalWS = packedInput.interp01.xyz;
				float4 tangentWS = packedInput.interp02.xyzw;
				float4 texCoord0 = packedInput.interp03.xyzw;
				float4 texCoord1 = packedInput.interp04.xyzw;
				float4 texCoord2 = packedInput.interp05.xyzw;
				float4 texCoord3 = packedInput.interp06.xyzw;
				float4 vertexColor = packedInput.interp07.xyzw;
		
					
				FragInputs input;
				ZERO_INITIALIZE(FragInputs, input);
        
				input.worldToTangent = k_identity3x3;
				input.positionSS = packedInput.positionCS;
        
				input.positionRWS = positionRWS;
				input.worldToTangent = BuildWorldToTangent(tangentWS, normalWS);
				input.texCoord0 = texCoord0;
				input.texCoord1 = texCoord1;
				input.texCoord2 = texCoord2;
				input.texCoord3 = texCoord3;
				input.color = vertexColor;

				PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

				float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);

				SurfaceData surfaceData;
				BuiltinData builtinData;
				SmoothSurfaceDescription surfaceDescription = (SmoothSurfaceDescription)0;
				float2 uv_MainTex97 = packedInput.interp03.xy;
				float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
				float Alpha98 = tex2DNode97.a;
				
				surfaceDescription.Smoothness = _Smoothness;
				surfaceDescription.Alpha = Alpha98;

				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = _AlphaClip;
				#endif

				GetSurfaceAndBuiltinData(surfaceDescription, input, V, posInput, surfaceData, builtinData);

			#ifdef _DEPTHOFFSET_ON
				outputDepth = posInput.deviceDepth;
			#endif

			#ifdef WRITE_NORMAL_BUFFER
				EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);
				#ifdef WRITE_MSAA_DEPTH
				depthColor = packedInput.positionCS.z;
				#endif
			#endif
			}

            ENDHLSL
        }

		
		Pass
        {
			
            Name "Motion Vectors"
            Tags { "LightMode"="MotionVectors" }
			Stencil
			{
				Ref 128
				WriteMask 128
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

        
            HLSLPROGRAM
				#pragma vertex Vert
				#pragma fragment Frag

				#define ASE_SRP_VERSION 41000
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1

        
				//#define UNITY_MATERIAL_LIT
        
				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
				#define OUTPUT_SPLIT_LIGHTING
				#endif
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
                #define SHADERPASS SHADERPASS_VELOCITY
                #pragma multi_compile _ WRITE_NORMAL_BUFFER
                #pragma multi_compile _ WRITE_MSAA_DEPTH
        
                #define VARYINGS_NEED_POSITION_WS
        
			    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        		
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 ase_color : COLOR;
					float4 ase_texcoord : TEXCOORD0;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
        
				struct VaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float3 positionRWS;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif 
				};

				struct AttributesPass
				{
					float3 previousPositionOS : TEXCOORD4;
				};

				struct VaryingsPassToPS
				{
					float4 positionCS;
					float4 previousPositionCS;
				};

				#define VARYINGS_NEED_PASS
				struct VaryingsToPS
				{
					VaryingsMeshToPS vmesh;
					VaryingsPassToPS vpass;
				};

				struct PackedVaryingsToPS
				{
					float4 vmeshPositionCS : SV_Position;
					float3 vmeshInterp00 : TEXCOORD0; 
					float3 vpassInterpolators0 : TEXCOORD1;
					float3 vpassInterpolators1 : TEXCOORD2;
					float4 ase_texcoord3 : TEXCOORD3;
					#if INSTANCING_ON
					uint vmeshInstanceID : INSTANCEID_SEMANTIC; 
					#endif 
				};

				float _MaxWindStrength;
				float _WindStrength;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _MinHeight;
				float _HeightmapInfluence;
				float _MaxHeight;
				float _Smoothness;
				sampler2D _MainTex;
				float _AlphaClip;

				        
				void BuildSurfaceData(FragInputs fragInputs, inout SmoothSurfaceDescription surfaceDescription, float3 V, out SurfaceData surfaceData, out float3 bentNormalWS)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
        
					surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
                
					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
			#endif
			#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
			#endif
			#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
			#endif
        
			#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
			#endif
			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
			#endif
        
			#if defined (_MATERIAL_FEATURE_SPECULAR_COLOR) && defined (_ENERGY_CONSERVING_SPECULAR)
					surfaceData.baseColor *= (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b));
			#endif
        
					float3 normalTS = float3(0.0f, 0.0f, 1.0f);
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
					bentNormalWS = surfaceData.normalWS;
					surfaceData.geomNormalWS = fragInputs.worldToTangent[2];

			#ifdef _HAS_REFRACTION
					if (_EnableSSRefraction)
					{
        
						surfaceData.transmittanceMask = (1.0 - surfaceDescription.Alpha);
						surfaceDescription.Alpha = 1.0;
					}
					else
					{
						surfaceData.ior = 1.0;
						surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
						surfaceData.atDistance = 1.0;
						surfaceData.transmittanceMask = 0.0;
						surfaceDescription.Alpha = 1.0;
					}
			#else
					surfaceData.ior = 1.0;
					surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
					surfaceData.atDistance = 1.0;
					surfaceData.transmittanceMask = 0.0;
			#endif
        
					surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
			#if defined(_SPECULAR_OCCLUSION_CUSTOM)
			#elif defined(_SPECULAR_OCCLUSION_FROM_AO_BENT_NORMAL)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData.normalWS, surfaceData.ambientOcclusion, PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness));
			#elif defined(_AMBIENT_OCCLUSION) && defined(_SPECULAR_OCCLUSION_FROM_AO)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
			#else
					surfaceData.specularOcclusion = 1.0;
			#endif
			#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceData.perceptualSmoothness = GeometricNormalFiltering(surfaceData.perceptualSmoothness, fragInputs.worldToTangent[2], surfaceDescription.SpecularAAScreenSpaceVariance, surfaceDescription.SpecularAAThreshold);
			#endif

				}
        
				void GetSurfaceAndBuiltinData( SmoothSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{
			#ifdef LOD_FADE_CROSSFADE
					uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx));
					LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
			#endif
        
			#ifdef _ALPHATEST_ON
					DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
			#endif
					float3 bentNormalWS;
					BuildSurfaceData(fragInputs, surfaceDescription, V, surfaceData, bentNormalWS);
        
			#if HAVE_DECALS
					if (_EnableDecals)
					{
						DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
						ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
					}
			#endif
        
					InitBuiltinData(surfaceDescription.Alpha, bentNormalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
					builtinData.depthOffset = 0.0;
        
			#if (SHADERPASS == SHADERPASS_DISTORTION)
					builtinData.distortion = surfaceDescription.Distortion;
					builtinData.distortionBlur = surfaceDescription.DistortionBlur;
			#else
					builtinData.distortion = float2(0.0, 0.0);
					builtinData.distortionBlur = 0.0;
			#endif
        
					PostInitBuiltinData(V, posInput, surfaceData, builtinData);
				}
        
				VaryingsPassToPS UnpackVaryingsPassToPS(PackedVaryingsToPS input)
				{
					VaryingsPassToPS output;
					output.positionCS = float4(input.vpassInterpolators0.xy, 0.0, input.vpassInterpolators0.z);
					output.previousPositionCS = float4(input.vpassInterpolators1.xy, 0.0, input.vpassInterpolators1.z);

					return output;
				}

				float3 TransformPreviousObjectToWorldNormal(float3 normalOS)
				{
				#ifdef UNITY_ASSUME_UNIFORM_SCALING
					return normalize(mul((float3x3)unity_MatrixPreviousM, normalOS));
				#else
					return normalize(mul(normalOS, (float3x3)unity_MatrixPreviousMI));
				#endif
				}

				float3 TransformPreviousObjectToWorld(float3 positionOS)
				{
					float4x4 previousModelMatrix = ApplyCameraTranslationToMatrix(unity_MatrixPreviousM);
					return mul(previousModelMatrix, float4(positionOS, 1.0)).xyz;
				}

				void VelocityPositionZBias(VaryingsToPS input)
				{
				#if defined(UNITY_REVERSED_Z)
					input.vmesh.positionCS.z -= unity_MotionVectorsParams.z * input.vmesh.positionCS.w;
				#else
					input.vmesh.positionCS.z += unity_MotionVectorsParams.z * input.vmesh.positionCS.w;
				#endif
				}

				PackedVaryingsToPS Vert(AttributesMesh inputMesh,
										AttributesPass inputPass
										 )
				{
					PackedVaryingsToPS outputPackedVaryingsToPS;
					VaryingsToPS varyingsType;
					VaryingsMeshToPS outputVaryingsMeshToPS;

					UNITY_SETUP_INSTANCE_ID(inputMesh);
					UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputVaryingsMeshToPS);

					float WindStrength522 = _WindStrength;
					float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
					float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
					float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
					float3 break277 = WindVector91;
					float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
					float3 temp_cast_0 = (-1.0).xxx;
					float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
					float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 ) , float3( 0,0,0 ) , ( 1.0 - inputMesh.ase_color.r ));
					float3 Wind84 = lerpResult74;
					float3 temp_output_571_0 = (_ObstaclePosition).xyz;
					float3 normalizeResult184 = normalize( ( temp_output_571_0 - ase_worldPos ) );
					float temp_output_186_0 = ( _BendingStrength * 0.1 );
					float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
					float clampResult192 = clamp( ( distance( temp_output_571_0 , ase_worldPos ) / _BendingRadius ) , 0.0 , 1.0 );
					float3 Bending201 = ( inputMesh.ase_color.r * -( ( ( normalizeResult184 * appendResult468 ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
					float3 temp_output_203_0 = ( Wind84 + Bending201 );
					float3 lerpResult508 = lerp( temp_output_203_0 , ( temp_output_203_0 * 0 ) , 0);
					float3 break437 = lerpResult508;
					float temp_output_499_0 = ( 1.0 - inputMesh.ase_color.r );
					float lerpResult344 = lerp( _MinHeight , 0.0 , temp_output_499_0);
					float lerpResult388 = lerp( _MaxHeight , 0.0 , temp_output_499_0);
					float GrassLength365 = ( ( lerpResult344 * _HeightmapInfluence ) + lerpResult388 );
					float3 appendResult391 = (float3(break437.x , GrassLength365 , break437.z));
					float3 VertexOffset330 = appendResult391;
					
					outputPackedVaryingsToPS.ase_texcoord3.xy = inputMesh.ase_texcoord.xy;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsToPS.ase_texcoord3.zw = 0;
					float3 vertexValue = VertexOffset330;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
					#else
					inputMesh.positionOS.xyz += vertexValue;
					#endif 
					inputMesh.normalOS = float3(0,1,0);

					float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);

					outputVaryingsMeshToPS.positionRWS = positionRWS;
					outputVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
					
					varyingsType.vmesh = outputVaryingsMeshToPS;

					VelocityPositionZBias(varyingsType);
					varyingsType.vpass.positionCS = mul(_NonJitteredViewProjMatrix, float4(varyingsType.vmesh.positionRWS, 1.0));

					bool forceNoMotion = unity_MotionVectorsParams.y == 0.0;
					if (forceNoMotion)
					{
						varyingsType.vpass.previousPositionCS = float4(0.0, 0.0, 0.0, 1.0);
					}
					else
					{
						bool hasDeformation = unity_MotionVectorsParams.x > 0.0; // Skin or morph target
						float3 previousPositionRWS = TransformPreviousObjectToWorld(hasDeformation ? inputPass.previousPositionOS : inputMesh.positionOS);
						varyingsType.vpass.previousPositionCS = mul(_PrevViewProjMatrix, float4(previousPositionRWS, 1.0));
					}

					outputPackedVaryingsToPS.vmeshPositionCS = varyingsType.vmesh.positionCS;
					outputPackedVaryingsToPS.vmeshInterp00.xyz = varyingsType.vmesh.positionRWS;
					#if INSTANCING_ON
					outputPackedVaryingsToPS.vmeshInstanceID = varyingsType.vmeshInstanceID;
					#endif 
					
					outputPackedVaryingsToPS.vpassInterpolators0 = float3(varyingsType.vpass.positionCS.xyw);
					outputPackedVaryingsToPS.vpassInterpolators1 = float3(varyingsType.vpass.previousPositionCS.xyw);
					return outputPackedVaryingsToPS;
				}

				void Frag(  PackedVaryingsToPS packedInput
							, out float4 outVelocity : SV_Target0
							#ifdef WRITE_NORMAL_BUFFER
							, out float4 outNormalBuffer : SV_Target1
								#ifdef WRITE_MSAA_DEPTH
								, out float1 depthColor : SV_Target2
								#endif
							#endif

							#ifdef _DEPTHOFFSET_ON
							, out float outputDepth : SV_Depth
							#endif
							
						)
				{
					
					UNITY_SETUP_INSTANCE_ID( packedInput );
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
					input.worldToTangent = k_identity3x3;
					input.positionSS = packedInput.vmeshPositionCS; 
					input.positionRWS = packedInput.vmeshInterp00.xyz;
					
					PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

					float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);
				
					SurfaceData surfaceData;
					BuiltinData builtinData;
					
					SmoothSurfaceDescription surfaceDescription = (SmoothSurfaceDescription)0;
                    float2 uv_MainTex97 = packedInput.ase_texcoord3.xy;
                    float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
                    float Alpha98 = tex2DNode97.a;
                    
					surfaceDescription.Smoothness = _Smoothness;
					surfaceDescription.Alpha = Alpha98;
					
					#ifdef _ALPHATEST_ON
					surfaceDescription.AlphaClipThreshold = _AlphaClip;
                    #endif

					GetSurfaceAndBuiltinData(surfaceDescription, input, V, posInput, surfaceData, builtinData);

					VaryingsPassToPS inputPass = UnpackVaryingsPassToPS(packedInput);
				#ifdef _DEPTHOFFSET_ON
					inputPass.positionCS.w += builtinData.depthOffset;
					inputPass.previousPositionCS.w += builtinData.depthOffset;
				#endif

					float2 velocity = CalculateVelocity(inputPass.positionCS, inputPass.previousPositionCS);

					EncodeVelocity(velocity * 0.5, outVelocity);

					bool forceNoMotion = unity_MotionVectorsParams.y == 0.0;
					if (forceNoMotion)
						outVelocity = float4(0.0, 0.0, 0.0, 0.0);

				#ifdef WRITE_NORMAL_BUFFER
					EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);

					#ifdef WRITE_MSAA_DEPTH
					depthColor = packedInput.vmeshPositionCS.z;
					#endif
				#endif

				#ifdef _DEPTHOFFSET_ON
					outputDepth = posInput.deviceDepth;
				#endif
				}

            ENDHLSL
        }

		
		Pass
        {
			
            Name "Forward"
            Tags { "LightMode"="Forward" }
			Stencil
			{
				Ref 34
				WriteMask 39
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

        
            HLSLPROGRAM
                #define _DECALS 1
        
				#pragma vertex Vert
				#pragma fragment Frag
				
				#define ASE_SRP_VERSION 41000
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1
				#pragma shader_feature _VS_TOUCHBEND_ON

        
				//#define UNITY_MATERIAL_LIT
        
				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
				#define OUTPUT_SPLIT_LIGHTING
				#endif
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
                #define SHADERPASS SHADERPASS_FORWARD
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
                #define LIGHTLOOP_TILE_PASS
                #pragma multi_compile USE_FPTL_LIGHTLIST USE_CLUSTERED_LIGHTLIST
                #pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH
        
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TANGENT_TO_WORLD
                #define VARYINGS_NEED_TEXCOORD1
                #define VARYINGS_NEED_TEXCOORD2
        
        
			    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
        
				#define HAS_LIGHTLOOP
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
				int _ObjectId;
				int _PassValue;
        
				//float3x3 BuildWorldToTangent(float4 tangentWS, float3 normalWS)
				//{
				//	float3 unnormalizedNormalWS = normalWS;
				//	float renormFactor = 1.0 / length(unnormalizedNormalWS);
				//	float3x3 worldToTangent = CreateWorldToTangent(unnormalizedNormalWS, tangentWS.xyz, tangentWS.w > 0.0 ? 1.0 : -1.0);
				//	worldToTangent[0] = worldToTangent[0] * renormFactor;
				//	worldToTangent[1] = worldToTangent[1] * renormFactor;
				//	worldToTangent[2] = worldToTangent[2] * renormFactor;
				//	return worldToTangent;
				//}
        
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL; 
					float4 tangentOS : TANGENT; 
					float4 uv1 : TEXCOORD1;
					float4 uv2 : TEXCOORD2;
					float4 ase_color : COLOR;
					float4 ase_texcoord : TEXCOORD0;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
        
				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float3 interp00 : TEXCOORD0;
					float3 interp01 : TEXCOORD1;
					float4 interp02 : TEXCOORD2;
					float4 interp03 : TEXCOORD3;
					float4 interp04 : TEXCOORD4;
					float4 ase_color : COLOR;
					float4 ase_texcoord5 : TEXCOORD5;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif 
				};

				float _MaxWindStrength;
				float _WindStrength;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _MinHeight;
				float _HeightmapInfluence;
				float _MaxHeight;
				float4 _ColorTop;
				float4 _ColorBottom;
				sampler2D _MainTex;
				float _BendingTint;
				float _AmbientOcclusion;
				float _WindDebug;
				sampler2D _BumpMap;
				float _Smoothness;
				float _AlphaClip;
				float _Thickness;
				float _Diffusion;

				                  
				void BuildSurfaceData(FragInputs fragInputs, inout GlobalSurfaceDescription surfaceDescription, float3 V, out SurfaceData surfaceData, out float3 bentNormalWS)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
        
					surfaceData.baseColor =                 surfaceDescription.Albedo;
					surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
			#ifdef _SPECULAR_OCCLUSION_CUSTOM
					surfaceData.specularOcclusion =         surfaceDescription.SpecularOcclusion;
			#endif
					surfaceData.ambientOcclusion =          surfaceDescription.Occlusion;
					surfaceData.metallic =                  surfaceDescription.Metallic;
					surfaceData.coatMask =                  surfaceDescription.CoatMask;
			
			#ifdef _MATERIAL_FEATURE_IRIDESCENCE		
					surfaceData.iridescenceMask =           surfaceDescription.IridescenceMask;
					surfaceData.iridescenceThickness =      surfaceDescription.IridescenceThickness;
			#endif
					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
			#endif
			#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
			#endif
			#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
			#endif
			
			#ifdef ASE_LIT_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
			#endif
			
			#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
			#endif
			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.specularColor = surfaceDescription.Specular;
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
			#endif
        
			#if defined (_MATERIAL_FEATURE_SPECULAR_COLOR) && defined (_ENERGY_CONSERVING_SPECULAR)
					surfaceData.baseColor *= (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b));
			#endif
        
					float3 normalTS = float3(0.0f, 0.0f, 1.0f);
					normalTS = surfaceDescription.Normal;
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
        
					bentNormalWS = surfaceData.normalWS;
					surfaceData.geomNormalWS = fragInputs.worldToTangent[2];

			#ifdef ASE_BENT_NORMAL
					GetNormalWS(fragInputs, surfaceDescription.BentNormal, bentNormalWS,doubleSidedConstants);
			#endif
        
			#ifdef _HAS_REFRACTION
					if (_EnableSSRefraction)
					{
						surfaceData.ior =                       surfaceDescription.RefractionIndex;
						surfaceData.transmittanceColor =        surfaceDescription.RefractionColor;
						surfaceData.atDistance =                surfaceDescription.RefractionDistance;
        
						surfaceData.transmittanceMask = (1.0 - surfaceDescription.Alpha);
						surfaceDescription.Alpha = 1.0;
					}
					else
					{
						surfaceData.ior = 1.0;
						surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
						surfaceData.atDistance = 1.0;
						surfaceData.transmittanceMask = 0.0;
						surfaceDescription.Alpha = 1.0;
					}
			#else
					surfaceData.ior = 1.0;
					surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
					surfaceData.atDistance = 1.0;
					surfaceData.transmittanceMask = 0.0;
			#endif
        
			#if defined(_HAS_REFRACTION) || defined(_MATERIAL_FEATURE_TRANSMISSION)
					surfaceData.thickness =	                 surfaceDescription.Thickness;
			#endif

			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.subsurfaceMask =            surfaceDescription.SubsurfaceMask;
					surfaceData.diffusionProfile =          surfaceDescription.DiffusionProfile;
			#endif
					surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
			#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.anisotropy = surfaceDescription.Anisotropy;
					surfaceData.tangentWS = TransformTangentToWorld(surfaceDescription.Tangent, fragInputs.worldToTangent);
			#endif
					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
        
			#if defined(_SPECULAR_OCCLUSION_CUSTOM)
			#elif defined(_SPECULAR_OCCLUSION_FROM_AO_BENT_NORMAL)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData.normalWS, surfaceData.ambientOcclusion, PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness));
			#elif defined(_AMBIENT_OCCLUSION) && defined(_SPECULAR_OCCLUSION_FROM_AO)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
			#else
					surfaceData.specularOcclusion = 1.0;
			#endif
			#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceData.perceptualSmoothness = GeometricNormalFiltering(surfaceData.perceptualSmoothness, fragInputs.worldToTangent[2], surfaceDescription.SpecularAAScreenSpaceVariance, surfaceDescription.SpecularAAThreshold);
			#endif
        
				}
        
				void GetSurfaceAndBuiltinData(GlobalSurfaceDescription surfaceDescription,FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{
			#ifdef LOD_FADE_CROSSFADE
					uint3 fadeMaskSeed = asuint((int3)(V * _ScreenSize.xyx));
					LODDitheringTransition(fadeMaskSeed, unity_LODFade.x);
			#endif
        
			#ifdef _ALPHATEST_ON
						DoAlphaTest(surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold);
			#endif
        
					float3 bentNormalWS;
					BuildSurfaceData(fragInputs, surfaceDescription, V, surfaceData, bentNormalWS);
        
			#if HAVE_DECALS
					if (_EnableDecals)
					{
						DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
						ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
					}
			#endif
        
					InitBuiltinData(surfaceDescription.Alpha, bentNormalWS, -fragInputs.worldToTangent[2], fragInputs.positionRWS, fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
					builtinData.emissiveColor = surfaceDescription.Emission;
        
					builtinData.depthOffset = 0.0;
        
			#if (SHADERPASS == SHADERPASS_DISTORTION)
					builtinData.distortion = surfaceDescription.Distortion;
					builtinData.distortionBlur = surfaceDescription.DistortionBlur;
			#else
					builtinData.distortion = float2(0.0, 0.0);
					builtinData.distortionBlur = 0.0;
			#endif
        
					PostInitBuiltinData(V, posInput, surfaceData, builtinData);
				}
    
				PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh )
				{
				
					PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

					UNITY_SETUP_INSTANCE_ID(inputMesh);
					UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

					float WindStrength522 = _WindStrength;
					float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
					float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
					float3 WindVector91 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ), 0, 0.0) ), 1.0f );
					float3 break277 = WindVector91;
					float3 appendResult495 = (float3(break277.x , 0.0 , break277.y));
					float3 temp_cast_0 = (-1.0).xxx;
					float3 lerpResult249 = lerp( (float3( 0,0,0 ) + (appendResult495 - temp_cast_0) * (float3( 1,1,0 ) - float3( 0,0,0 )) / (float3( 1,1,0 ) - temp_cast_0)) , appendResult495 , _WindSwinging);
					float3 lerpResult74 = lerp( ( ( _MaxWindStrength * WindStrength522 ) * lerpResult249 ) , float3( 0,0,0 ) , ( 1.0 - inputMesh.ase_color.r ));
					float3 Wind84 = lerpResult74;
					float3 temp_output_571_0 = (_ObstaclePosition).xyz;
					float3 normalizeResult184 = normalize( ( temp_output_571_0 - ase_worldPos ) );
					float temp_output_186_0 = ( _BendingStrength * 0.1 );
					float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
					float clampResult192 = clamp( ( distance( temp_output_571_0 , ase_worldPos ) / _BendingRadius ) , 0.0 , 1.0 );
					float3 Bending201 = ( inputMesh.ase_color.r * -( ( ( normalizeResult184 * appendResult468 ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
					float3 temp_output_203_0 = ( Wind84 + Bending201 );
					float3 lerpResult508 = lerp( temp_output_203_0 , ( temp_output_203_0 * 0 ) , 0);
					float3 break437 = lerpResult508;
					float temp_output_499_0 = ( 1.0 - inputMesh.ase_color.r );
					float lerpResult344 = lerp( _MinHeight , 0.0 , temp_output_499_0);
					float lerpResult388 = lerp( _MaxHeight , 0.0 , temp_output_499_0);
					float GrassLength365 = ( ( lerpResult344 * _HeightmapInfluence ) + lerpResult388 );
					float3 appendResult391 = (float3(break437.x , GrassLength365 , break437.z));
					float3 VertexOffset330 = appendResult391;
					
					outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
					outputPackedVaryingsMeshToPS.ase_texcoord5.xy = inputMesh.ase_texcoord.xy;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord5.zw = 0;
					float3 vertexValue = VertexOffset330;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
					#else
					inputMesh.positionOS.xyz += vertexValue;
					#endif
					inputMesh.normalOS = float3(0,1,0);

					float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
					float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
					float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

					outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
					outputPackedVaryingsMeshToPS.interp00.xyz = positionRWS;
					outputPackedVaryingsMeshToPS.interp01.xyz = normalWS;
					outputPackedVaryingsMeshToPS.interp02.xyzw = tangentWS;
					outputPackedVaryingsMeshToPS.interp03.xyzw = inputMesh.uv1;
					outputPackedVaryingsMeshToPS.interp04.xyzw = inputMesh.uv2;
				
					return outputPackedVaryingsMeshToPS;
				}

				void Frag(PackedVaryingsMeshToPS packedInput,
						#ifdef OUTPUT_SPLIT_LIGHTING
							out float4 outColor : SV_Target0,
							out float4 outDiffuseLighting : SV_Target1,
							OUTPUT_SSSBUFFER(outSSSBuffer)
						#else
							out float4 outColor : SV_Target0
						#endif
						#ifdef _DEPTHOFFSET_ON
							, out float outputDepth : SV_Depth
						#endif
						
						  )
				{
					UNITY_SETUP_INSTANCE_ID( packedInput );
					float3 positionRWS = packedInput.interp00.xyz;
					float3 normalWS = packedInput.interp01.xyz;
					float4 tangentWS = packedInput.interp02.xyzw;
				
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
					input.worldToTangent = k_identity3x3;
					input.positionSS = packedInput.positionCS;
					input.positionRWS = positionRWS;
					input.worldToTangent = BuildWorldToTangent(tangentWS, normalWS);
					input.texCoord1 = packedInput.interp03.xyzw;
					input.texCoord2 = packedInput.interp04.xyzw;
                
					uint2 tileIndex = uint2(input.positionSS.xy) / GetTileSize ();
				#if defined(UNITY_SINGLE_PASS_STEREO)
					tileIndex.x -= unity_StereoEyeIndex * _NumTileClusteredX;
				#endif
					PositionInputs posInput = GetPositionInput_Stereo(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, tileIndex , unity_StereoEyeIndex);

					float3 normalizedWorldViewDir = GetWorldSpaceNormalizeViewDir(input.positionRWS);
			
					SurfaceData surfaceData;
					BuiltinData builtinData;
					GlobalSurfaceDescription surfaceDescription = (GlobalSurfaceDescription)0;
					float4 lerpResult363 = lerp( _ColorTop , _ColorBottom , ( 1.0 - packedInput.ase_color.r ));
					float2 uv_MainTex97 = packedInput.ase_texcoord5.xy;
					float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
					float4 BaseColor551 = ( lerpResult363 * tex2DNode97 );
					float4 Color161 = BaseColor551;
					#ifdef _VS_TOUCHBEND_ON
					float staticSwitch659 = (float3( 0,0,0 )).y;
					#else
					float staticSwitch659 = 0.0;
					#endif
					float TouchBendPos613 = staticSwitch659;
					float4 temp_cast_0 = (( TouchBendPos613 * _BendingTint )).xxxx;
					float clampResult302 = clamp( ( ( packedInput.ase_color.r * 1.33 ) * _AmbientOcclusion ) , 0.0 , 1.0 );
					float lerpResult115 = lerp( 1.0 , clampResult302 , _AmbientOcclusion);
					float AmbientOcclusion207 = lerpResult115;
					float4 FinalColor205 = ( ( Color161 - temp_cast_0 ) * AmbientOcclusion207 );
					float3 ase_worldPos = GetAbsolutePositionWS( positionRWS );
					float2 appendResult469 = (float2(_WindDirection.x , _WindDirection.z));
					float3 WindVector91 = UnpackNormalmapRGorAG( tex2D( _WindVectors, ( ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) + ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * appendResult469 ) ) ), 1.0f );
					float4 lerpResult310 = lerp( FinalColor205 , float4( WindVector91 , 0.0 ) , _WindDebug);
					
					float2 uv_BumpMap172 = packedInput.ase_texcoord5.xy;
					float3 Normals174 = UnpackNormalmapRGorAG( tex2D( _BumpMap, uv_BumpMap172 ), 1.0 );
					
					float Alpha98 = tex2DNode97.a;
					
					surfaceDescription.Albedo = lerpResult310.rgb;
					surfaceDescription.Normal = Normals174;
					surfaceDescription.BentNormal = float3( 0, 0, 1 );
					surfaceDescription.CoatMask = 0;
					surfaceDescription.Metallic = 0;
					
					#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceDescription.Specular = 0;
					#endif
					
					surfaceDescription.Emission = 0;
					surfaceDescription.Smoothness = _Smoothness;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Alpha = Alpha98;
					
					#ifdef _ALPHATEST_ON
					surfaceDescription.AlphaClipThreshold = _AlphaClip;
					#endif

					#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceDescription.SpecularAAScreenSpaceVariance = 0;
					surfaceDescription.SpecularAAThreshold = 0;
					#endif

					#ifdef _SPECULAR_OCCLUSION_CUSTOM
					surfaceDescription.SpecularOcclusion = 0;
					#endif

					#if defined(_HAS_REFRACTION) || defined(_MATERIAL_FEATURE_TRANSMISSION)
					surfaceDescription.Thickness = _Thickness;
					#endif

					#ifdef _HAS_REFRACTION
					surfaceDescription.RefractionIndex = 1;
					surfaceDescription.RefractionColor = float3(1,1,1);
					surfaceDescription.RefractionDistance = 0;
					#endif

					#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceDescription.SubsurfaceMask = 1;
					surfaceDescription.DiffusionProfile = _Diffusion;
					#endif

					#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceDescription.Anisotropy = 1;
					surfaceDescription.Tangent = float3(1,0,0);
					#endif

					#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceDescription.IridescenceMask = 0;
					surfaceDescription.IridescenceThickness = 0;
					#endif

					GetSurfaceAndBuiltinData(surfaceDescription,input, normalizedWorldViewDir, posInput, surfaceData, builtinData);

					BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);

					PreLightData preLightData = GetPreLightData(normalizedWorldViewDir, posInput, bsdfData);

					outColor = float4(0.0, 0.0, 0.0, 0.0);

					{
				#ifdef _SURFACE_TYPE_TRANSPARENT
						uint featureFlags = LIGHT_FEATURE_MASK_FLAGS_TRANSPARENT;
				#else
						uint featureFlags = LIGHT_FEATURE_MASK_FLAGS_OPAQUE;
				#endif
						float3 diffuseLighting;
						float3 specularLighting;

						LightLoop(normalizedWorldViewDir, posInput, preLightData, bsdfData, builtinData, featureFlags, diffuseLighting, specularLighting);

				#ifdef OUTPUT_SPLIT_LIGHTING
						if (_EnableSubsurfaceScattering != 0 && ShouldOutputSplitLighting(bsdfData))
						{
							outColor = float4(specularLighting, 1.0);
							outDiffuseLighting = float4(TagLightingForSSS(diffuseLighting), 1.0);
						}
						else
						{
							outColor = float4(diffuseLighting + specularLighting, 1.0);
							outDiffuseLighting = 0;
						}
						ENCODE_INTO_SSSBUFFER(surfaceData, posInput.positionSS, outSSSBuffer);
				#else
						outColor = ApplyBlendMode(diffuseLighting, specularLighting, builtinData.opacity);
						outColor = EvaluateAtmosphericScattering(posInput, normalizedWorldViewDir, outColor);
				#endif
					}

				#ifdef _DEPTHOFFSET_ON
					outputDepth = posInput.deviceDepth;
				#endif
				}

            ENDHLSL
        }
		
    }
    CustomEditor "ASEMaterialInspector"   
	
	
}
/*ASEBEGIN
Version=16301
455.2;267.2;721;767;-3727.81;-1039.75;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;368;-4626.298,-1189.271;Float;False;2299.111;956.0105;Comment;18;91;410;222;298;221;72;297;79;520;469;75;308;384;69;67;77;319;383;Wind vectors;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;77;-4482.71,-1063.982;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;319;-4571.499,-844.1255;Float;False;Global;_WindSpeed;_WindSpeed;11;0;Create;True;0;0;False;0;0.5;0.24;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;383;-4473.01,-744.6186;Float;False;Constant;_Float7;Float 7;19;0;Create;True;0;0;False;0;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;308;-4253.298,-447.8275;Float;False;Global;_WindDirection;_WindDirection;13;0;Create;True;0;0;False;0;1,0,0,0;0,0,-1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;75;-4256.11,-1063.99;Float;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TimeNode;69;-4267.893,-645.5446;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-4142.394,-791.1456;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;384;-4261.245,-952.3274;Float;False;Constant;_Float8;Float 8;19;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-3930.196,-690.6456;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-4054.306,-1068.048;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;469;-3949.837,-411.0562;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;297;-3930.545,-974.5492;Float;False;Property;_WindAmplitudeMultiplier;WindAmplitudeMultiplier;9;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;520;-3931.458,-888.7498;Float;False;Global;_WindAmplitude;_WindAmplitude;20;0;Create;True;0;0;False;0;1;14;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;-3689.792,-564.3065;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;202;-2142.645,-2259.974;Float;False;2627.3;775.1997;Bending;23;181;183;186;188;184;194;189;191;192;193;195;196;197;200;198;201;231;232;234;386;387;468;571;Foliage bending away from obstacle;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-3587.035,-1024.596;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;231;-2095.184,-2104.723;Float;False;Global;_ObstaclePosition;_ObstaclePosition;18;1;[HideInInspector];Create;True;0;0;False;0;0,0,0,0;1.34,-0.4799998,14.72,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;222;-3383.589,-914.0057;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;571;-1848.695,-2077.154;Float;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;410;-3145.582,-934.1251;Float;True;Global;_WindVectors;_WindVectors;6;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;6c795dd1d1d319e479e68164001557e8;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;181;-2078.544,-1822.477;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;234;-1698.183,-1884.723;Float;False;Global;_BendingStrength;_BendingStrength;15;1;[HideInInspector];Create;True;0;0;False;0;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-2809.208,-931.3988;Float;False;WindVector;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;386;-1679.209,-1805.235;Float;False;Constant;_Float10;Float 10;19;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-1716.183,-1588.722;Float;False;Global;_BendingRadius;_BendingRadius;14;1;[HideInInspector];Create;True;0;0;False;0;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;369;-2173.667,-1224.785;Float;False;2670.73;665.021;Comment;16;277;248;16;247;83;249;66;70;74;84;385;408;495;500;521;522;Wind animations;1,1,1,1;0;0
Node;AmplifyShaderEditor.DistanceOpNode;189;-1673.746,-1722.773;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;191;-1459.945,-1676.773;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;521;-2113.14,-973.3709;Float;False;91;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;183;-1662.445,-2071.378;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;387;-1437.41,-1569.935;Float;False;Constant;_Float11;Float 11;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-1470.544,-1875.676;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;468;-1264.144,-1894.772;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;192;-1288.945,-1676.773;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;277;-1874.768,-977.4964;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NormalizeNode;184;-1384.548,-2072.176;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;193;-1044.945,-1674.773;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-1024.545,-2065.675;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-1102.412,-1079.697;Float;False;Global;_WindStrength;_WindStrength;19;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;408;-1488.413,-837.2699;Float;False;Constant;_Float14;Float 14;20;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;495;-1579.352,-980.8199;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-1124.974,-745.7667;Float;False;Property;_WindSwinging;WindSwinging;8;0;Create;True;0;0;False;0;0.25;0.394;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;371;-2159.553,-389.6831;Float;False;1807.377;845.9116;Comment;9;551;549;293;363;97;501;292;362;364;Base color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-786.7443,-1906.174;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;522;-875.6971,-1086.247;Float;False;WindStrength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;247;-1262.914,-943.2866;Float;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,1,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-714.9434,-1777.574;Float;False;Property;_BendingInfluence;BendingInfluence;13;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1152.243,-1165.787;Float;False;Property;_MaxWindStrength;Max Wind Strength;7;0;Create;True;0;0;False;0;0.126967;0.301;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;364;-2104.4,156.0724;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;83;-521.2678,-946.241;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;-398.1443,-1904.475;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;249;-798.6658,-999.0773;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-520.265,-1143.746;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;159;-2143.86,2840.496;Float;False;1813.59;398.8397;AO;11;207;115;114;117;301;118;113;111;302;381;382;Ambient Occlusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-252.8295,-1087.164;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;382;-1814.028,3002.569;Float;False;Constant;_Float6;Float 6;19;0;Create;True;0;0;False;0;1.33;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;197;-216.6443,-1902.474;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;292;-2109.553,-339.6831;Float;False;Property;_ColorTop;ColorTop;0;0;Create;True;0;0;False;0;0.3001064,0.6838235,0,1;0.3158575,0.6102941,0.02692473,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;111;-2093.859,2890.496;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;500;-274.7222,-946.4897;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;198;-252.5788,-2130.417;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;362;-2105.6,-131.9273;Float;False;Property;_ColorBottom;Color Bottom;1;0;Create;True;0;0;False;0;0.232,0.5,0,1;0.2549249,0.5147058,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;501;-1906.319,177.3479;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-2025.64,3098.476;Float;False;Property;_AmbientOcclusion;AmbientOcclusion;5;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;74;-6.421254,-1078.501;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;97;-1599.225,-27.15059;Float;True;Property;_MainTex;MainTex;2;1;[NoScaleOffset];Create;True;0;0;False;0;None;e3a9522ecae56444b9d4e7a0eb9d6e78;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;665;-4226.258,-2789.499;Float;False;FLOAT;1;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;7.856029,-2045.574;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;301;-1574.174,2911.218;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;660;-4245.799,-2886.684;Float;False;Constant;_Float9;Float 9;22;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;343;-4345.815,-1858.752;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;363;-1669.001,-181.4273;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-1371.343,2935.675;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;241.656,-2050.775;Float;False;Bending;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;659;-4002.933,-2818.131;Float;False;Property;_VS_TOUCHBEND;VS_TOUCHBEND;15;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-1266.153,-190.7834;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;247.4628,-1074.753;Float;False;Wind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;381;-1349.626,3147.969;Float;False;Constant;_Float5;Float 5;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;499;-4112.737,-1845.776;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;374;1831.836,-489.6089;Float;False;2217.195;546.4841;Comment;11;204;85;203;330;508;456;529;426;366;437;391;Vertex function layer blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;392;-3990.975,-2051.045;Float;False;Property;_MinHeight;MinHeight;11;0;Create;True;0;0;False;0;-0.5;-0.832;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;118;-1256.54,3116.476;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;302;-1138.474,2918.418;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;361;-3435.164,-1966.095;Float;False;Property;_HeightmapInfluence;HeightmapInfluence;10;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-4001.294,-1946.098;Float;False;Property;_MaxHeight;MaxHeight;12;0;Create;True;0;0;False;0;0;0.42;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;1947.242,-316.3543;Float;False;201;Bending;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;613;-3725.462,-2817.573;Float;False;TouchBendPos;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;551;-916.9384,-188.8136;Float;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;344;-3375.759,-2129.614;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;236;1488.743,-1237.9;Float;False;3425.277;437.2272;;9;205;519;208;534;532;531;161;542;524;Final color;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;117;-1218.442,3055.776;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;1935.874,-422.8134;Float;False;84;Wind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;388;-3237.73,-1833.117;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;524;1689.672,-1134.667;Float;False;551;BaseColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;115;-856.2404,2935.676;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;456;2089.852,-134.6054;Float;False;-1;;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;531;3035.332,-1052.988;Float;False;613;TouchBendPos;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;532;2972.651,-977.2318;Float;False;Property;_BendingTint;BendingTint;14;0;Create;True;0;0;False;0;-0.05;-0.051;-0.1;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;360;-3095.494,-2113.002;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;203;2298.659,-410.8396;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;426;2488.814,-319.9986;Float;False;219;183;Mask wind/bending by height;1;420;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;-636.6566,2929.231;Float;False;AmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;2145.16,-1162.154;Float;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;534;3485.771,-1019.796;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;2540.814,-269.9979;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;389;-2854.729,-2117.818;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;529;2456.923,-94.14083;Float;False;-1;;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;508;2935.445,-394.5296;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;542;3706.971,-1153.228;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;365;-2607.386,-2127.475;Float;False;GrassLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;237;-2119.915,3380.083;Float;False;978.701;287.5597;;3;174;172;419;Normal map;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;4239.477,-1030.722;Float;False;207;AmbientOcclusion;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-2007.296,3508.627;Float;False;Constant;_Float18;Float 18;21;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;366;3380.36,-243.9879;Float;False;365;GrassLength;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;437;3225.992,-389.9932;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;519;4481.406,-1148.504;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;235;2843.666,889.9761;Float;False;452.9371;811.1447;Final;4;99;175;206;331;Outputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;4658.84,-1159.965;Float;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;375;2964.505,1790.556;Float;False;352;249.0994;Comment;1;311;Debug switch;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;172;-1768.914,3434.642;Float;True;Property;_BumpMap;BumpMap;3;2;[NoScaleOffset];[Normal];Create;True;0;0;True;0;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;391;3551.427,-385.0264;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-997.71,1109.093;Float;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-1384.214,3430.082;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;330;3743.457,-384.6883;Float;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;373;-2151.307,1610.689;Float;False;1792.004;391.326;Comment;10;523;514;274;101;511;239;86;240;93;525;Color through wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;312;2977.959,1720.188;Float;False;91;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;494;-4616.219,-36.44699;Float;False;1616.341;554.3467;Comment;11;324;491;489;490;484;487;485;486;488;483;493;TerrainUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;3072.166,941.4243;Float;False;205;FinalColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;311;3014.505,1924.656;Float;False;Global;_WindDebug;_WindDebug;20;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;-3747.159,276.6454;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;310;3589.109,973.5546;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;3096.573,1235.245;Float;False;98;Alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;487;-4013.361,345.0453;Float;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;3082.283,1039.971;Float;False;174;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;687;3842.16,1305.152;Float;False;Property;_AlphaClip;AlphaClip;16;0;Create;True;0;0;False;0;0.5;0.67;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;578;-3687.778,-1996.696;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;689;4090.81,1573.25;Float;False;Property;_Thickness;Thickness;17;0;Create;True;0;0;False;0;0;0.159;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;86;-1620.504,1798.089;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;485;-4238.418,217.5534;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;483;-4236.418,14.55324;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;664;-4853.995,-2785.871;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;490;-3739.417,30.55324;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;514;-797.2388,1667.527;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;493;-4566.219,98.85242;Float;False;Global;_TerrainUV;_TerrainUV;2;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;688;4071.784,1427.905;Float;False;Property;_Diffusion;Diffusion;18;0;Create;True;0;0;False;0;5;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;577;-3500.577,-1735.096;Float;False;GrassMinMaxHeight;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2101.308,1660.688;Float;False;91;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;324;-3331.81,149.9584;Float;False;TerrainUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;451;3614.484,1439.282;Float;False;Constant;_UpNormalVector;UpNormalVector;21;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;313;3675.083,1200.303;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;491;-3506.654,157.7434;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;525;-1320.113,1918.377;Float;False;522;WindStrength;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;484;-4261.365,342.0453;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;488;-4052.417,13.55305;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-967.168,1664.503;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;486;-4015.417,165.5533;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;3064.599,1369.667;Float;False;330;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;511;-1369.941,1663.164;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;549;-1803.634,-324.2867;Float;False;TopColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;240;-1853.897,1663.845;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;690;4187.81,1288.25;Float;False;Property;_Smoothness;Smoothness;19;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;-1576.098,1662.443;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;523;-601.9745,1656.407;Float;False;WindTint;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;406;3424.385,1441.343;Float;False;Constant;_Float12;Float 12;20;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-1383.694,1796.119;Float;False;Property;_ColorVariation;ColorVariation;4;0;Create;True;0;0;False;0;0.05;0;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;681;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;5;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;SceneSelectionPass;0;3;SceneSelectionPass;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;682;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;5;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;DepthOnly;0;4;DepthOnly;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;684;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;5;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;Distortion;0;6;Distortion;2;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;True;4;1;False;-1;1;False;-1;4;1;False;-1;1;False;-1;True;1;False;-1;5;False;-1;False;False;False;False;False;True;3;False;-1;False;True;1;LightMode=DistortionVectors;False;0;;0;0;Standard;0;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;683;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;5;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;Motion Vectors;0;5;Motion Vectors;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;128;False;-1;255;False;-1;128;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=MotionVectors;False;0;;0;0;Standard;0;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;679;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;5;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;META;0;1;META;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;26;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;18;FLOAT3;0,0,0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT;0;False;23;FLOAT3;0,0,0;False;24;FLOAT;0;False;25;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;686;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;5;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;Forward;0;8;Forward;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;34;False;-1;255;False;-1;39;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=Forward;False;0;;0;0;Standard;0;26;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;18;FLOAT3;0,0,0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT;0;False;23;FLOAT3;0,0,0;False;24;FLOAT;0;False;25;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;685;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;5;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;TransparentBackface;0;7;TransparentBackface;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;True;1;False;-1;False;False;False;False;False;True;1;LightMode=TransparentBackface;False;0;;0;0;Standard;0;13;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;680;4279.866,1027.348;Float;False;False;2;Float;ASEMaterialInspector;0;5;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;ShadowCaster;0;2;ShadowCaster;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;678;4503.686,1178.243;Float;False;True;2;Float;ASEMaterialInspector;0;5;FAE/Grass;091c43ba8bd92c9459798d59b089ce4e;True;GBuffer;0;0;GBuffer;26;True;0;1;False;-1;1;False;-1;0;5;False;-1;10;False;-1;False;False;True;2;False;-1;False;False;True;1;False;-1;True;0;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;34;False;-1;255;False;-1;39;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=GBuffer;False;0;;0;0;Standard;18;Material Type,InvertActionOnDeselection;5;Energy Conserving Specular,InvertActionOnDeselection;0;Transmission,InvertActionOnDeselection;0;Surface Type;0;Receive Decals;1;Alpha Cutoff;1;Receives SSR;0;Specular AA;0;Specular Occlusion Mode;0;Distortion;0;Distortion Mode;0;Distortion Depth Test;0;Back Then Front Rendering;0;Blend Preserves Specular;1;Fog;1;Draw Before Refraction;0;Refraction Model;0;Vertex Position,InvertActionOnDeselection;1;0;9;True;True;True;True;True;True;False;False;True;False;26;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;18;FLOAT3;0,0,0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT;0;False;23;FLOAT3;0,0,0;False;24;FLOAT;0;False;25;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;566;2867.522,531.4199;Float;False;339.8231;101.9985;Copyright Staggart Creations;0;FAE Grass Shader;1,1,1,1;0;0
WireConnection;75;0;77;0
WireConnection;67;0;319;0
WireConnection;67;1;383;0
WireConnection;79;0;67;0
WireConnection;79;1;69;4
WireConnection;72;0;75;0
WireConnection;72;1;384;0
WireConnection;469;0;308;1
WireConnection;469;1;308;3
WireConnection;221;0;79;0
WireConnection;221;1;469;0
WireConnection;298;0;72;0
WireConnection;298;1;297;0
WireConnection;298;2;520;0
WireConnection;222;0;298;0
WireConnection;222;1;221;0
WireConnection;571;0;231;0
WireConnection;410;1;222;0
WireConnection;91;0;410;0
WireConnection;189;0;571;0
WireConnection;189;1;181;0
WireConnection;191;0;189;0
WireConnection;191;1;232;0
WireConnection;183;0;571;0
WireConnection;183;1;181;0
WireConnection;186;0;234;0
WireConnection;186;1;386;0
WireConnection;468;0;186;0
WireConnection;468;2;186;0
WireConnection;192;0;191;0
WireConnection;192;2;387;0
WireConnection;277;0;521;0
WireConnection;184;0;183;0
WireConnection;193;0;192;0
WireConnection;188;0;184;0
WireConnection;188;1;468;0
WireConnection;495;0;277;0
WireConnection;495;2;277;1
WireConnection;194;0;188;0
WireConnection;194;1;193;0
WireConnection;522;0;385;0
WireConnection;247;0;495;0
WireConnection;247;1;408;0
WireConnection;196;0;194;0
WireConnection;196;1;195;0
WireConnection;249;0;247;0
WireConnection;249;1;495;0
WireConnection;249;2;248;0
WireConnection;66;0;16;0
WireConnection;66;1;522;0
WireConnection;70;0;66;0
WireConnection;70;1;249;0
WireConnection;197;0;196;0
WireConnection;500;0;83;1
WireConnection;501;0;364;1
WireConnection;74;0;70;0
WireConnection;74;2;500;0
WireConnection;200;0;198;1
WireConnection;200;1;197;0
WireConnection;301;0;111;1
WireConnection;301;1;382;0
WireConnection;363;0;292;0
WireConnection;363;1;362;0
WireConnection;363;2;501;0
WireConnection;114;0;301;0
WireConnection;114;1;113;0
WireConnection;201;0;200;0
WireConnection;659;1;660;0
WireConnection;659;0;665;0
WireConnection;293;0;363;0
WireConnection;293;1;97;0
WireConnection;84;0;74;0
WireConnection;499;0;343;1
WireConnection;118;0;113;0
WireConnection;302;0;114;0
WireConnection;302;2;381;0
WireConnection;613;0;659;0
WireConnection;551;0;293;0
WireConnection;344;0;392;0
WireConnection;344;2;499;0
WireConnection;117;0;118;0
WireConnection;388;0;71;0
WireConnection;388;2;499;0
WireConnection;115;0;381;0
WireConnection;115;1;302;0
WireConnection;115;2;117;0
WireConnection;360;0;344;0
WireConnection;360;1;361;0
WireConnection;203;0;85;0
WireConnection;203;1;204;0
WireConnection;207;0;115;0
WireConnection;161;0;524;0
WireConnection;534;0;531;0
WireConnection;534;1;532;0
WireConnection;420;0;203;0
WireConnection;420;1;456;0
WireConnection;389;0;360;0
WireConnection;389;1;388;0
WireConnection;508;0;203;0
WireConnection;508;1;420;0
WireConnection;508;2;529;0
WireConnection;542;0;161;0
WireConnection;542;1;534;0
WireConnection;365;0;389;0
WireConnection;437;0;508;0
WireConnection;519;0;542;0
WireConnection;519;1;208;0
WireConnection;205;0;519;0
WireConnection;172;5;419;0
WireConnection;391;0;437;0
WireConnection;391;1;366;0
WireConnection;391;2;437;2
WireConnection;98;0;97;4
WireConnection;174;0;172;0
WireConnection;330;0;391;0
WireConnection;489;0;486;0
WireConnection;489;1;487;0
WireConnection;310;0;206;0
WireConnection;310;1;312;0
WireConnection;310;2;311;0
WireConnection;487;0;484;0
WireConnection;578;0;392;0
WireConnection;578;1;71;0
WireConnection;485;0;493;1
WireConnection;485;1;493;1
WireConnection;483;0;493;3
WireConnection;483;1;493;4
WireConnection;490;0;488;0
WireConnection;490;1;493;1
WireConnection;514;0;274;0
WireConnection;577;0;578;0
WireConnection;324;0;491;0
WireConnection;313;0;99;0
WireConnection;313;1;406;0
WireConnection;313;2;311;0
WireConnection;491;0;490;0
WireConnection;491;1;489;0
WireConnection;488;0;483;0
WireConnection;274;0;511;0
WireConnection;274;1;101;0
WireConnection;274;2;525;0
WireConnection;486;0;493;1
WireConnection;486;1;485;0
WireConnection;511;0;239;0
WireConnection;511;1;86;1
WireConnection;549;0;292;0
WireConnection;240;0;93;0
WireConnection;239;0;240;0
WireConnection;239;1;240;1
WireConnection;523;0;514;0
WireConnection;678;0;310;0
WireConnection;678;1;175;0
WireConnection;678;7;690;0
WireConnection;678;9;99;0
WireConnection;678;10;687;0
WireConnection;678;16;689;0
WireConnection;678;21;688;0
WireConnection;678;11;331;0
WireConnection;678;12;451;0
ASEEND*/
//CHKSM=B7B9AD1E3B077B47E810EE510525BAE127AE16FD