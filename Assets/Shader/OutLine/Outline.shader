Shader "Unlit/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeOnly("EdgeOnly",float) = 1.0
        _EdgeColor("EdgeColor",color) = (0,0,0,1)
    }
    SubShader
    {
        ZTest Always
        Cull Off
        ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed _EdgeOnly;
            fixed4 _BackColor;
            fixed4 _EdgeColor;
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            

            struct v2f
            {
                float2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed Luminance(fixed4 color)
            {
                return  0.299 * color.r + 0.587*color.g + 0.0114*color.b;
            }

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.texcoord + _MainTex_TexelSize.xy * half2(-1,-1);
                o.uv[1] = v.texcoord + _MainTex_TexelSize.xy * half2(0,-1);
                o.uv[2] = v.texcoord + _MainTex_TexelSize.xy * half2(1,-1);
                o.uv[3] = v.texcoord + _MainTex_TexelSize.xy * half2(-1,0);
                o.uv[4] = v.texcoord + _MainTex_TexelSize.xy * half2(0,0);
                o.uv[5] = v.texcoord + _MainTex_TexelSize.xy * half2(1,0);
                o.uv[6] = v.texcoord + _MainTex_TexelSize.xy * half2(-1,1);
                o.uv[7] = v.texcoord + _MainTex_TexelSize.xy * half2(0,1);
                o.uv[8] = v.texcoord + _MainTex_TexelSize.xy * half2(1,1);
                return o;
            }

            fixed sobel(v2f i)
            {
                fixed Gx[9] =
                    { -1, 0, 1,
                      -2, 0, 2,
                      -1, 0, 1
                    };
                fixed Gy[9] =
                    { -1, -2, -1,
                       0, 0, 0,
                       1, 2, 1
                    };
                fixed texColor;
                fixed edgeGx=0;
                fixed edgeGy=0;
                for (int it = 0; it<9; it++)
                {
                    texColor = Luminance(tex2D(_MainTex,i.uv[it]));
                    edgeGx += texColor * Gx[it];
                    edgeGy += texColor * Gy[it];
                }
                fixed edge = 1-(abs(edgeGx)+abs(edgeGy));//反色，否则边缘是白色的
                return edge;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed edge = sobel(i);
                fixed4 color = lerp(_EdgeColor,tex2D(_MainTex,i.uv[4]),edge);
                color = lerp(tex2D(_MainTex,i.uv[4]),color,_EdgeOnly);
                return color;

            }
            ENDCG
        }
    }
}
