Shader "Unlit/GodRay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
           CGINCLUDE

            #include "UnityCG.cginc"
            struct v2fLum
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            struct v2fBlur
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 blurOffset : TEXCOORD1;
            };
        

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BlurTex;

            float3 _LightPos;
            half4 _ThresholdCol;
            half4 _LightCol;
            float _LightRadius;
            float _LightFactor;
            float _PowFactor;
            float2 _Offset;
            float _BlurSpeard;
        

            v2fLum vertLum (appdata_img v)
            {
                v2fLum o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            float4 fragLum (v2fLum i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                float LightDistance = length(_LightPos.xy - i.uv);
                float LightControl = saturate(_LightRadius - LightDistance);
                //根据距离控制颜色亮度
                half4 DistanceCol = saturate(col - _ThresholdCol) * LightControl;
                half ColGrayVal = Luminance(DistanceCol.rgb);
                ColGrayVal = pow(ColGrayVal,_PowFactor);
                return float4(ColGrayVal,ColGrayVal,ColGrayVal,1);
            }

            v2fBlur vertBlur (appdata_img v)
            {
                v2fBlur o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.blurOffset = _Offset * (_LightPos.xy - v.texcoord) * _BlurSpeard;
                return o;
            }
            float4 fragBlur (v2fBlur i) : SV_Target
            {
                float2 uv = i.uv;
                half4 col = half4(0,0,0,0);
                for (int it = 0; it < 6; ++it)
                {
                    col += tex2D(_MainTex,uv);
                    //UV的偏移值 = 偏移像素*方向
                    uv.xy += i.blurOffset;
                }
                return col/6;
            }

            struct v2fCombine
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD;
            };

            v2fCombine vertCombine (appdata_img v)
            {
                v2fCombine o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord;
                o.uv.zw = v.texcoord;
                return o;
            }
            float4 fragCombine (v2fCombine i) : SV_Target
            {
                half4 MainCol = tex2D(_MainTex,i.uv.xy);
                half4 BlurCol = tex2D(_BlurTex,i.uv.zw);
                return MainCol + _LightFactor * BlurCol * _LightCol;
            }
        ENDCG

    SubShader
    {
        Cull Off
        ZTest Always
        ZWrite Off
        
        Tags { "RenderType"="Opaque" }
        LOD 100
 
        Pass
        {
            //亮度提取
            CGPROGRAM
            #pragma vertex vertLum
            #pragma fragment fragLum
            ENDCG
        }
        Pass
        {
            //亮度提取
            CGPROGRAM
            #pragma vertex vertBlur
            #pragma fragment fragBlur
            ENDCG
        }
        Pass
        {
            //亮度提取
            CGPROGRAM
            #pragma vertex vertCombine
            #pragma fragment fragCombine
            ENDCG
        }
    }
}
