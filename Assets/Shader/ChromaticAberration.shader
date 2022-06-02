Shader "Unlit/ChromaticAberration"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _rgbSplit("rgbSplit",float) = 0.1
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _rgbSplit;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                float2 center = i.uv * 2 - 1 ;//将uv从左下角移动到中间，取值范围[-1,1]
                //同方向向量的点击结果等于其平方和，
                //uv是float2向量，其同方向点积结果为 x^2 + y^2 = 圆标准方程
                float radius = dot(center,center);
                //radius = radius * radius * radius ; //todo 不明白
                
                //对RGB三个通道分别进行偏移
                half4 col;
                half colR = tex2D(_MainTex,i.uv+ float2(_rgbSplit,_rgbSplit) * 0.1 * radius).r;
                half colG = tex2D(_MainTex,i.uv).g;
                half colB = tex2D(_MainTex,i.uv + float2(_rgbSplit,_rgbSplit)*0.1 * radius).b;
                col = fixed4(colR,colG,colB,1);
                return col;
            }
            ENDCG
        }
    }
}
