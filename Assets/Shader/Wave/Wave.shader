Shader "Unlit/Wave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off
        ZTest Always
        ZWrite Off

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
            float4 _MainTex_ST;
            fixed _DisFactor;
            fixed _TimeFactor;
            fixed _SinFactor;
            fixed _WaveWidth;
            fixed _WaveSpeed;
            fixed _CurWaveDis;
            float4 _startPos;
            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 dv = _startPos.xy - i.uv; //波浪运动方向的向量
                dv = dv * float2(_ScreenParams.x/_ScreenParams.y,1);//按照屏幕长宽比进行缩放
                float dis = sqrt(dv.x*dv.x + dv.y*dv.y);
                float sinFactor = sin(dis * _DisFactor + _Time.y * _TimeFactor) * _SinFactor * 0.01;
                //当前波浪距离 - dis = 可以理解为波浪宽度 ，若结果小于指定宽度说明该位置需要收到波浪影响，距离因子等于1，否则距离因子等于0
                //偏移量也就等于0
                float disFactor = clamp(_WaveWidth - abs(_CurWaveDis-dis),0,1);//小于波形的部分不发生变化
                float offset = normalize(dv) * sinFactor * disFactor;
                i.uv += offset;
                return tex2D(_MainTex,i.uv);
            }
            ENDCG
        }
    }
}
