Shader "Unlit/GlobalFog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            ZTest Always
            ZWrite Off
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 depthUV : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float4 Ray : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            half4 _fogColor;
            fixed _fogStart;
            fixed _forEnd;
            fixed _Density;
            float4x4 _furstum;
            float4 _MainTex_TexelSize;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.depthUV = v.texcoord;
                
                fixed index = 0;
                if (v.texcoord.x < 0 && v.texcoord.y > 0)
                {
                    index = 0;
                }
                else if(v.texcoord.x > 0 && v.texcoord.y > 0)
                {
                    index = 1;
                }
                else if(v.texcoord.x < 0 && v.texcoord.y < 0)
                {
                    index = 2;
                }
                else if (v.texcoord.x > 0 && v.texcoord.y < 0)
                {
                    index = 3;
                }
                o.Ray = _furstum[index];
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.depthUV));
                float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.Ray.xyz;

                float fogDensity = (_forEnd - worldPos.y)/(_forEnd - _fogStart);
                fogDensity = saturate(fogDensity * _Density);
                
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 finalColor = lerp(col,_fogColor,fogDensity);
                return finalColor;
            }
            ENDCG
        }
    }
}
