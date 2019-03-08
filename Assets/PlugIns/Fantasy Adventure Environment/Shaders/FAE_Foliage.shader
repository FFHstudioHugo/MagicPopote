// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FAE/Foliage"
{
    Properties
    {
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset][Normal]_BumpMap("BumpMap", 2D) = "bump" {}
		_WindTint("WindTint", Range( -0.5 , 0.5)) = 0.1
		_AmbientOcclusion("AmbientOcclusion", Range( 0 , 1)) = 0
		_TransmissionSize("Transmission Size", Range( 0 , 20)) = 1
		_TransmissionAmount("Transmission Amount", Range( 0 , 10)) = 2.696819
		_WindSwinging("WindSwinging", Range( 0 , 1)) = 0
		_BendingInfluence("BendingInfluence", Range( 0 , 1)) = 0
		_FlatLighting("FlatLighting", Range( 0 , 1)) = 0
		_WindAmplitudeMultiplier("WindAmplitudeMultiplier", Float) = 10
		_MaxWindStrength("Max Wind Strength", Range( 0 , 1)) = 0.126967
		_GlobalWindMotion("GlobalWindMotion", Range( 0 , 1)) = 1
		_LeafFlutter("LeafFlutter", Range( 0 , 1)) = 0.495
		_Thickness("Thickness", Range( 0 , 1)) = 0
		_Int0("Int 0", Int) = 1
		_AlphaCutoff("AlphaCutoff", Range( 0 , 1)) = 0.5
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
    }

    SubShader
    {        
		

		Tags { "RenderPipeline"="HDRenderPipeline" "RenderType"="TransparentCutout" "Queue"="Geometry" }

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
        
				#define ASE_SRP_VERSION 40900
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _SPECULAR_OCCLUSION_FROM_AO 1
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
					float4 ase_texcoord5 : TEXCOORD5;
					float4 ase_color : COLOR;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				float _GlobalWindMotion;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float _LeafFlutter;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _MaxWindStrength;
				float _WindStrength;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _FlatLighting;
				sampler2D _MainTex;
				float _WindTint;
				float _TransmissionSize;
				float _TransmissionAmount;
				float _WindDebug;
				sampler2D _BumpMap;
				float _Smoothness;
				float _AmbientOcclusion;
				float _AlphaCutoff;
				float _Thickness;
				int _Int0;

				    
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

				float temp_output_514_0 = ( _WindSpeed * _Time.w );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
				float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
				float3 temp_cast_1 = (-1.0).xxx;
				float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_1) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_1)) , temp_output_524_0 , _WindSwinging);
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float3 WindVector577 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ), 0, 0.0) ), 1.0f );
				float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
				float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
				float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * inputMesh.ase_color.r * _WindStrength );
				float4 normalizeResult184 = normalize( ( _ObstaclePosition - float4( ase_worldPos , 0.0 ) ) );
				float temp_output_186_0 = ( _BendingStrength * 0.1 );
				float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
				float clampResult192 = clamp( ( distance( _ObstaclePosition , float4( ase_worldPos , 0.0 ) ) / _BendingRadius ) , 0.0 , 1.0 );
				float4 Bending201 = ( inputMesh.ase_color.r * -( ( ( normalizeResult184 * float4( appendResult468 , 0.0 ) ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
				float4 VertexOffset330 = ( float4( GlobalWind84 , 0.0 ) + Bending201 );
				
				float3 lerpResult552 = lerp( inputMesh.normalOS , float3(0,1,0) , _FlatLighting);
				
				outputPackedVaryingsMeshToPS.ase_texcoord5.xy = inputMesh.ase_texcoord.xy;
				outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord5.zw = 0;
				float3 vertexValue = VertexOffset330.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS = lerpResult552;

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
				float2 uv_MainTex97 = packedInput.ase_texcoord5.xy;
				float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
				float4 temp_cast_0 = (2.0).xxxx;
				float temp_output_514_0 = ( _WindSpeed * _Time.w );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
				float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
				float3 temp_cast_2 = (-1.0).xxx;
				float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_2) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_2)) , temp_output_524_0 , _WindSwinging);
				float3 ase_worldPos = GetAbsolutePositionWS( positionRWS );
				float3 WindVector577 = UnpackNormalmapRGorAG( tex2D( _WindVectors, ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ) ), 1.0f );
				float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
				float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
				float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * packedInput.ase_color.r * _WindStrength );
				float lerpResult271 = lerp( (GlobalWind84).x , 0.0 , ( 1.0 - packedInput.ase_color.r ));
				float WindTint548 = ( ( lerpResult271 * _WindTint ) * 2.0 );
				float4 lerpResult273 = lerp( tex2DNode97 , temp_cast_0 , WindTint548);
				float4 Color161 = lerpResult273;
				float dotResult141 = dot( -normalizedWorldViewDir , -_DirectionalLightDatas[0].forward );
				float lerpResult151 = lerp( ( pow( max( dotResult141 , 0.0 ) , _TransmissionSize ) * _TransmissionAmount ) , 0.0 , ( ( 1.0 - packedInput.ase_color.r ) * 1.33 ));
				float clampResult152 = clamp( lerpResult151 , 0.0 , 1.0 );
				float Subsurface153 = clampResult152;
				float4 lerpResult106 = lerp( Color161 , ( Color161 * 2.0 ) , Subsurface153);
				float4 FinalColor205 = lerpResult106;
				float4 lerpResult310 = lerp( FinalColor205 , float4( WindVector577 , 0.0 ) , _WindDebug);
				
				float2 uv_BumpMap172 = packedInput.ase_texcoord5.xy;
				float3 Normals174 = UnpackNormalmapRGorAG( tex2D( _BumpMap, uv_BumpMap172 ), 1.0 );
				
				float lerpResult557 = lerp( 1.0 , packedInput.ase_color.r , _AmbientOcclusion);
				float AmbientOcclusion207 = lerpResult557;
				
				float Alpha98 = tex2DNode97.a;
				float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
				
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
                surfaceDescription.Occlusion = AmbientOcclusion207;
				surfaceDescription.Alpha = lerpResult313;
				
				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = _AlphaCutoff;
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
                surfaceDescription.DiffusionProfile = (float)_Int0;
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
        
				#define ASE_SRP_VERSION 40900
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _SPECULAR_OCCLUSION_FROM_AO 1
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
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_texcoord1 : TEXCOORD1;
					float4 ase_color : COLOR;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				float _GlobalWindMotion;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float _LeafFlutter;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _MaxWindStrength;
				float _WindStrength;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _FlatLighting;
				sampler2D _MainTex;
				float _WindTint;
				float _TransmissionSize;
				float _TransmissionAmount;
				float _WindDebug;
				sampler2D _BumpMap;
				float _Smoothness;
				float _AmbientOcclusion;
				float _AlphaCutoff;
				float _Thickness;
				int _Int0;
				
				                
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

					float temp_output_514_0 = ( _WindSpeed * _Time.w );
					float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
					float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
					float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
					float3 temp_cast_1 = (-1.0).xxx;
					float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_1) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_1)) , temp_output_524_0 , _WindSwinging);
					float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
					float3 WindVector577 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ), 0, 0.0) ), 1.0f );
					float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
					float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
					float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * inputMesh.color.r * _WindStrength );
					float4 normalizeResult184 = normalize( ( _ObstaclePosition - float4( ase_worldPos , 0.0 ) ) );
					float temp_output_186_0 = ( _BendingStrength * 0.1 );
					float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
					float clampResult192 = clamp( ( distance( _ObstaclePosition , float4( ase_worldPos , 0.0 ) ) / _BendingRadius ) , 0.0 , 1.0 );
					float4 Bending201 = ( inputMesh.color.r * -( ( ( normalizeResult184 * float4( appendResult468 , 0.0 ) ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
					float4 VertexOffset330 = ( float4( GlobalWind84 , 0.0 ) + Bending201 );
					
					float3 lerpResult552 = lerp( inputMesh.normalOS , float3(0,1,0) , _FlatLighting);
					
					outputPackedVaryingsMeshToPS.ase_texcoord1.xyz = ase_worldPos;
					
					outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.uv0.xy;
					outputPackedVaryingsMeshToPS.ase_color = inputMesh.color;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord1.w = 0;
					float3 vertexValue = VertexOffset330.xyz;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
					#else
					inputMesh.positionOS.xyz += vertexValue;
					#endif
					
					inputMesh.normalOS = lerpResult552;

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
					float2 uv_MainTex97 = packedInput.ase_texcoord.xy;
					float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
					float4 temp_cast_0 = (2.0).xxxx;
					float temp_output_514_0 = ( _WindSpeed * _Time.w );
					float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
					float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
					float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
					float3 temp_cast_2 = (-1.0).xxx;
					float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_2) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_2)) , temp_output_524_0 , _WindSwinging);
					float3 ase_worldPos = packedInput.ase_texcoord1.xyz;
					float3 WindVector577 = UnpackNormalmapRGorAG( tex2D( _WindVectors, ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ) ), 1.0f );
					float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
					float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
					float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * packedInput.ase_color.r * _WindStrength );
					float lerpResult271 = lerp( (GlobalWind84).x , 0.0 , ( 1.0 - packedInput.ase_color.r ));
					float WindTint548 = ( ( lerpResult271 * _WindTint ) * 2.0 );
					float4 lerpResult273 = lerp( tex2DNode97 , temp_cast_0 , WindTint548);
					float4 Color161 = lerpResult273;
					float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
					ase_worldViewDir = normalize(ase_worldViewDir);
					float dotResult141 = dot( -ase_worldViewDir , -_DirectionalLightDatas[0].forward );
					float lerpResult151 = lerp( ( pow( max( dotResult141 , 0.0 ) , _TransmissionSize ) * _TransmissionAmount ) , 0.0 , ( ( 1.0 - packedInput.ase_color.r ) * 1.33 ));
					float clampResult152 = clamp( lerpResult151 , 0.0 , 1.0 );
					float Subsurface153 = clampResult152;
					float4 lerpResult106 = lerp( Color161 , ( Color161 * 2.0 ) , Subsurface153);
					float4 FinalColor205 = lerpResult106;
					float4 lerpResult310 = lerp( FinalColor205 , float4( WindVector577 , 0.0 ) , _WindDebug);
					
					float2 uv_BumpMap172 = packedInput.ase_texcoord.xy;
					float3 Normals174 = UnpackNormalmapRGorAG( tex2D( _BumpMap, uv_BumpMap172 ), 1.0 );
					
					float lerpResult557 = lerp( 1.0 , packedInput.ase_color.r , _AmbientOcclusion);
					float AmbientOcclusion207 = lerpResult557;
					
					float Alpha98 = tex2DNode97.a;
					float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
					
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
					surfaceDescription.Occlusion = AmbientOcclusion207;
					surfaceDescription.Alpha = lerpResult313;
					
					#ifdef _ALPHATEST_ON
					surfaceDescription.AlphaClipThreshold = _AlphaCutoff;
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
					surfaceDescription.DiffusionProfile = (float)_Int0;
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
        
				#define ASE_SRP_VERSION 40900
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _SPECULAR_OCCLUSION_FROM_AO 1
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

				float _GlobalWindMotion;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float _LeafFlutter;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _MaxWindStrength;
				float _WindStrength;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _FlatLighting;
				sampler2D _MainTex;
				float _WindDebug;
				float _AlphaCutoff;
				
				                
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

				float temp_output_514_0 = ( _WindSpeed * _Time.w );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
				float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
				float3 temp_cast_1 = (-1.0).xxx;
				float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_1) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_1)) , temp_output_524_0 , _WindSwinging);
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float3 WindVector577 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ), 0, 0.0) ), 1.0f );
				float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
				float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
				float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * inputMesh.ase_color.r * _WindStrength );
				float4 normalizeResult184 = normalize( ( _ObstaclePosition - float4( ase_worldPos , 0.0 ) ) );
				float temp_output_186_0 = ( _BendingStrength * 0.1 );
				float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
				float clampResult192 = clamp( ( distance( _ObstaclePosition , float4( ase_worldPos , 0.0 ) ) / _BendingRadius ) , 0.0 , 1.0 );
				float4 Bending201 = ( inputMesh.ase_color.r * -( ( ( normalizeResult184 * float4( appendResult468 , 0.0 ) ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
				float4 VertexOffset330 = ( float4( GlobalWind84 , 0.0 ) + Bending201 );
				
				float3 lerpResult552 = lerp( inputMesh.normalOS , float3(0,1,0) , _FlatLighting);
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				float3 vertexValue = VertexOffset330.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif 
				inputMesh.normalOS = lerpResult552;

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
				float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
				
				surfaceDescription.Alpha = lerpResult313;

				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = _AlphaCutoff;
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
        
				#define ASE_SRP_VERSION 40900
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _SPECULAR_OCCLUSION_FROM_AO 1
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

				float _GlobalWindMotion;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float _LeafFlutter;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _MaxWindStrength;
				float _WindStrength;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _FlatLighting;
				sampler2D _MainTex;
				float _WindDebug;
				float _AlphaCutoff;

				        
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

				float temp_output_514_0 = ( _WindSpeed * _Time.w );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
				float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
				float3 temp_cast_1 = (-1.0).xxx;
				float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_1) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_1)) , temp_output_524_0 , _WindSwinging);
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float3 WindVector577 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ), 0, 0.0) ), 1.0f );
				float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
				float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
				float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * inputMesh.ase_color.r * _WindStrength );
				float4 normalizeResult184 = normalize( ( _ObstaclePosition - float4( ase_worldPos , 0.0 ) ) );
				float temp_output_186_0 = ( _BendingStrength * 0.1 );
				float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
				float clampResult192 = clamp( ( distance( _ObstaclePosition , float4( ase_worldPos , 0.0 ) ) / _BendingRadius ) , 0.0 , 1.0 );
				float4 Bending201 = ( inputMesh.ase_color.r * -( ( ( normalizeResult184 * float4( appendResult468 , 0.0 ) ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
				float4 VertexOffset330 = ( float4( GlobalWind84 , 0.0 ) + Bending201 );
				
				float3 lerpResult552 = lerp( inputMesh.normalOS , float3(0,1,0) , _FlatLighting);
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				float3 vertexValue = VertexOffset330.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif 
				inputMesh.normalOS = lerpResult552;

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
				float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
				
				surfaceDescription.Alpha = lerpResult313;
				
				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = _AlphaCutoff;
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
        
				#define ASE_SRP_VERSION 40900
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _SPECULAR_OCCLUSION_FROM_AO 1
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
      
				float _GlobalWindMotion;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float _LeafFlutter;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _MaxWindStrength;
				float _WindStrength;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _FlatLighting;
				float _Smoothness;
				sampler2D _MainTex;
				float _WindDebug;
				float _AlphaCutoff;

				                    
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
				
				float temp_output_514_0 = ( _WindSpeed * _Time.w );
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
				float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
				float3 temp_cast_1 = (-1.0).xxx;
				float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_1) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_1)) , temp_output_524_0 , _WindSwinging);
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float3 WindVector577 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ), 0, 0.0) ), 1.0f );
				float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
				float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
				float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * inputMesh.color.r * _WindStrength );
				float4 normalizeResult184 = normalize( ( _ObstaclePosition - float4( ase_worldPos , 0.0 ) ) );
				float temp_output_186_0 = ( _BendingStrength * 0.1 );
				float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
				float clampResult192 = clamp( ( distance( _ObstaclePosition , float4( ase_worldPos , 0.0 ) ) / _BendingRadius ) , 0.0 , 1.0 );
				float4 Bending201 = ( inputMesh.color.r * -( ( ( normalizeResult184 * float4( appendResult468 , 0.0 ) ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
				float4 VertexOffset330 = ( float4( GlobalWind84 , 0.0 ) + Bending201 );
				
				float3 lerpResult552 = lerp( inputMesh.normalOS , float3(0,1,0) , _FlatLighting);
				
				float3 vertexValue = VertexOffset330.xyz;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif 

				inputMesh.normalOS = lerpResult552;

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
				float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
				
				surfaceDescription.Smoothness = _Smoothness;
				surfaceDescription.Alpha = lerpResult313;

				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = _AlphaCutoff;
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

				#define ASE_SRP_VERSION 40900
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _SPECULAR_OCCLUSION_FROM_AO 1
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

				float _GlobalWindMotion;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float _LeafFlutter;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _MaxWindStrength;
				float _WindStrength;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _FlatLighting;
				float _Smoothness;
				sampler2D _MainTex;
				float _WindDebug;
				float _AlphaCutoff;

				        
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

					float temp_output_514_0 = ( _WindSpeed * _Time.w );
					float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
					float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
					float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
					float3 temp_cast_1 = (-1.0).xxx;
					float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_1) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_1)) , temp_output_524_0 , _WindSwinging);
					float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
					float3 WindVector577 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ), 0, 0.0) ), 1.0f );
					float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
					float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
					float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * inputMesh.ase_color.r * _WindStrength );
					float4 normalizeResult184 = normalize( ( _ObstaclePosition - float4( ase_worldPos , 0.0 ) ) );
					float temp_output_186_0 = ( _BendingStrength * 0.1 );
					float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
					float clampResult192 = clamp( ( distance( _ObstaclePosition , float4( ase_worldPos , 0.0 ) ) / _BendingRadius ) , 0.0 , 1.0 );
					float4 Bending201 = ( inputMesh.ase_color.r * -( ( ( normalizeResult184 * float4( appendResult468 , 0.0 ) ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
					float4 VertexOffset330 = ( float4( GlobalWind84 , 0.0 ) + Bending201 );
					
					float3 lerpResult552 = lerp( inputMesh.normalOS , float3(0,1,0) , _FlatLighting);
					
					outputPackedVaryingsToPS.ase_texcoord3.xy = inputMesh.ase_texcoord.xy;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsToPS.ase_texcoord3.zw = 0;
					float3 vertexValue = VertexOffset330.xyz;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
					#else
					inputMesh.positionOS.xyz += vertexValue;
					#endif 
					inputMesh.normalOS = lerpResult552;

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
                    float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
                    
					surfaceDescription.Smoothness = _Smoothness;
					surfaceDescription.Alpha = lerpResult313;
					
					#ifdef _ALPHATEST_ON
					surfaceDescription.AlphaClipThreshold = _AlphaCutoff;
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
				
				#define ASE_SRP_VERSION 40900
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#define _MATERIAL_FEATURE_TRANSMISSION 1
				#define _DECALS 1
				#define _ALPHATEST_ON 1
				#define _DISABLE_SSR 1
				#define _SPECULAR_OCCLUSION_FROM_AO 1
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
					float4 ase_texcoord5 : TEXCOORD5;
					float4 ase_color : COLOR;
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif 
				};

				float _GlobalWindMotion;
				float _WindSpeed;
				float4 _WindDirection;
				float _WindSwinging;
				float _LeafFlutter;
				sampler2D _WindVectors;
				float _WindAmplitudeMultiplier;
				float _WindAmplitude;
				float _MaxWindStrength;
				float _WindStrength;
				float4 _ObstaclePosition;
				float _BendingStrength;
				float _BendingRadius;
				float _BendingInfluence;
				float _FlatLighting;
				sampler2D _MainTex;
				float _WindTint;
				float _TransmissionSize;
				float _TransmissionAmount;
				float _WindDebug;
				sampler2D _BumpMap;
				float _Smoothness;
				float _AmbientOcclusion;
				float _AlphaCutoff;
				float _Thickness;
				int _Int0;

				                  
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

					float temp_output_514_0 = ( _WindSpeed * _Time.w );
					float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
					float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
					float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
					float3 temp_cast_1 = (-1.0).xxx;
					float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_1) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_1)) , temp_output_524_0 , _WindSwinging);
					float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
					float3 WindVector577 = UnpackNormalmapRGorAG( tex2Dlod( _WindVectors, float4( ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ), 0, 0.0) ), 1.0f );
					float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
					float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
					float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * inputMesh.ase_color.r * _WindStrength );
					float4 normalizeResult184 = normalize( ( _ObstaclePosition - float4( ase_worldPos , 0.0 ) ) );
					float temp_output_186_0 = ( _BendingStrength * 0.1 );
					float3 appendResult468 = (float3(temp_output_186_0 , 0.0 , temp_output_186_0));
					float clampResult192 = clamp( ( distance( _ObstaclePosition , float4( ase_worldPos , 0.0 ) ) / _BendingRadius ) , 0.0 , 1.0 );
					float4 Bending201 = ( inputMesh.ase_color.r * -( ( ( normalizeResult184 * float4( appendResult468 , 0.0 ) ) * ( 1.0 - clampResult192 ) ) * _BendingInfluence ) );
					float4 VertexOffset330 = ( float4( GlobalWind84 , 0.0 ) + Bending201 );
					
					float3 lerpResult552 = lerp( inputMesh.normalOS , float3(0,1,0) , _FlatLighting);
					
					outputPackedVaryingsMeshToPS.ase_texcoord5.xy = inputMesh.ase_texcoord.xy;
					outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord5.zw = 0;
					float3 vertexValue = VertexOffset330.xyz;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
					#else
					inputMesh.positionOS.xyz += vertexValue;
					#endif
					inputMesh.normalOS = lerpResult552;

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
					float2 uv_MainTex97 = packedInput.ase_texcoord5.xy;
					float4 tex2DNode97 = tex2D( _MainTex, uv_MainTex97 );
					float4 temp_cast_0 = (2.0).xxxx;
					float temp_output_514_0 = ( _WindSpeed * _Time.w );
					float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
					float2 appendResult518 = (float2(_WindDirection.x , _WindDirection.z));
					float3 temp_output_524_0 = sin( ( ( temp_output_514_0 * ase_objectScale ) * float3( appendResult518 ,  0.0 ) ) );
					float3 temp_cast_2 = (-1.0).xxx;
					float3 lerpResult544 = lerp( (float3( 0,0,0 ) + (temp_output_524_0 - temp_cast_2) * (float3( 1,0,0 ) - float3( 0,0,0 )) / (float3( 1,0,0 ) - temp_cast_2)) , temp_output_524_0 , _WindSwinging);
					float3 ase_worldPos = GetAbsolutePositionWS( positionRWS );
					float3 WindVector577 = UnpackNormalmapRGorAG( tex2D( _WindVectors, ( ( ( temp_output_514_0 * 0.05 ) * appendResult518 ) + ( ( (ase_worldPos).xz * 0.01 ) * _WindAmplitudeMultiplier * _WindAmplitude ) ) ), 1.0f );
					float2 break584 = ( ( _GlobalWindMotion * (lerpResult544).x ) + ( _LeafFlutter * (WindVector577).xy ) );
					float3 appendResult583 = (float3(break584.x , 0.0 , break584.y));
					float3 GlobalWind84 = ( appendResult583 * _MaxWindStrength * packedInput.ase_color.r * _WindStrength );
					float lerpResult271 = lerp( (GlobalWind84).x , 0.0 , ( 1.0 - packedInput.ase_color.r ));
					float WindTint548 = ( ( lerpResult271 * _WindTint ) * 2.0 );
					float4 lerpResult273 = lerp( tex2DNode97 , temp_cast_0 , WindTint548);
					float4 Color161 = lerpResult273;
					float dotResult141 = dot( -normalizedWorldViewDir , -_DirectionalLightDatas[0].forward );
					float lerpResult151 = lerp( ( pow( max( dotResult141 , 0.0 ) , _TransmissionSize ) * _TransmissionAmount ) , 0.0 , ( ( 1.0 - packedInput.ase_color.r ) * 1.33 ));
					float clampResult152 = clamp( lerpResult151 , 0.0 , 1.0 );
					float Subsurface153 = clampResult152;
					float4 lerpResult106 = lerp( Color161 , ( Color161 * 2.0 ) , Subsurface153);
					float4 FinalColor205 = lerpResult106;
					float4 lerpResult310 = lerp( FinalColor205 , float4( WindVector577 , 0.0 ) , _WindDebug);
					
					float2 uv_BumpMap172 = packedInput.ase_texcoord5.xy;
					float3 Normals174 = UnpackNormalmapRGorAG( tex2D( _BumpMap, uv_BumpMap172 ), 1.0 );
					
					float lerpResult557 = lerp( 1.0 , packedInput.ase_color.r , _AmbientOcclusion);
					float AmbientOcclusion207 = lerpResult557;
					
					float Alpha98 = tex2DNode97.a;
					float lerpResult313 = lerp( Alpha98 , 1.0 , _WindDebug);
					
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
					surfaceDescription.Occlusion = AmbientOcclusion207;
					surfaceDescription.Alpha = lerpResult313;
					
					#ifdef _ALPHATEST_ON
					surfaceDescription.AlphaClipThreshold = _AlphaCutoff;
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
					surfaceDescription.DiffusionProfile = (float)_Int0;
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
Version=16209
7.2;1.6;1523;795;-3152.473;-1087.612;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;507;-4066.512,-3186.75;Float;False;4223.285;1155.072;;38;534;84;583;584;581;582;577;385;16;527;580;544;526;576;248;561;543;524;520;560;568;571;565;518;517;570;562;516;514;511;567;564;563;319;513;573;586;588;Global wind motion;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;573;-3697.419,-2433.168;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TimeNode;513;-3715.418,-3017.448;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;319;-3937.326,-3132.458;Float;False;Global;_WindSpeed;_WindSpeed;11;0;Create;True;0;0;False;0;0;0.318;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;516;-3691.352,-2718.526;Float;False;Global;_WindDirection;_WindDirection;9;0;Create;True;0;0;False;0;1,0,0,0;-0.08159085,0,0.996666,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;564;-3140.257,-2684.31;Float;False;Constant;_Float7;Float 7;19;0;Create;True;0;0;False;0;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;511;-3447.5,-2873.395;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;567;-3472.122,-2317.767;Float;False;Constant;_Float8;Float 8;19;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;-3415.012,-3081.15;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;563;-3451.174,-2440.566;Float;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;518;-3418.178,-2697.826;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;565;-3636.875,-2224.849;Float;False;Property;_WindAmplitudeMultiplier;WindAmplitudeMultiplier;10;0;Create;True;0;0;False;0;10;9.98;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;517;-3202.916,-2977.488;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;571;-3638.923,-2138.373;Float;False;Global;_WindAmplitude;_WindAmplitude;20;0;Create;True;0;0;False;0;1;6.8;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;562;-2962.2,-2732.018;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;570;-3223.371,-2438.942;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;520;-2957.145,-2879.598;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;568;-2996.431,-2370.207;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;560;-2832.244,-2499.469;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;543;-2702.433,-3019.491;Float;False;Constant;_Float2;Float 2;13;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;524;-2735.857,-2890.221;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;561;-2649.573,-2414.612;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;526;-2470.363,-3036.312;Float;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;576;-2458.675,-2449.087;Float;True;Global;_WindVectors;_WindVectors;7;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;6c795dd1d1d319e479e68164001557e8;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;248;-2550.377,-2800.018;Float;False;Property;_WindSwinging;WindSwinging;6;0;Create;True;0;0;False;0;0;0.195;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;577;-2119.198,-2444.151;Float;False;WindVector;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;544;-2207.111,-2912.084;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;582;-1856.577,-2450.862;Float;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;588;-2122.579,-2651.492;Float;False;Property;_LeafFlutter;LeafFlutter;13;0;Create;True;0;0;False;0;0.495;0.681;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;580;-2005.865,-2919.054;Float;False;FLOAT;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;586;-2054.995,-3070.913;Float;False;Property;_GlobalWindMotion;GlobalWindMotion;12;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;585;-1709.203,-2955.683;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;587;-1708.298,-2667.625;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;581;-1546.871,-2894.326;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;584;-1395.815,-2901.544;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;583;-1107.815,-2871.544;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1069.807,-2732.127;Float;False;Property;_MaxWindStrength;Max Wind Strength;11;0;Create;True;0;0;False;0;0.126967;0.126967;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;527;-962.0208,-2647.322;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;385;-1000.576,-2451.538;Float;False;Global;_WindStrength;_WindStrength;19;0;Create;True;0;0;False;0;2;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;534;-558.2651,-2880.917;Float;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;202;-3197.001,-177.1511;Float;False;2627.3;775.1997;Bending;23;181;183;186;188;184;194;189;191;192;193;195;196;197;200;198;201;231;232;234;386;387;468;506;Foliage bending away from obstacle;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;373;-2588.356,831.4046;Float;False;2020.167;388.1052;Comment;10;307;274;407;271;101;502;86;93;548;558;Color through wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-373.5839,-2893.495;Float;False;GlobalWind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;181;-3132.901,260.3462;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;231;-3149.54,-21.90026;Float;False;Global;_ObstaclePosition;_ObstaclePosition;18;1;[HideInInspector];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;160;-3251.288,1459.145;Float;False;2711.621;557.9603;Subsurface scattering;17;153;152;380;151;149;147;148;146;145;150;141;143;139;140;138;503;550;Subsurface color simulation;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-2429.357,883.4036;Float;False;84;GlobalWind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;138;-3105.49,1513.545;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;234;-2752.54,198.0997;Float;False;Global;_BendingStrength;_BendingStrength;15;1;[HideInInspector];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;386;-2733.566,277.5881;Float;False;Constant;_Float10;Float 10;19;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;86;-2249.954,1022.705;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;189;-2728.102,360.0503;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-2770.54,494.1013;Float;False;Global;_BendingRadius;_BendingRadius;14;1;[HideInInspector];Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;558;-2021.708,896.4333;Float;False;FLOAT;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;191;-2514.301,406.0505;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;183;-2716.801,11.44478;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NegateNode;139;-2909.05,1510.851;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;140;-3203.488,1675.545;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-2524.901,207.147;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;502;-1979.193,1046.495;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;387;-2491.766,512.8883;Float;False;Constant;_Float11;Float 11;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;468;-2318.499,188.0509;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;271;-1787.723,909.8607;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;192;-2343.301,406.0505;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;141;-2743.491,1573.545;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-1761.713,1083.204;Float;False;Property;_WindTint;WindTint;2;0;Create;True;0;0;False;0;0.1;0.217;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;184;-2438.904,10.64699;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-2078.9,17.14789;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-2757.122,1735.206;Float;False;Property;_TransmissionSize;Transmission Size;4;0;Create;True;0;0;False;0;1;7.5;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;193;-2099.301,408.0505;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;550;-2540.499,1578.627;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-1430.625,905.5606;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;148;-2149.892,1710.745;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;407;-1410.77,1037.111;Float;False;Constant;_Float13;Float 13;20;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-1833.604,412.4233;Float;False;Property;_BendingInfluence;BendingInfluence;8;0;Create;True;0;0;False;0;0;0.731;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;503;-1959.698,1730.817;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-2465.291,1732.945;Float;False;Property;_TransmissionAmount;Transmission Amount;5;0;Create;True;0;0;False;0;2.696819;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-2075.692,1892.346;Float;False;Constant;_TransmissionHeight;TransmissionHeight;12;0;Create;True;0;0;False;0;1.33;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;145;-2350.844,1569.851;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-1206.763,921.5057;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-1841.1,176.6488;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;236;-2419.377,3192.074;Float;False;1901.952;536.7815;SSS Blending with color;11;205;106;547;296;295;161;549;98;273;497;97;Final color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;548;-987.9922,910.64;Float;False;WindTint;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;-1526.547,180.2964;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-1789.491,1741.945;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-2142.892,1575.345;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;497;-2240.694,3458.267;Float;False;Constant;_Float0;Float 0;20;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;97;-2366.277,3258.45;Float;True;Property;_MainTex;MainTex;0;1;[NoScaleOffset];Create;True;0;0;True;0;None;f654a384396a5a245a9a41a56b8efbeb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;549;-2251.758,3568.538;Float;False;548;WindTint;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;198;-1395.148,-4.388111;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;197;-1352.842,182.2973;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;380;-1241.679,1774.337;Float;False;Constant;_Float4;Float 4;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;151;-1589.291,1574.945;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;273;-1928.839,3336.538;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;-1163.417,146.3718;Float;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;152;-1035.492,1567.445;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;-1738.614,3342.875;Float;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;-858.9927,1570.345;Float;False;Subsurface;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;506;-1007.616,142.1316;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-1579.436,3466.872;Float;False;Constant;_Float1;Float 1;21;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-818.7435,139.0677;Float;False;Bending;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;159;-2367.693,2262.087;Float;False;1813.59;398.8397;AO;4;207;113;111;557;Ambient Occlusion by Red vertex color channel;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;547;-1256.909,3553.238;Float;False;153;Subsurface;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;237;-1533.39,2770.484;Float;False;978.701;287.5597;;3;174;172;419;Normal map;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;-1333.547,3428.735;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;374;254.2972,-61.15241;Float;False;1307.47;528.0521;Comment;4;330;203;85;204;Vertex function layer blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;106;-965.9405,3349.727;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;339.7766,-11.15247;Float;False;84;GlobalWind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-2171.473,2528.067;Float;False;Property;_AmbientOcclusion;AmbientOcclusion;3;0;Create;True;0;0;False;0;0;0.867;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;485.497,143.4051;Float;False;201;Bending;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;111;-2317.692,2312.087;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;419;-1420.771,2899.029;Float;False;Constant;_Float18;Float 18;21;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;172;-1182.389,2825.043;Float;True;Property;_BumpMap;BumpMap;1;2;[NoScaleOffset];[Normal];Create;True;0;0;True;0;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;203;780.7659,11.02355;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-1934.471,3256.42;Float;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;375;2964.505,1790.556;Float;False;352;249.0994;Comment;2;312;311;Debug switch;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;557;-1832.394,2336.545;Float;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;235;2843.666,889.9761;Float;False;452.9371;811.1447;Final;1;206;Outputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;205;-771.8661,3343.871;Float;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-797.689,2820.483;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;451;2937.299,2066.65;Float;False;Constant;_Vector0;Vector 0;21;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;330;1331.807,33.5835;Float;False;VertexOffset;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalVertexDataNode;553;2922.633,2246;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;551;2933.198,2422.128;Float;False;Property;_FlatLighting;FlatLighting;9;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;3561.005,1390.879;Float;False;98;Alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;-1642.589,2346.922;Float;False;AmbientOcclusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;311;3014.505,1924.656;Float;False;Global;_WindDebug;_WindDebug;20;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;3072.166,941.4243;Float;False;205;FinalColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;312;3073.705,1840.556;Float;False;577;WindVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;406;3571.739,1475.127;Float;False;Constant;_Float12;Float 12;20;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;310;3589.109,973.5546;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;3769.352,1284.505;Float;False;207;AmbientOcclusion;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;313;3831.875,1408.118;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;3635.648,1128.905;Float;False;174;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;3753.835,1609.293;Float;False;330;VertexOffset;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;552;3356.692,2087.125;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;599;3995.473,1345.112;Float;False;Property;_Int0;Int 0;15;0;Create;True;0;0;False;0;1;1;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;600;3835.473,1744.612;Float;False;Property;_AlphaCutoff;AlphaCutoff;16;0;Create;True;0;0;False;0;0.5;0.735;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;598;3871.473,1538.112;Float;False;Property;_Thickness;Thickness;14;0;Create;True;0;0;False;0;0;0.734;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;601;4019.473,1274.612;Float;False;Property;_Smoothness;Smoothness;17;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;595;4240.718,1217.804;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;Distortion;0;6;Distortion;2;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;True;4;1;False;-1;1;False;-1;4;1;False;-1;1;False;-1;True;1;False;-1;5;False;-1;False;False;False;False;False;True;3;False;-1;False;True;1;LightMode=DistortionVectors;False;0;;0;0;Standard;0;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;594;4240.718,1217.804;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;Motion Vectors;0;5;Motion Vectors;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;128;False;-1;255;False;-1;128;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=MotionVectors;False;0;;0;0;Standard;0;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;596;4240.718,1217.804;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;TransparentBackface;0;7;TransparentBackface;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;True;1;False;-1;False;False;False;False;False;True;1;LightMode=TransparentBackface;False;0;;0;0;Standard;0;13;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;597;4240.718,1217.804;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;Forward;0;8;Forward;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;34;False;-1;255;False;-1;39;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=Forward;False;0;;0;0;Standard;0;26;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;18;FLOAT3;0,0,0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT;0;False;23;FLOAT3;0,0,0;False;24;FLOAT;0;False;25;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;589;4240.718,1217.804;Float;False;True;2;Float;ASEMaterialInspector;0;4;FAE/Foliage;091c43ba8bd92c9459798d59b089ce4e;True;GBuffer;0;0;GBuffer;26;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;False;False;True;0;False;-1;True;0;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=TransparentCutout=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;34;False;-1;255;False;-1;39;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=GBuffer;False;0;;0;0;Standard;18;Material Type,InvertActionOnDeselection;5;Energy Conserving Specular,InvertActionOnDeselection;0;Transmission,InvertActionOnDeselection;0;Surface Type;0;Receive Decals;1;Alpha Cutoff;1;Receives SSR;0;Specular AA;0;Specular Occlusion Mode;1;Distortion;0;Distortion Mode;0;Distortion Depth Test;0;Back Then Front Rendering;0;Blend Preserves Specular;1;Fog;1;Draw Before Refraction;0;Refraction Model;0;Vertex Position,InvertActionOnDeselection;1;0;9;True;True;True;True;True;True;False;False;True;False;26;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;18;FLOAT3;0,0,0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT;0;False;23;FLOAT3;0,0,0;False;24;FLOAT;0;False;25;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;590;4240.718,1217.804;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;META;0;1;META;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;26;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;18;FLOAT3;0,0,0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT;0;False;23;FLOAT3;0,0,0;False;24;FLOAT;0;False;25;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;591;4240.718,1217.804;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;ShadowCaster;0;2;ShadowCaster;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;592;4240.718,1217.804;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;SceneSelectionPass;0;3;SceneSelectionPass;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;593;4240.718,1217.804;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;DepthOnly;0;4;DepthOnly;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;0
WireConnection;514;0;319;0
WireConnection;514;1;513;4
WireConnection;563;0;573;0
WireConnection;518;0;516;1
WireConnection;518;1;516;3
WireConnection;517;0;514;0
WireConnection;517;1;511;0
WireConnection;562;0;514;0
WireConnection;562;1;564;0
WireConnection;570;0;563;0
WireConnection;570;1;567;0
WireConnection;520;0;517;0
WireConnection;520;1;518;0
WireConnection;568;0;570;0
WireConnection;568;1;565;0
WireConnection;568;2;571;0
WireConnection;560;0;562;0
WireConnection;560;1;518;0
WireConnection;524;0;520;0
WireConnection;561;0;560;0
WireConnection;561;1;568;0
WireConnection;526;0;524;0
WireConnection;526;1;543;0
WireConnection;576;1;561;0
WireConnection;577;0;576;0
WireConnection;544;0;526;0
WireConnection;544;1;524;0
WireConnection;544;2;248;0
WireConnection;582;0;577;0
WireConnection;580;0;544;0
WireConnection;585;0;586;0
WireConnection;585;1;580;0
WireConnection;587;0;588;0
WireConnection;587;1;582;0
WireConnection;581;0;585;0
WireConnection;581;1;587;0
WireConnection;584;0;581;0
WireConnection;583;0;584;0
WireConnection;583;2;584;1
WireConnection;534;0;583;0
WireConnection;534;1;16;0
WireConnection;534;2;527;1
WireConnection;534;3;385;0
WireConnection;84;0;534;0
WireConnection;189;0;231;0
WireConnection;189;1;181;0
WireConnection;558;0;93;0
WireConnection;191;0;189;0
WireConnection;191;1;232;0
WireConnection;183;0;231;0
WireConnection;183;1;181;0
WireConnection;139;0;138;0
WireConnection;186;0;234;0
WireConnection;186;1;386;0
WireConnection;502;0;86;1
WireConnection;468;0;186;0
WireConnection;468;2;186;0
WireConnection;271;0;558;0
WireConnection;271;2;502;0
WireConnection;192;0;191;0
WireConnection;192;2;387;0
WireConnection;141;0;139;0
WireConnection;141;1;140;0
WireConnection;184;0;183;0
WireConnection;188;0;184;0
WireConnection;188;1;468;0
WireConnection;193;0;192;0
WireConnection;550;0;141;0
WireConnection;274;0;271;0
WireConnection;274;1;101;0
WireConnection;503;0;148;1
WireConnection;145;0;550;0
WireConnection;145;1;143;0
WireConnection;307;0;274;0
WireConnection;307;1;407;0
WireConnection;194;0;188;0
WireConnection;194;1;193;0
WireConnection;548;0;307;0
WireConnection;196;0;194;0
WireConnection;196;1;195;0
WireConnection;149;0;503;0
WireConnection;149;1;150;0
WireConnection;147;0;145;0
WireConnection;147;1;146;0
WireConnection;197;0;196;0
WireConnection;151;0;147;0
WireConnection;151;2;149;0
WireConnection;273;0;97;0
WireConnection;273;1;497;0
WireConnection;273;2;549;0
WireConnection;200;0;198;1
WireConnection;200;1;197;0
WireConnection;152;0;151;0
WireConnection;152;2;380;0
WireConnection;161;0;273;0
WireConnection;153;0;152;0
WireConnection;506;0;200;0
WireConnection;201;0;506;0
WireConnection;295;0;161;0
WireConnection;295;1;296;0
WireConnection;106;0;161;0
WireConnection;106;1;295;0
WireConnection;106;2;547;0
WireConnection;172;5;419;0
WireConnection;203;0;85;0
WireConnection;203;1;204;0
WireConnection;98;0;97;4
WireConnection;557;1;111;1
WireConnection;557;2;113;0
WireConnection;205;0;106;0
WireConnection;174;0;172;0
WireConnection;330;0;203;0
WireConnection;207;0;557;0
WireConnection;310;0;206;0
WireConnection;310;1;312;0
WireConnection;310;2;311;0
WireConnection;313;0;99;0
WireConnection;313;1;406;0
WireConnection;313;2;311;0
WireConnection;552;0;553;0
WireConnection;552;1;451;0
WireConnection;552;2;551;0
WireConnection;589;0;310;0
WireConnection;589;1;175;0
WireConnection;589;7;601;0
WireConnection;589;8;208;0
WireConnection;589;9;313;0
WireConnection;589;10;600;0
WireConnection;589;16;598;0
WireConnection;589;21;599;0
WireConnection;589;11;331;0
WireConnection;589;12;552;0
ASEEND*/
//CHKSM=2FEE2D210B055DB6A3C07A8108E5EC3EBB87F961