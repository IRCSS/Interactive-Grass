// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/SheepFluff"
{
	Properties
	{
		_Color ("Color",Color ) = (0.1 ,0.7 ,0.1,1.0)
		_MainTex ("noise one", 2D) = "white" {}
		_Noise("noise two", 2D) = "white" {}
		_Distortation("distortaion", 2D) = "white" {}
		_TilingN1("Tiling of noise one", Float) = 2
			_TilingN2("Tiling of noise two", Float) = 2
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
#define stackOffset 0.03

		v2f vert(appdata_base v)
		{
			v2f o;
			v.vertex.xyz = v.normal *NumberOfStacks* stackOffset*0.25 + v.vertex.xyz;
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


#define NumberOfStacks 7
#define stackOffset 0.03

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
		float3 normal : TEXCOORD3;
		float4 tangent : TEXCOORD4;
		float3 color : TEXCOORD2;
		SHADOW_COORDS(5)
	};


	sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _Distortation;
	sampler2D _Noise;
	float _TilingN1;
	float _TilingN2;
	float4 _Color;

	
			v2g vert (appdata v)
			{
				v2g o;
				o.objPos =v.vertex;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//o._ShadowCoord = mul(unity_WorldToShadow[0], mul(unity_ObjectToWorld, v.vertex));
				//TRANSFER_SHADOW(o);
				o._ShadowCoord = ComputeScreenPos(o.pos);
				
				float4 maxDisplacement = v.vertex + v.normal * stackOffset*NumberOfStacks;
				maxDisplacement = UnityObjectToClipPos(maxDisplacement);
				o.shadowCoordMax = ComputeScreenPos(maxDisplacement);
				o.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				o.normal = UnityObjectToWorldNormal(v.normal);

				return o;
			}

			#define SetG2FPar(o, i) o.uv = i.uv;o.normal = i.normal;o.tangent = i.tangent;
		

			[maxvertexcount(27)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> tristream) {
		
				g2f o;
				
				o.pos =input[0].pos;
				o.color = float3(1.,1.,1.);
				o._ShadowCoord = input[0]._ShadowCoord;
				SetG2FPar(o, input[0]);

				tristream.Append(o);

					o.pos = input[1].pos;
				o.color = float3(1., 1., 1.);
				o._ShadowCoord = input[1]._ShadowCoord;
				SetG2FPar(o, input[1]);

				tristream.Append(o);

					o.pos = input[2].pos;
				o.color = float3(1., 1., 1.);
				o._ShadowCoord = input[2]._ShadowCoord;
				SetG2FPar(o, input[2]);

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
						SetG2FPar(o, input[0]);
						tristream.Append(o);

				
						objSpace = input[1].objPos + offsetVector;
						o.color = float(1. - i / numberOfStacks).xxx;
						o.pos = UnityObjectToClipPos(objSpace);
						o._ShadowCoord = lerp(input[1]._ShadowCoord, input[1].shadowCoordMax, i / numberOfStacks);
						SetG2FPar(o, input[1]);
						tristream.Append(o);

					
						objSpace = input[2].objPos + offsetVector;
						o.color = float(1. - i / numberOfStacks).xxx;
						o.pos = UnityObjectToClipPos(objSpace);
						o._ShadowCoord = lerp(input[2]._ShadowCoord, input[2].shadowCoordMax, i / numberOfStacks);
						SetG2FPar(o, input[2]);

						tristream.Append(o);
						tristream.RestartStrip();
				}
			}

			float3	ReturnFragmentNormal(float2 distortation, g2f i) {
				distortation *= 5.;
					float3 binormal = cross(i.normal, i.tangent.xyz) * i.tangent.w;
				return normalize(
					distortation.y * i.tangent +
					1. * i.normal +
					distortation.x * binormal
				);
			}
			


			fixed4 frag (g2f i) : SV_Target
			{
				// sample the texture
			
				float2 dis = tex2D(_Distortation,i.uv  *0.6+ _Time.xx*3.3);
				float displacementStrengh = 0.22* (((sin(_Time.y) + sin(_Time.y*0.5 + 1.051))/4.0) +0.5f);
				dis = dis * displacementStrengh*(1.0 - i.color.xx);
				fixed4 col = tex2D(_MainTex, i.uv *_TilingN1 + dis.xy);
				float3 noise = tex2D(_Noise, i.uv *_TilingN2 + dis.xy);
				
			if (step(col.x+noise.x*0.3, i.color.x) <= .0)discard;
			col.xyz = ((1.0- i.color)+ saturate(dot(_WorldSpaceLightPos0, ReturnFragmentNormal(dis,i))) * _LightColor0) * float3(_Color.x+(noise.x*0.25), _Color.y, _Color.z);
	
			float3 shadowCoord = i._ShadowCoord.xyz / i._ShadowCoord.w;
			float shadowmap = tex2D(_ShadowMapTexture, shadowCoord.xy);
			col.xyz = lerp(col.xyz, col.xyz* shadowmap, float3(0.7,0.67,0.45));

			

			return col;
			}
			ENDCG
		}



		
	} Fallback "VertexLit"
}
