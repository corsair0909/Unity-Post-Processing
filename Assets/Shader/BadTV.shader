Shader "Unlit/BadTV"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float2 _ScanLineJitter;
            float2 _VerticalJump;
            fixed _HorizontalShake;
            float2 _ColorDrift;
            //周期函数，根据传入的x和y构造一个频率足够高的周期函数用来模拟抖动的周期性
            float nrand(float x, float y)
            {
                return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
            }

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed u = i.uv.x;
                fixed v = i.uv.y;
                //扫描线的周期抖动
                float jitter = nrand(v,_Time.x) * 2 - 1;
                jitter *= step(_ScanLineJitter.y,abs(jitter))*_ScanLineJitter.x;

                //VerticalJump其中x分量是时间，y分量是强度
                float jump = lerp(v,frac(v+_VerticalJump.x),_VerticalJump.y);
                float shake = (nrand(_Time.x, 2) - 0.5) * _HorizontalShake;
                //y分量是时间，x分量是强度
                float dirft = sin(jump+_ColorDrift.y)*_ColorDrift.x;
                
                fixed4 col1 = tex2D(_MainTex, frac(float2(u+jitter+shake,jump)));
                fixed4 col2 = tex2D(_MainTex, frac(float2(u+jitter+shake+dirft,jump)));
                return fixed4(col1.r,col2.g,col1.b,1);
            }
            ENDCG
        }
    }
}
