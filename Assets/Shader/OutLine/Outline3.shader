Shader "Unlit/Outline3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            
            sampler2D _BlurTex;
            sampler2D _SrcTex;

            fixed _BlurSize;
            fixed4 _OutlineColor;
            fixed _outlinePower;

            v2f Horizontalvert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.texcoord;
                o.uv[1] = v.texcoord + float2(0.0f,_MainTex_TexelSize.y * 1.0f) * _BlurSize;
                o.uv[2] = v.texcoord - float2(0.0f,_MainTex_TexelSize.y * 1.0f) * _BlurSize;
                o.uv[3] = v.texcoord + float2(0.0f,_MainTex_TexelSize.y * 2.0f) * _BlurSize;
                o.uv[4] = v.texcoord - float2(0.0f,_MainTex_TexelSize.y * 2.0f) * _BlurSize;
                return o;
            }
        
            v2f Verticalvert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.texcoord;
                o.uv[1] = v.texcoord + float2(_MainTex_TexelSize.x * 1.0f,0.0f) * _BlurSize;
                o.uv[2] = v.texcoord - float2(_MainTex_TexelSize.x * 1.0f,0.0f) * _BlurSize;
                o.uv[3] = v.texcoord + float2(_MainTex_TexelSize.x * 1.0f,0.0f) * _BlurSize;
                o.uv[4] = v.texcoord - float2(_MainTex_TexelSize.x * 1.0f,0.0f) * _BlurSize;
                return o;
            }
        
            fixed4 Frag (v2f i) : SV_Target
            {
                fixed weight[3] = {0.4026, 0.2442, 0.0545};
                fixed3 sum  = tex2D(_MainTex,i.uv[0]).rgb * weight[0];
                for (int it = 1; it < 3; it++)
                {
                    sum += tex2D(_MainTex,i.uv[it*2-1]).rgb * weight[it];
                    sum += tex2D(_MainTex,i.uv[it*2]).rgb * weight[it];
                }
                return fixed4(sum,1.0f);
            }

            struct v2f_Cull
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
        
            v2f_Cull CullVert (appdata_img v)
            {
                v2f_Cull o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
            fixed4 CullFrag (v2f_Cull i) : SV_Target
            {
                fixed4 MainTex = tex2D(_MainTex, i.uv);//原图
                fixed4 BlurTex = tex2D(_BlurTex, i.uv);//模糊图
                fixed4 SrcTex = tex2D(_SrcTex, i.uv);//rendertexture图
                //模糊图-rendertexture = 模糊膨胀出来的部分（描边）
                fixed4 outlineColor = (BlurTex - SrcTex) * _OutlineColor * _outlinePower;
                fixed4 finalColor = saturate(outlineColor) + MainTex;
                return finalColor;
            }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex Horizontalvert
            #pragma fragment Frag
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex Verticalvert
            #pragma fragment Frag
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex CullVert
            #pragma fragment CullFrag
            ENDCG
        }
    }
}
