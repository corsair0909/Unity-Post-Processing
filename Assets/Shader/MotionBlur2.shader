Shader "Unlit/MotionBlur2"
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            fixed _BlurSize;

            sampler2D _CameraDepthTexture;
            float4x4 _PreVpMatrix;
            float4x4 _CurInverseVPMatrix;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 depthUV : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
            };
            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.depthUV = v.texcoord;
                //ComputeScreenPos函数返回齐次坐标系下的屏幕坐标
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.depthUV);
                depth = Linear01Depth(depth);
                //得到当前的NDC坐标，NDC坐标是[-1,1]之间的坐标（标准正方形）
                //float4 CurNDCpos = float4(i.uv.x * 2 - 1 ,i.uv.y * 2 - 1 , depth * 2 - 1 , 1 );
                float4 CurNDCpos = (i.screenPos/i.screenPos.w) * 2 - 1;
                float4 worldPos = mul(_CurInverseVPMatrix,CurNDCpos);//根据当前NDC坐标和VP逆矩阵求出世界坐标
                worldPos.xy / worldPos.w;
                
                // float3 CurNDCpos = (i.screenPos/i.screenPos.w) * 2 - 1 ;
                // float3 farClipVec = CurNDCpos *  _ProjectionParams.z;//从屏幕坐标指向远平面的向量
                // float3 ViewClip = mul(unity_CameraInvProjection,farClipVec.xyzz).xyz;//转换到视角空间（相机空间）
                // float3 viewPos = depth * ViewClip;//求出屏幕坐标在视角空间的位置
                // float3 worldPos = mul(UNITY_MATRIX_I_V,float4(viewPos,1)).xyz;//逆矩阵求出世界空间位置

                float4 lastPos = mul(_PreVpMatrix,worldPos);//根据世界坐标求出上一帧该位置的NDC坐标
                float4 lastNDCpos = lastPos/lastPos.w;
                float2 Speed = (lastNDCpos.xy - CurNDCpos.xy) * 0.5f;
                float4 finalColor = float4(0,0,0,1);
                //得到速度后，对相邻的像素采样后求其平均值得到模糊效果
                for (int it = 0 ; it<4 ; it++)
                {
                    float2 tempUV = i.uv + it * Speed * _BlurSize;
                    finalColor += tex2D(_MainTex,tempUV);
                }
                finalColor *=0.25f;
                return finalColor;
            }
            ENDCG
        }
    }
}
