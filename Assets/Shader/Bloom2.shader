Shader "Unlit/Bloom2"
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
            fixed4 _BloomColor;
            sampler2D _BlurTex;
            float4 _offsets;
            fixed _LuminanceThreshold;
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



            struct v2fBlur
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 uv01 : TEXCOORD1;
                float4 uv23 : TEXCOORD3;
            };

            v2fBlur BlurVertex(appdata_img v)
            {
                v2fBlur o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                _offsets *= _MainTex_TexelSize;
                o.uv01 = v.texcoord.xyxy + _offsets.xyxy * float4(1,1,-1,-1);
                o.uv23 = v.texcoord.xyxy + _offsets.xyxy * float4(1,1,-1,-1) * 2;
                return o;
            }

            fixed4 BlurFrag(v2fBlur i) : SV_Target
            {
                float4 color = float4(0,0,0,0);
                color += tex2D(_MainTex,i.uv);
                color += tex2D(_MainTex,i.uv01.xy);
                color += tex2D(_MainTex,i.uv01.zw);
                color += tex2D(_MainTex,i.uv23.xy);
                color += tex2D(_MainTex,i.uv23.zw);
                return color;
            }


            struct v2fbloom
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;

            };

            v2fbloom bloomVert(appdata_img v)
            {
                v2fbloom o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord;
                o.uv.zw = v.texcoord;
                return o;
            }

            fixed4 bloomFrag(v2fbloom i) : SV_Target
            {
                fixed3 mainColor = tex2D(_MainTex,i.uv.xy);
                fixed3 blurColor = tex2D(_BlurTex,i.uv.zw);
                fixed3 finalColor = mainColor + (blurColor * _BloomColor);
                return fixed4(finalColor,1);
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
            #pragma vertex BlurVertex
            #pragma fragment BlurFrag
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex bloomVert
            #pragma fragment bloomFrag
            ENDCG
        }
    }
}
