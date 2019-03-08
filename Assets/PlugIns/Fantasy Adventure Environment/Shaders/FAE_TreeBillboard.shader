// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FAE/Tree Billboard"
{
    Properties
    {
		_Atlas("Atlas", 2D) = "white" {}
		_Variationcolor("Variation color", Color) = (1,0.5,0,0.184)
		_Normals("Normals", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
    }

    SubShader
    {        
		

		Tags { "RenderPipeline"="HDRenderPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Blend One Zero
		Cull Back
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
				Ref 2
				WriteMask 7
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
				#define _DECALS 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1
				#define _ALPHATEST_ON 1


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
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				float _WindSpeed;
				float _TrunkWindSpeed;
				float4 _WindDirection;
				float _TrunkWindSwinging;
				float _TrunkWindWeight;
				sampler2D _Atlas;
				float4 _Atlas_ST;
				float4 _Variationcolor;
				sampler2D _Normals;
				float4 _Normals_ST;

				    
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

				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float3 appendResult18 = (float3(_WindDirection.x , 0.0 , _WindDirection.z));
				float3 _Vector23 = float3(1,1,1);
				float3 break55 = (float3( 0,0,0 ) + (sin( ( ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * ( _TrunkWindSpeed / ase_objectScale ) ) * appendResult18 ) ) - ( float3(-1,-1,-1) + _TrunkWindSwinging )) * (_Vector23 - float3( 0,0,0 )) / (_Vector23 - ( float3(-1,-1,-1) + _TrunkWindSwinging )));
				float3 appendResult56 = (float3(break55.x , 0.0 , break55.z));
				float3 Wind48 = ( ( appendResult56 * _TrunkWindWeight ) * inputMesh.ase_color.a );
				
				outputPackedVaryingsMeshToPS.ase_texcoord5.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord5.zw = 0;
				float3 vertexValue = Wind48;
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
				float2 uv_Atlas = packedInput.ase_texcoord5.xy * _Atlas_ST.xy + _Atlas_ST.zw;
				float4 tex2DNode1 = tex2D( _Atlas, uv_Atlas );
				float4 transform43 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				transform43.xyz = GetAbsolutePositionWS((transform43).xyz);
				float4 lerpResult46 = lerp( tex2DNode1 , _Variationcolor , ( _Variationcolor.a * frac( ( ( transform43.x + transform43.y ) + transform43.z ) ) ));
				
				float2 uv_Normals = packedInput.ase_texcoord5.xy * _Normals_ST.xy + _Normals_ST.zw;
				
                surfaceDescription.Albedo = lerpResult46.rgb;
                surfaceDescription.Normal = ( 1.0 - UnpackNormalmapRGorAG( tex2D( _Normals, uv_Normals ), 1.0f ) );
                surfaceDescription.BentNormal = float3( 0, 0, 1 );
                surfaceDescription.CoatMask = 0;
                surfaceDescription.Metallic = 0;
				
				#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceDescription.Specular = 0;
				#endif
                
				surfaceDescription.Emission = 0;
                surfaceDescription.Smoothness = 0.5;
                surfaceDescription.Occlusion = 1;
				surfaceDescription.Alpha = tex2DNode1.a;
				
				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = 0.5;
				#endif

				#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
				surfaceDescription.SpecularAAScreenSpaceVariance = 0;
				surfaceDescription.SpecularAAThreshold = 0;
				#endif

				#ifdef _SPECULAR_OCCLUSION_CUSTOM
				surfaceDescription.SpecularOcclusion = 0;
				#endif

				#if defined(_HAS_REFRACTION) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceDescription.Thickness = 1;
				#endif

				#ifdef _HAS_REFRACTION
				surfaceDescription.RefractionIndex = 1;
                surfaceDescription.RefractionColor = float3(1,1,1);
                surfaceDescription.RefractionDistance = 0;
				#endif

				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceDescription.SubsurfaceMask = 1;
                surfaceDescription.DiffusionProfile = 0;
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
				#define _DECALS 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1
				#define _ALPHATEST_ON 1


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
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				float _WindSpeed;
				float _TrunkWindSpeed;
				float4 _WindDirection;
				float _TrunkWindSwinging;
				float _TrunkWindWeight;
				sampler2D _Atlas;
				float4 _Atlas_ST;
				float4 _Variationcolor;
				sampler2D _Normals;
				float4 _Normals_ST;
				
				                
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

					float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
					float3 appendResult18 = (float3(_WindDirection.x , 0.0 , _WindDirection.z));
					float3 _Vector23 = float3(1,1,1);
					float3 break55 = (float3( 0,0,0 ) + (sin( ( ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * ( _TrunkWindSpeed / ase_objectScale ) ) * appendResult18 ) ) - ( float3(-1,-1,-1) + _TrunkWindSwinging )) * (_Vector23 - float3( 0,0,0 )) / (_Vector23 - ( float3(-1,-1,-1) + _TrunkWindSwinging )));
					float3 appendResult56 = (float3(break55.x , 0.0 , break55.z));
					float3 Wind48 = ( ( appendResult56 * _TrunkWindWeight ) * inputMesh.color.a );
					
					outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.uv0.xy;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
					float3 vertexValue = Wind48;
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
					float2 uv_Atlas = packedInput.ase_texcoord.xy * _Atlas_ST.xy + _Atlas_ST.zw;
					float4 tex2DNode1 = tex2D( _Atlas, uv_Atlas );
					float4 transform43 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
					transform43.xyz = GetAbsolutePositionWS((transform43).xyz);
					float4 lerpResult46 = lerp( tex2DNode1 , _Variationcolor , ( _Variationcolor.a * frac( ( ( transform43.x + transform43.y ) + transform43.z ) ) ));
					
					float2 uv_Normals = packedInput.ase_texcoord.xy * _Normals_ST.xy + _Normals_ST.zw;
					
					surfaceDescription.Albedo = lerpResult46.rgb;
					surfaceDescription.Normal = ( 1.0 - UnpackNormalmapRGorAG( tex2D( _Normals, uv_Normals ), 1.0f ) );
					surfaceDescription.BentNormal = float3( 0, 0, 1 );
					surfaceDescription.CoatMask = 0;
					surfaceDescription.Metallic = 0;
					
					#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceDescription.Specular = 0;
					#endif
					
					surfaceDescription.Emission = 0;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Alpha = tex2DNode1.a;
					
					#ifdef _ALPHATEST_ON
					surfaceDescription.AlphaClipThreshold = 0.5;
					#endif

					#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceDescription.SpecularAAScreenSpaceVariance = 0;
					surfaceDescription.SpecularAAThreshold = 0;
					#endif

					#ifdef _SPECULAR_OCCLUSION_CUSTOM
					surfaceDescription.SpecularOcclusion = 0;
					#endif

					#if defined(_HAS_REFRACTION) || defined(_MATERIAL_FEATURE_TRANSMISSION)
					surfaceDescription.Thickness = 1;
					#endif

					#ifdef _HAS_REFRACTION
					surfaceDescription.RefractionIndex = 1;
					surfaceDescription.RefractionColor = float3(1,1,1);
					surfaceDescription.RefractionDistance = 0;
					#endif

					#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceDescription.SubsurfaceMask = 1;
					surfaceDescription.DiffusionProfile = 0;
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
				#define _DECALS 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1
				#define _ALPHATEST_ON 1


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

				float _WindSpeed;
				float _TrunkWindSpeed;
				float4 _WindDirection;
				float _TrunkWindSwinging;
				float _TrunkWindWeight;
				sampler2D _Atlas;
				float4 _Atlas_ST;
				
				                
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

				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float3 appendResult18 = (float3(_WindDirection.x , 0.0 , _WindDirection.z));
				float3 _Vector23 = float3(1,1,1);
				float3 break55 = (float3( 0,0,0 ) + (sin( ( ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * ( _TrunkWindSpeed / ase_objectScale ) ) * appendResult18 ) ) - ( float3(-1,-1,-1) + _TrunkWindSwinging )) * (_Vector23 - float3( 0,0,0 )) / (_Vector23 - ( float3(-1,-1,-1) + _TrunkWindSwinging )));
				float3 appendResult56 = (float3(break55.x , 0.0 , break55.z));
				float3 Wind48 = ( ( appendResult56 * _TrunkWindWeight ) * inputMesh.ase_color.a );
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				float3 vertexValue = Wind48;
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
				float2 uv_Atlas = packedInput.ase_texcoord.xy * _Atlas_ST.xy + _Atlas_ST.zw;
				float4 tex2DNode1 = tex2D( _Atlas, uv_Atlas );
				
				surfaceDescription.Alpha = tex2DNode1.a;

				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = 0.5;
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
				#define _DECALS 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1
				#define _ALPHATEST_ON 1


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

				float _WindSpeed;
				float _TrunkWindSpeed;
				float4 _WindDirection;
				float _TrunkWindSwinging;
				float _TrunkWindWeight;
				sampler2D _Atlas;
				float4 _Atlas_ST;

				        
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

				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float3 appendResult18 = (float3(_WindDirection.x , 0.0 , _WindDirection.z));
				float3 _Vector23 = float3(1,1,1);
				float3 break55 = (float3( 0,0,0 ) + (sin( ( ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * ( _TrunkWindSpeed / ase_objectScale ) ) * appendResult18 ) ) - ( float3(-1,-1,-1) + _TrunkWindSwinging )) * (_Vector23 - float3( 0,0,0 )) / (_Vector23 - ( float3(-1,-1,-1) + _TrunkWindSwinging )));
				float3 appendResult56 = (float3(break55.x , 0.0 , break55.z));
				float3 Wind48 = ( ( appendResult56 * _TrunkWindWeight ) * inputMesh.ase_color.a );
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				float3 vertexValue = Wind48;
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
				float2 uv_Atlas = packedInput.ase_texcoord.xy * _Atlas_ST.xy + _Atlas_ST.zw;
				float4 tex2DNode1 = tex2D( _Atlas, uv_Atlas );
				
				surfaceDescription.Alpha = tex2DNode1.a;
				
				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = 0.5;
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
				#define _DECALS 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1
				#define _ALPHATEST_ON 1


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
      
				float _WindSpeed;
				float _TrunkWindSpeed;
				float4 _WindDirection;
				float _TrunkWindSwinging;
				float _TrunkWindWeight;
				sampler2D _Atlas;
				float4 _Atlas_ST;

				                    
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
				
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float3 appendResult18 = (float3(_WindDirection.x , 0.0 , _WindDirection.z));
				float3 _Vector23 = float3(1,1,1);
				float3 break55 = (float3( 0,0,0 ) + (sin( ( ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * ( _TrunkWindSpeed / ase_objectScale ) ) * appendResult18 ) ) - ( float3(-1,-1,-1) + _TrunkWindSwinging )) * (_Vector23 - float3( 0,0,0 )) / (_Vector23 - ( float3(-1,-1,-1) + _TrunkWindSwinging )));
				float3 appendResult56 = (float3(break55.x , 0.0 , break55.z));
				float3 Wind48 = ( ( appendResult56 * _TrunkWindWeight ) * inputMesh.color.a );
				
				float3 vertexValue = Wind48;
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
				float2 uv_Atlas = packedInput.interp03.xy * _Atlas_ST.xy + _Atlas_ST.zw;
				float4 tex2DNode1 = tex2D( _Atlas, uv_Atlas );
				
				surfaceDescription.Smoothness = 1;
				surfaceDescription.Alpha = tex2DNode1.a;

				#ifdef _ALPHATEST_ON
				surfaceDescription.AlphaClipThreshold = 0.5;
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
				#define _DECALS 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1
				#define _ALPHATEST_ON 1

        
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

				float _WindSpeed;
				float _TrunkWindSpeed;
				float4 _WindDirection;
				float _TrunkWindSwinging;
				float _TrunkWindWeight;
				sampler2D _Atlas;
				float4 _Atlas_ST;

				        
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

					float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
					float3 appendResult18 = (float3(_WindDirection.x , 0.0 , _WindDirection.z));
					float3 _Vector23 = float3(1,1,1);
					float3 break55 = (float3( 0,0,0 ) + (sin( ( ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * ( _TrunkWindSpeed / ase_objectScale ) ) * appendResult18 ) ) - ( float3(-1,-1,-1) + _TrunkWindSwinging )) * (_Vector23 - float3( 0,0,0 )) / (_Vector23 - ( float3(-1,-1,-1) + _TrunkWindSwinging )));
					float3 appendResult56 = (float3(break55.x , 0.0 , break55.z));
					float3 Wind48 = ( ( appendResult56 * _TrunkWindWeight ) * inputMesh.ase_color.a );
					
					outputPackedVaryingsToPS.ase_texcoord3.xy = inputMesh.ase_texcoord.xy;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsToPS.ase_texcoord3.zw = 0;
					float3 vertexValue = Wind48;
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
                    float2 uv_Atlas = packedInput.ase_texcoord3.xy * _Atlas_ST.xy + _Atlas_ST.zw;
                    float4 tex2DNode1 = tex2D( _Atlas, uv_Atlas );
                    
					surfaceDescription.Smoothness = 1;
					surfaceDescription.Alpha = tex2DNode1.a;
					
					#ifdef _ALPHATEST_ON
					surfaceDescription.AlphaClipThreshold = 0.5;
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
				Ref 2
				WriteMask 7
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
				#define _DECALS 1
				#define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
				#define _ENABLE_FOG_ON_TRANSPARENT 1
				#define _ALPHATEST_ON 1

        
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
					#if INSTANCING_ON
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif 
				};

				float _WindSpeed;
				float _TrunkWindSpeed;
				float4 _WindDirection;
				float _TrunkWindSwinging;
				float _TrunkWindWeight;
				sampler2D _Atlas;
				float4 _Atlas_ST;
				float4 _Variationcolor;
				sampler2D _Normals;
				float4 _Normals_ST;

				                  
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

					float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
					float3 appendResult18 = (float3(_WindDirection.x , 0.0 , _WindDirection.z));
					float3 _Vector23 = float3(1,1,1);
					float3 break55 = (float3( 0,0,0 ) + (sin( ( ( ( ( _WindSpeed * 0.05 ) * _Time.w ) * ( _TrunkWindSpeed / ase_objectScale ) ) * appendResult18 ) ) - ( float3(-1,-1,-1) + _TrunkWindSwinging )) * (_Vector23 - float3( 0,0,0 )) / (_Vector23 - ( float3(-1,-1,-1) + _TrunkWindSwinging )));
					float3 appendResult56 = (float3(break55.x , 0.0 , break55.z));
					float3 Wind48 = ( ( appendResult56 * _TrunkWindWeight ) * inputMesh.ase_color.a );
					
					outputPackedVaryingsMeshToPS.ase_texcoord5.xy = inputMesh.ase_texcoord.xy;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord5.zw = 0;
					float3 vertexValue = Wind48;
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
					float2 uv_Atlas = packedInput.ase_texcoord5.xy * _Atlas_ST.xy + _Atlas_ST.zw;
					float4 tex2DNode1 = tex2D( _Atlas, uv_Atlas );
					float4 transform43 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
					transform43.xyz = GetAbsolutePositionWS((transform43).xyz);
					float4 lerpResult46 = lerp( tex2DNode1 , _Variationcolor , ( _Variationcolor.a * frac( ( ( transform43.x + transform43.y ) + transform43.z ) ) ));
					
					float2 uv_Normals = packedInput.ase_texcoord5.xy * _Normals_ST.xy + _Normals_ST.zw;
					
					surfaceDescription.Albedo = lerpResult46.rgb;
					surfaceDescription.Normal = ( 1.0 - UnpackNormalmapRGorAG( tex2D( _Normals, uv_Normals ), 1.0f ) );
					surfaceDescription.BentNormal = float3( 0, 0, 1 );
					surfaceDescription.CoatMask = 0;
					surfaceDescription.Metallic = 0;
					
					#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceDescription.Specular = 0;
					#endif
					
					surfaceDescription.Emission = 0;
					surfaceDescription.Smoothness = 0.5;
					surfaceDescription.Occlusion = 1;
					surfaceDescription.Alpha = tex2DNode1.a;
					
					#ifdef _ALPHATEST_ON
					surfaceDescription.AlphaClipThreshold = 0.5;
					#endif

					#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
					surfaceDescription.SpecularAAScreenSpaceVariance = 0;
					surfaceDescription.SpecularAAThreshold = 0;
					#endif

					#ifdef _SPECULAR_OCCLUSION_CUSTOM
					surfaceDescription.SpecularOcclusion = 0;
					#endif

					#if defined(_HAS_REFRACTION) || defined(_MATERIAL_FEATURE_TRANSMISSION)
					surfaceDescription.Thickness = 1;
					#endif

					#ifdef _HAS_REFRACTION
					surfaceDescription.RefractionIndex = 1;
					surfaceDescription.RefractionColor = float3(1,1,1);
					surfaceDescription.RefractionDistance = 0;
					#endif

					#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceDescription.SubsurfaceMask = 1;
					surfaceDescription.DiffusionProfile = 0;
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
7.2;1.6;1523;795;1594.488;656.147;2.09;True;False
Node;AmplifyShaderEditor.CommentaryNode;49;-2516.138,-1505.089;Float;False;3322.649;1011.52;Comment;26;56;55;27;31;48;32;26;24;23;28;25;21;20;22;19;18;37;17;14;36;15;16;35;34;33;57;Wind engine;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2400.276,-1376.865;Float;False;Constant;_Float26;Float 26;10;0;Create;True;0;0;False;0;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2466.138,-1455.089;Float;False;Global;_WindSpeed;_WindSpeed;7;0;Create;True;0;0;False;0;0.3;0.318;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2172.73,-941.0371;Float;False;Global;_TrunkWindSpeed;_TrunkWindSpeed;10;0;Create;True;0;0;False;0;10;33.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;36;-2166.043,-1335.786;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-2087.876,-1448.266;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;16;-2135.238,-852.6451;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1865.635,-1399.488;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;17;-1860.936,-908.9457;Float;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;14;-2143.935,-1126.542;Float;False;Global;_WindDirection;_WindDirection;9;0;Create;True;0;0;False;0;0,0,0,0;-0.08159085,0,0.996666,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1562.932,-1223.736;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;-1883.295,-1096.746;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;20;-1334.436,-1005.644;Float;False;Constant;_Vector21;Vector 21;10;0;Create;True;0;0;False;0;-1,-1,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1301.334,-1131.742;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1420.338,-835.3469;Float;False;Global;_TrunkWindSwinging;_TrunkWindSwinging;10;0;Create;True;0;0;False;0;0;0.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-1096.338,-945.3469;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;25;-1167.489,-767.9471;Float;False;Constant;_Vector23;Vector 23;10;0;Create;True;0;0;False;0;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SinOpNode;23;-1114.033,-1119.242;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;26;-869.7344,-1107.843;Float;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;2;FLOAT3;1,1,1;False;3;FLOAT3;0,0,0;False;4;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;55;-642.2948,-1112.043;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;27;-342.4654,-950.4337;Float;False;Global;_TrunkWindWeight;_TrunkWindWeight;10;0;Create;True;0;0;False;0;2;4.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;56;-303.8236,-1120.83;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;43;-1453.147,140.8373;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-2.56002,-1130.665;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-1237.012,160.2166;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;28;-60.77927,-893.9528;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-1049.013,193.016;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;269.0231,-1120.742;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;57;408.7239,-1109.255;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;44;-894.7302,-43.89215;Float;False;Property;_Variationcolor;Variation color;1;0;Create;True;0;0;False;0;1,0.5,0,0.184;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;42;-885.2475,193.9371;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-825.0991,-299.9994;Float;True;Property;_Atlas;Atlas;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-72.10028,45.0998;Float;True;Property;_Normals;Normals;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-638.8769,97.19617;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;584.6132,-1107.404;Float;False;Wind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-30.18862,300.6029;Float;False;48;Wind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;53;8.802795,418.4017;Float;False;Constant;_Vector0;Vector 0;4;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;54;303.7151,47.08692;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;46;-307.0044,-53.29811;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;67;292.7819,217.4729;Float;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;63;689.2,-58.6;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;Motion Vectors;0;5;Motion Vectors;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;128;False;-1;255;False;-1;128;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=MotionVectors;False;0;;0;0;Standard;0;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;64;689.2,-58.6;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;Distortion;0;6;Distortion;2;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;True;4;1;False;-1;1;False;-1;4;1;False;-1;1;False;-1;True;1;False;-1;5;False;-1;False;False;False;False;False;True;3;False;-1;False;True;1;LightMode=DistortionVectors;False;0;;0;0;Standard;0;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;62;689.2,-58.6;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;DepthOnly;0;4;DepthOnly;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=DepthOnly;False;0;;0;0;Standard;0;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;65;689.2,-58.6;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;TransparentBackface;0;7;TransparentBackface;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;True;1;False;-1;False;False;False;False;False;True;1;LightMode=TransparentBackface;False;0;;0;0;Standard;0;13;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;60;689.2,-58.6;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;ShadowCaster;0;2;ShadowCaster;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;59;689.2,-58.6;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;META;0;1;META;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;;0;0;Standard;0;26;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;18;FLOAT3;0,0,0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT;0;False;23;FLOAT3;0,0,0;False;24;FLOAT;0;False;25;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;58;689.2,-58.6;Float;False;True;2;Float;ASEMaterialInspector;0;4;FAE/Tree Billboard;091c43ba8bd92c9459798d59b089ce4e;True;GBuffer;0;0;GBuffer;26;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;2;False;-1;255;False;-1;7;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=GBuffer;False;0;;0;0;Standard;18;Material Type,InvertActionOnDeselection;0;Energy Conserving Specular,InvertActionOnDeselection;0;Transmission,InvertActionOnDeselection;0;Surface Type;0;Receive Decals;1;Alpha Cutoff;1;Receives SSR;1;Specular AA;0;Specular Occlusion Mode;0;Distortion;0;Distortion Mode;0;Distortion Depth Test;0;Back Then Front Rendering;0;Blend Preserves Specular;1;Fog;1;Draw Before Refraction;0;Refraction Model;0;Vertex Position,InvertActionOnDeselection;1;0;9;True;True;True;True;True;True;False;False;True;False;26;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;18;FLOAT3;0,0,0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT;0;False;23;FLOAT3;0,0,0;False;24;FLOAT;0;False;25;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;61;689.2,-58.6;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;SceneSelectionPass;0;3;SceneSelectionPass;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;0;;0;0;Standard;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;66;689.2,-58.6;Float;False;False;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/HDSRPLit;091c43ba8bd92c9459798d59b089ce4e;True;Forward;0;8;Forward;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;2;False;-1;255;False;-1;7;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=Forward;False;0;;0;0;Standard;0;26;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;0;False;14;FLOAT;0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;18;FLOAT3;0,0,0;False;19;FLOAT;0;False;20;FLOAT;0;False;21;FLOAT;0;False;22;FLOAT;0;False;23;FLOAT3;0,0,0;False;24;FLOAT;0;False;25;FLOAT;0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;0
WireConnection;35;0;33;0
WireConnection;35;1;34;0
WireConnection;37;0;35;0
WireConnection;37;1;36;4
WireConnection;17;0;15;0
WireConnection;17;1;16;0
WireConnection;19;0;37;0
WireConnection;19;1;17;0
WireConnection;18;0;14;1
WireConnection;18;2;14;3
WireConnection;21;0;19;0
WireConnection;21;1;18;0
WireConnection;24;0;20;0
WireConnection;24;1;22;0
WireConnection;23;0;21;0
WireConnection;26;0;23;0
WireConnection;26;1;24;0
WireConnection;26;2;25;0
WireConnection;26;4;25;0
WireConnection;55;0;26;0
WireConnection;56;0;55;0
WireConnection;56;2;55;2
WireConnection;31;0;56;0
WireConnection;31;1;27;0
WireConnection;40;0;43;1
WireConnection;40;1;43;2
WireConnection;41;0;40;0
WireConnection;41;1;43;3
WireConnection;32;0;31;0
WireConnection;32;1;28;4
WireConnection;57;0;32;0
WireConnection;42;0;41;0
WireConnection;45;0;44;4
WireConnection;45;1;42;0
WireConnection;48;0;57;0
WireConnection;54;0;11;0
WireConnection;46;0;1;0
WireConnection;46;1;44;0
WireConnection;46;2;45;0
WireConnection;58;0;46;0
WireConnection;58;1;54;0
WireConnection;58;9;1;4
WireConnection;58;10;67;0
WireConnection;58;11;50;0
WireConnection;58;12;53;0
ASEEND*/
//CHKSM=B1F2B75B3EBDA0535F50DBB7B4359691E06C22B7