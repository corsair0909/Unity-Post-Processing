Shader "Unlit/SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    CGINCLUDE
            #include "UnityCG.cginc"

            struct v2fAO
            {
                float2 uv           : TEXCOORD0;
                //float4 screenPos    : TEXCOORD1;
                float3 viewPos      : TEXCOORD2;
                float4 vertex       : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthNormalsTexture;
            sampler2D _AoTex;
            float4 _AoTex_TexelSize;

            float4 _RandomSampleVecArray [128];

            float _SampleCount;
            float _AoRadius;
            float _AoStrange;
            float _BlurSpard;
            half4 _aoColor;

            v2fAO vertAO (appdata_img v)
            {
                v2fAO o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                float4 screenPos = ComputeScreenPos(o.vertex);
                float4 ndcPos = (screenPos/screenPos.w) * 2 - 1;
                //_ProjectionParams.z存放远平面距离,从裁剪空间 -> 相机空间
                float3 farClipPos = float3(ndcPos.x,ndcPos.y,1) * _ProjectionParams.z;
                o.viewPos = mul(unity_CameraInvProjection,farClipPos.xyzz).xyz;
                return o;
            }

            float Hash(float2 p)
            {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }

            float3 GetRandomVecHalf(float2 p)
            {
                float3 vec = float3(0, 0, 0);
                vec.x = Hash(p) * 2 - 1;
                vec.y = Hash(p * p) * 2 - 1;
                vec.z = saturate(Hash(p * p * p) + 0.2);
                return normalize(vec);
            }

            float3 GetRandomVec(float2 p)
            {
                float3 vec = float3(0, 0, 0);
                vec.x = Hash(p) * 2 - 1;
                vec.y = Hash(p * p) * 2 - 1;
                vec.z = Hash(p * p * p) * 2 - 1;
                return normalize(vec);
            }
    
            fixed4 fragAO (v2fAO i) : SV_Target
            {
                float linearDepth;
                float3 ViewNormalDir;
                float4 depthNormals = tex2D(_CameraDepthNormalsTexture,i.uv);
                DecodeDepthNormal(depthNormals,linearDepth,ViewNormalDir);
                //根据NDC重建世界坐标后的所有顶点在世界空间下的坐标坐标
                float3 worldSpacePos = linearDepth * i.viewPos;

                //左手坐标系的原因，法线z分量要取反
                float3 ViewNormal = normalize(ViewNormalDir) * float3(1,1,-1);
                float3 randomVec = GetRandomVec(i.uv);
                //float3 randomVec = tex2D(_NoiseTex,i.uv);

                //施密特正交化（两个不相干的向量求正交基）
                float3 Tangent = randomVec - ViewNormal * dot(randomVec,ViewNormal);
                float3 Btangent = cross(ViewNormal,Tangent);
                float3x3 TBN = float3x3(Tangent,Btangent,ViewNormal);

                float Ao = 0;

                [unroll(128)]
                for (int it = 0; it < (int)_SampleCount; ++it)
                {
                    float3 randomPos = GetRandomVecHalf(i.uv);

                    //计算缩放和权重
                    float scale = it / _SampleCount;
                    scale = lerp(0.01, 1, scale * scale);
                    randomPos *= scale;
                    //越靠近采样点的随机点对AO的贡献越大，权重越大
                    float weight = smoothstep(0,0.2,length(randomPos));
                    
                    float3 randomPosVec = mul(randomPos.xyz,TBN) * _AoRadius;
                    float3 randomSamplePos = worldSpacePos + randomPosVec;
                    //回到裁剪空间
                    float3 sampleCamSpacePos = mul((float3x3)unity_CameraProjection,randomSamplePos);
                    //随机采样点的uv坐标
                    float2 randomSampleScrPos = (sampleCamSpacePos.xy/sampleCamSpacePos.z) * 0.5f + 0.5f;
                    
                    float4 randomSample = tex2D(_CameraDepthNormalsTexture,randomSampleScrPos);
                    float randomSampleDepth;
                    float3 randomSampleNormal;
                    DecodeDepthNormal(randomSample,randomSampleDepth,randomSampleNormal);
                    //相差太远的物体之间不应该有AO
                    float rangeCheck = smoothstep(0.0,1.0,_AoRadius/abs(linearDepth - randomSampleDepth));
                    Ao += randomSampleDepth < linearDepth ? 1.0f * _AoStrange * weight * rangeCheck: 0.2f;
                }

                //此时AO呈现白色，背景黑色，需要取反
                Ao = 1 - saturate((Ao / (int)_SampleCount)) * _aoColor;
                float4 scrTex = tex2D(_MainTex, i.uv);
                return Ao * scrTex;
            }

            fixed4 fragBlur(v2fAO i) : SV_Target
            {
                half4 col = tex2D(_AoTex,i.uv);
                for (int it = -1; it < 1; ++it)
                {
                    for (int jt = -1; jt < 1; ++jt)
                    {
                        i.uv += _AoTex_TexelSize.xy * _BlurSpard;
                        col += tex2D(_AoTex,i.uv);
                    }
                }
                return col/9;
            }

            fixed4 fragCombine(v2fAO i) : SV_Target
            {
                half4 MainCol = tex2D(_MainTex,i.uv) ;
                half4 AoCol = tex2D(_AoTex,i.uv);
                return lerp(MainCol,AoCol,_AoStrange);
                //return MainCol;
            }


    ENDCG
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off ZTest Always ZWrite Off

        Pass // AO计算
        {
            CGPROGRAM
            #pragma vertex vertAO
            #pragma fragment fragAO
            ENDCG
        }
        Pass //合并
        {
            CGPROGRAM
            #pragma vertex vertAO
            #pragma fragment fragCombine
            ENDCG
        }
    }
}
