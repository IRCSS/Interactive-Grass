// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/InteractiveGrass"
{
	Properties
	{
		_Color ("Color",Color ) = (0.1 ,0.7 ,0.1,1.0)
		_MainTex ("noise one", 2D) = "white" {}
		_Noise("noise two", 2D) = "white" {}
		_Distortation("distortaion", 2D) = "white" {}
		_TilingN1("Tiling of noise one", Float) = 2
			_TilingN2("Tiling of noise two", Float) = 2
			_Tiling3("Wind Noise Tiling", Float) =1
			_stackOffset("distance between the stacks", Float) = 0.085
			_WindMovement("Wind Movement Speed", Float) = 1
	}
	SubShader
	{
		
		
			pass{

			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }

			Fog{ Mode Off }
			ZWrite On ZTest Less Cull Off
			Offset 1, 1

			CGPROGRAM

				float _stackOffset;
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_shadowcaster
#pragma fragmentoption ARB_precision_hint_fastest

#include "UnityCG.cginc"

			struct v2f
		{
			V2F_SHADOW_CASTER;
		};

#define NumberOfStacks 7
#define stackOffset _stackOffset

		v2f vert(appdata_base v)
		{
			v2f o;
			v.vertex.xyz = v.normal *NumberOfStacks* stackOffset*0. + v.vertex.xyz;
			TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
		}

		float4 frag(v2f i) : COLOR
		{
			SHADOW_CASTER_FRAGMENT(i)
		}

			ENDCG

		}

	

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" "RenderType" = "Opaque" }
			LOD 100
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#define SHADOWS_SCREEN
			
			#include "AutoLight.cginc"
#include "Lighting.cginc"
			#include "UnityCG.cginc"

			float _stackOffset;
#define NumberOfStacks 7
#define stackOffset _stackOffset

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal : NORMAL;
				float4 tangent : TANGENT;
			};

	struct v2g
	{
			float2 uv : TEXCOORD0;
			float4 pos : SV_POSITION;
			float4 objPos : TEXCOORD1;
			float4 shadowCoordMax : TEXCOORD2;
			float3 normal : TEXCOORD3;
			float4 tangent : TEXCOORD4;
		
			SHADOW_COORDS(5)
			
	};

	struct g2f
	{
		float2 uv : TEXCOORD0;
		float4 pos : SV_POSITION;
		float4 worldPos : TEXCOORD1;
		float3 normal : TEXCOORD3;
		float4 tangent : TEXCOORD4;
		float3 color : TEXCOORD2;
		float4 tracesCoordinate : TEXCOORD6;
		SHADOW_COORDS(5)
	};


	sampler2D _MainTex;

	float4 _MainTex_ST;
	sampler2D _Distortation;
	sampler2D _Noise;
	float _TilingN1;
	float _TilingN2;
	float4 _Color;
	float _Tiling3;
	float _WindMovement;

	uniform sampler2D _TracesCamTex;
	uniform float4x4 _TracesWorldToViewMatrix;

			v2g vert (appdata v)
			{
				v2g o;
				o.objPos =v.vertex;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o._ShadowCoord = ComputeScreenPos(o.pos);
				
				float4 maxDisplacement = v.vertex + v.normal * stackOffset*NumberOfStacks;
				maxDisplacement = UnityObjectToClipPos(maxDisplacement);
				o.shadowCoordMax = ComputeScreenPos(maxDisplacement);
				o.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				o.normal = UnityObjectToWorldNormal(v.normal);

				return o;
			}

			#define SetG2FPar(o, i) o.uv = i.uv;o.normal = i.normal;o.tangent = i.tangent; o.tracesCoordinate = mul(_TracesWorldToViewMatrix,o.worldPos)
#define UnityObject2Wrold(o) mul(unity_ObjectToWorld, float4(o.xyz,1.0))

			[maxvertexcount(27)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> tristream) {
		
				g2f o;
				
				o.pos =input[0].pos;
				o.color = float3(1.,1.,1.);
				o._ShadowCoord = input[0]._ShadowCoord;
				o.worldPos = UnityObject2Wrold(input[0].objPos);

				SetG2FPar(o, input[0]);

				tristream.Append(o);

					o.pos = input[1].pos;
				o.color = float3(1., 1., 1.);
				o._ShadowCoord = input[1]._ShadowCoord;
				SetG2FPar(o, input[1]);
				o.worldPos = UnityObject2Wrold(input[1].objPos);
				tristream.Append(o);

					o.pos = input[2].pos;
				o.color = float3(1., 1., 1.);
				o._ShadowCoord = input[2]._ShadowCoord;
				SetG2FPar(o, input[2]);
				o.worldPos = UnityObject2Wrold(input[2].objPos);
				tristream.Append(o);
				tristream.RestartStrip();

				float4 normal = float4(cross(input[1].objPos - input[0].objPos, input[2].objPos - input[0].objPos),0.);

				int numberOfStacks = NumberOfStacks;
				float4 objSpace;
				float offset = stackOffset;
					for (float i = 1; i <= numberOfStacks; i++) {

						float4 offsetVector = normal * offset*i;

						
						objSpace = input[0].objPos + offsetVector;
						o.pos = UnityObjectToClipPos(objSpace);
						o._ShadowCoord = lerp(input[0]._ShadowCoord, input[0].shadowCoordMax, i/ numberOfStacks);
						o.color = float(1.- i/numberOfStacks).xxx;
						
						o.worldPos = UnityObject2Wrold(objSpace);
						SetG2FPar(o, input[0]);
						tristream.Append(o);

				
						objSpace = input[1].objPos + offsetVector;
						o.color = float(1. - i / numberOfStacks).xxx;
						o.pos = UnityObjectToClipPos(objSpace);
						o._ShadowCoord = lerp(input[1]._ShadowCoord, input[1].shadowCoordMax, i / numberOfStacks);
						
						o.worldPos = UnityObject2Wrold(objSpace);
						SetG2FPar(o, input[1]);
						tristream.Append(o);

					
						objSpace = input[2].objPos + offsetVector;
						o.color = float(1. - i / numberOfStacks).xxx;
						o.pos = UnityObjectToClipPos(objSpace);
						o._ShadowCoord = lerp(input[2]._ShadowCoord, input[2].shadowCoordMax, i / numberOfStacks);
						
						o.worldPos = UnityObject2Wrold(objSpace);
						SetG2FPar(o, input[2]);
						tristream.Append(o);
						tristream.RestartStrip();
				}
			}

			float3	ReturnFragmentNormal(float2 distortation, g2f i) {
				distortation *=3.;
					float3 binormal = cross(i.normal, i.tangent.xyz) * i.tangent.w;
				return normalize(
					distortation.x * i.tangent +
					1. * i.normal +
					distortation.y * binormal
				);
			}
			
			// Single textre Triplanar for Albedo textures. 
			float4 Triplanar(sampler2D Texture, float Tiling, float3 offset, float3 Pos, float3 Normals) {
				float4 albedoX = tex2D(Texture, Pos.zy*Tiling + offset.zy);
				float4 albedoY = tex2D(Texture, Pos.xz*Tiling+ offset.xz);
				float4 albedoZ = tex2D(Texture, Pos.xy*Tiling + offset.xy);


				float3 triW = abs(Normals);
				triW /= (triW.x + triW.y + triW.z);
				return albedoX * triW.x + albedoY * triW.y + albedoZ * triW.z;
			}

			float2 ReturnGrassDisDelta(sampler2D t, float2 uv , float middle) {
				float2 toReturn = float2(0., 0.);
				toReturn.x = tex2D(t, uv + float2(0.01, 0.)).x - middle;
				toReturn.y = tex2D(t, uv + float2(0., 0.01)).y - middle;
				return toReturn.xy;
			}

			fixed4 frag (g2f i) : SV_Target
			{
				// sample the texture
			
				float2 tracesCamUV = (i.tracesCoordinate.xy + 1.0) / 2.0;
				float3 tracesMap = tex2D(_TracesCamTex, tracesCamUV);
				float deltaStepedOn = ReturnGrassDisDelta(_TracesCamTex, tracesCamUV, tracesMap.x);
				
				float2 dis = Triplanar(_Distortation, _Tiling3, _Time.xxx*_WindMovement, i.worldPos, i.normal);
				dis -= deltaStepedOn;
				float displacementStrengh = 0.1* (((sin(_Time.y) + sin(_Time.y*0.5 + 1.051))/4.0) +0.5f);
				dis = dis * displacementStrengh*(1.0 - i.color.xx);  


				float3 n = ReturnFragmentNormal(dis, i);

				fixed4 col = Triplanar(_MainTex, _TilingN1, float3(dis.x, 0., dis.y), i.worldPos, i.normal);
			
				float3 noise = Triplanar(_Noise, _TilingN2, float3(dis.x, 0., dis.y),i.worldPos, i.normal);
			
			if (step(col.x+noise.x*0.3 + tracesMap.x*0.5,	i.color.x) <= .0)discard;

			
			float nl = dot(n, _WorldSpaceLightPos0);
		
			col.xyz = ( saturate(nl) * _LightColor0) *float3(_Color.x+(noise.x*0.25), _Color.y, _Color.z) ;
			col.xyz = lerp(col.xyz, col.xyz *0.25,i.color);

			float3 shadowCoord = i._ShadowCoord.xyz / i._ShadowCoord.w;
			float shadowmap = tex2D(_ShadowMapTexture, shadowCoord.xy);
			col.xyz = lerp(col.xyz, col.xyz* shadowmap, float3(0.7,0.67,0.45)) + float3(0.1, 0.1, 0.15);

			
			

			return col;
			}
			ENDCG
		}



		
	} Fallback "VertexLit"
}
