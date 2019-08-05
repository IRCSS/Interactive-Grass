// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/TracePass"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="" }
		LOD 100

		Pass
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"

		struct appdata
			{
			float4 vertex : POSITION;
			};

		struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 proj : TEXCOORD2;
				float4 obj : TEXCOORD1;
			};

		v2f vert(appdata v)
			{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.proj = ComputeScreenPos(o.vertex);
			//Use this for linear one                        
			o.proj.z = COMPUTE_DEPTH_01;
	
			o.obj = v.vertex;
			return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float dis = length(i.obj);
				return float4(1.0-pow(smoothstep(0.0,1.42,dis),1.0).x, 0.0, 0.0, i.proj.z);

			}
		ENDCG
		}
	}
}
