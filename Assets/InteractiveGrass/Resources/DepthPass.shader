Shader "Unlit/DepthPass"
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
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.proj = ComputeScreenPos(o.vertex);
				//Use this for linear one                        
				o.proj.z = COMPUTE_DEPTH_01;


				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return i.proj.zzzz;
			
			}
			ENDCG
		}
	}
}
