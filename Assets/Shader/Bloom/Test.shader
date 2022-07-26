Shader "Unlit/Test"
{
     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _blurTex;
            fixed _LuminanceThreshold;
            fixed _Alpha;
            fixed _Fractor; 
            fixed _blurSize;
            fixed _Lum;
            // ------------------------------提取亮度像素---------------------------
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            fixed Luminance(fixed4 color)
            {
                return 0.2125*color.r + 0.7154*color.g + 0.0721*color.b;
            }
            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
            fixed4 frag (v2f v) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, v.uv);
                fixed val = clamp(Luminance(col) - _LuminanceThreshold,0,1);
                return col*val;
            }
            // ------------------------------高斯模糊---------------------------
            struct v2fBlur
            {
                float4 pos : SV_POSITION;
                float2 uv[5] : TEXCOORD0;
            };

            v2fBlur HorizonBlur(appdata_img v)
            {
                v2fBlur o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.texcoord;
                o.uv[1] = v.texcoord + float2(_MainTex_TexelSize.x * 1,0.0f) * _blurSize;
                o.uv[2] = v.texcoord - float2(_MainTex_TexelSize.x * 1,0.0f) * _blurSize;
                o.uv[3] = v.texcoord + float2(_MainTex_TexelSize.x * 2,0.0f) * _blurSize;
                o.uv[4] = v.texcoord - float2(_MainTex_TexelSize.x * 2,0.0f) * _blurSize;
                return o;
            }

            v2fBlur VerticalBlur(appdata_img v)
            {
                v2fBlur o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.texcoord;
                o.uv[1] = v.texcoord + float2(0.0f,_MainTex_TexelSize.y * 1) * _blurSize;
                o.uv[2] = v.texcoord + float2(0.0f,_MainTex_TexelSize.y * 1) * _blurSize;
                o.uv[3] = v.texcoord + float2(0.0f,_MainTex_TexelSize.y * 2) * _blurSize;
                o.uv[4] = v.texcoord + float2(0.0f,_MainTex_TexelSize.y * 2) * _blurSize;
                return o;
            }

            fixed4 FragBlur(v2fBlur v) : SV_Target
            {
                float weight[3] = {0.4062,0.2442,0.0545};
                float3 color = tex2D(_MainTex,v.uv[0]).rgb;
                for(int it = 1 ; it < 3 ; it++)
                {
                    color +=tex2D(_MainTex,v.uv[it*2-1]).rgb * weight[it];
                    color +=tex2D(_MainTex,v.uv[it*2]).rgb * weight[it];
                }
                return fixed4(color,1);
            }

            struct v2fBloom
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;

            };        

            v2fBloom BloomVert(appdata_img v) 
            {
                v2fBloom o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord;
                o.uv.zw = v.texcoord;
                return o;
            }
        

            fixed4 BloomFrag(v2fBloom v):SV_Target
            {
                float4 mainColor = tex2D(_MainTex,v.uv.xy);
                float4 blurColor = tex2D(_blurTex,v.uv.zw);
                float4 finalColor = (mainColor + blurColor) * mainColor.a;
                return finalColor ;
            }
            struct v2fToneMapping
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;

            };     
            v2fToneMapping ACESToneMappingVert(appdata_img v) 
            {
                v2fToneMapping o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
            float3 CEToneMapping(float3 color, float adapted_lum) 
            {
                return 1 - exp(-adapted_lum * color);
            }
            float3 ACESToneMapping(float3 color,float Lum)
            {
                const float A = 2.51f;
                const float B = 0.03f;
                const float C = 2.43f;
                const float D = 0.59f;
                const float E = 0.14f;
                color *= Lum;
                return (color * (A * color + B)) / (color * (C * color + D) + E);
            }
            fixed4 ACESToneMappingFrag(v2fToneMapping v):SV_Target
            {
                fixed3 var_MainTex = tex2D(_MainTex,v.uv.xy).rgb;
                var_MainTex = ACESToneMapping(var_MainTex,_Lum);
                fixed3 var_BloomTex = tex2D(_blurTex,v.uv).rgb;
                return fixed4(var_MainTex+var_BloomTex,1);
            }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex HorizonBlur
            #pragma fragment FragBlur

            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex VerticalBlur
            #pragma fragment FragBlur

            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex BloomVert
            #pragma fragment BloomFrag

            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex ACESToneMappingVert
            #pragma fragment ACESToneMappingFrag
            ENDCG
        }
    }
}
