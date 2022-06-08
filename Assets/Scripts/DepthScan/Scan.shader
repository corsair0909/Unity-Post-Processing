Shader "Unlit/Scan"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed("Speed",Range(0.001,8)) = 0.001
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
                float2 depthuv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            fixed _ScanValue;
            fixed _ScanLineWidth;
            fixed _ScanLineStranger;
            fixed4 _ScanColor;
            fixed _Speed;
            

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.depthuv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.depthuv);
                depth = Linear01Depth(depth);
                fixed4 col = tex2D(_MainTex, i.uv);
                //float pos = (_Time.y * _Speed * 1000 % 1000) * 0.001;
                // if (depth > _ScanValue && depth < _ScanValue+_ScanLineWidth)
                // {
                //     fixed3 Line = col * _ScanLineStranger * _ScanColor;
                //     return fixed4(Line,1);
                // }

                //效果相等
                float dif = abs(depth - _ScanValue);//深度和当前扫描值的差
                // float flag = step(_ScanLineWidth,dif);//小于width返回0，，大于返回1
                // float3 Line = col * flag + _ScanLineStranger * _ScanColor * (1-flag);

                float smoothFactor = 0.001f;
                float line1 = _ScanValue;
                float lineEdge1 = line1+smoothFactor;//上边界
                
                float line2 = _ScanValue + _ScanLineWidth;
                float lineEdge2 = line2+smoothFactor;//下边界

                float value = smoothstep(line1,lineEdge1,dif) - smoothstep(line2,lineEdge2,dif);//扫描线范围及是否显示控制
                float3 Line = lerp(col,_ScanColor*_ScanLineStranger,value);
                
                
                return fixed4(Line,1);
            }
            ENDCG
        }
    }
}
