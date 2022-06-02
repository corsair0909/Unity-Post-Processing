Shader "Unlit/Outline2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed _TheShold;
            fixed4 _EdgeColor;
            fixed4 _BackColor;
            fixed _SampleDistance;
            fixed4 _Sensitivity;
            sampler2D _CameraDepthNormalsTexture;
            
            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 uv = v.texcoord;
                o.uv[0] = uv;
                #if UNITY_UV_STARTS_AT_TOP
                    if (_MainTex_TexelSize.y<0)
                    {
                        v.texcoord.y = 1 - v.texcoord.y;
                    }
                #endif
                o.uv[1] = uv + _MainTex_TexelSize.xy * float2(1,1) * _SampleDistance;
                o.uv[2] = uv + _MainTex_TexelSize.xy * float2(-1,-1) * _SampleDistance;
                o.uv[3] = uv + _MainTex_TexelSize.xy * float2(-1,1) * _SampleDistance;
                o.uv[4] = uv + _MainTex_TexelSize.xy * float2(1,-1) * _SampleDistance;
                return o;
            }

            fixed CheckSample(float4 sample1 , float4 sample2)
            {
                float2 NormalVal1 = sample1.xy;
                float DepthVal1 = DecodeFloatRG(sample1.zw);
                float2 NormalVal2 = sample2.xy;
                float DepthVal2 = DecodeFloatRG(sample2.zw);

                float2 isNormals = abs(NormalVal1 - NormalVal2)* _Sensitivity.y;
                int Normals = (isNormals.x + isNormals.y) < _TheShold;
                float isDepth = abs(DepthVal1 - DepthVal2) * _Sensitivity.x;
                int Depth = isDepth < _TheShold;

                return Normals * Depth ? 1 : 0;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 Sample1 = tex2D(_CameraDepthNormalsTexture,i.uv[1]);
                float4 Sample2 = tex2D(_CameraDepthNormalsTexture,i.uv[2]);
                float4 Sample3 = tex2D(_CameraDepthNormalsTexture,i.uv[3]);
                float4 Sample4 = tex2D(_CameraDepthNormalsTexture,i.uv[4]);

                int edge = 1;
                edge *= CheckSample(Sample1,Sample2);
                edge *= CheckSample(Sample3,Sample4);

                fixed4 EdgeColor = lerp(_EdgeColor,tex2D(_MainTex,i.uv[0]),edge);
                fixed4 OnlyColor = lerp(_EdgeColor,_BackColor,edge);
                return lerp(EdgeColor,OnlyColor,_EdgeOnly);
            }
            ENDCG
        }
    }
}
