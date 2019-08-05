Shader "Unlit/recieveShadowMapWithOutline"

{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags{ "LightMode" = "ForwardBase"
		"RenderType" = "Opaque"
	}
		LOD 100

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
		// make fog work
#pragma multi_compile_fog
#define SHADOWS_SCREEN
#include "AutoLight.cginc"
#include "UnityCG.cginc"

		struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		UNITY_FOG_COORDS(1)
			SHADOW_COORDS(5)
			float4 pos : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		TRANSFER_SHADOW(o);
		UNITY_TRANSFER_FOG(o,o.pos);
		return o;
	}

	float sampleEdge(sampler2D tex, float2 uv, float Offset) {

		float mi = 1000.;
		float ma = -100.;
		float x, y;
		for (y = -1.; y <= 1.; y += 1.0)
		{
			for (x = -1.; x <= 1.; x += 1.0)
			{
				float offsets = Offset / _ScreenParams.xy;

				float v = tex2D(tex, uv + float2(x, y)*offsets);
				mi = min(v, mi);
				ma = max(v, ma);
			}
		}

		return abs(ma - mi);
	}

	fixed4 frag(v2f i) : SV_Target
	{
		// sample the texture
		fixed4 col = tex2D(_MainTex, i.uv);
	float3 shadowCoord = i._ShadowCoord.xyz / i._ShadowCoord.w;

	float shadowmap = tex2D(_ShadowMapTexture, shadowCoord.xy);
	float thickness = 20.;
	float e = sampleEdge(_ShadowMapTexture, shadowCoord.xy, thickness / i._ShadowCoord.w);
	col.xyz = lerp(pow(col.xyz, 3.6)*0.45, col.xyz, shadowmap);
	col.xyz = lerp(col.xyz, float3(.1,0.2,0.3), e);
	UNITY_APPLY_FOG(i.fogCoord, col);
	return col;
	}
		ENDCG
	}
	}   FallBack "VertexLit"
}