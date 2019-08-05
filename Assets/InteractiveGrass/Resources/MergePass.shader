Shader "Passes/MergePass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			uniform sampler2D _TracesCamDepth;
			uniform sampler2D _TracesIntermidate;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
			col.xyz -= float4(0.05, 0.05, 0.05, 0.05)*0.1;
			
			float depth = tex2D(_TracesCamDepth, i.uv);
			float4 tracesPass = tex2D(_TracesIntermidate, i.uv);

			float collisionDetector = 1.0-step(0.05, abs(depth - tracesPass.w));

			col.xy = col.xy +tracesPass.xy * collisionDetector*0.45;
			col.xyz = saturate(col.xyz);
				return col;
			}
			ENDCG
		}
	}
}
