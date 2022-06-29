Shader "Unlit/SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
            CGINCLUDE
          #include "UnityCG.cginc"
            #define MAX_SAMPLE_KERNEL_COUNT 32
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _AOTex;
            sampler2D _CameraDepthNormalsTexture;
        
            fixed _sampleKernelRadius;
            fixed _sampleKernelCount;
            fixed _AOStrength;
            fixed4x4 _InverseProjectMatrix;
            fixed4 _blurRadius;
			fixed _BilaterFilterFactor;
            fixed _randomBias;

            fixed4 _sampleKernelPosList[MAX_SAMPLE_KERNEL_COUNT];

            struct v2f
            {
                float2 uv        : TEXCOORD0;
                float4 vertex    : SV_POSITION;
                float3 viewRay   : TEXCOORD1;
                float2 screenPos : TEXCOORD2;
            };

        		float3 GetNormal(float2 uv)
			{
				float4 cdn = tex2D(_CameraDepthNormalsTexture, uv);
				return DecodeViewNormalStereo(cdn);
			}
	
			half CompareNormal(float3 normal1, float3 normal2)
        	{
        		return smoothstep(_BilaterFilterFactor, 1.0, dot(normal1, normal2));
        	}
            v2f AO_vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                float4 farClip = float4(v.texcoord*2-1,1.0f,1.0f)*_ProjectionParams.z;//远裁剪平面
                float4 Ray = mul(unity_CameraInvProjection,farClip);//转换到视角空间下
                o.viewRay = Ray.xyz/Ray.w;//从相机出发经过顶点指向远裁剪平面的射线向量
                float4 scrPos = ComputeScreenPos(o.vertex);//
                o.screenPos = (scrPos.xy/scrPos.w);
                return o;
            }
            fixed4 Ao_frag (v2f i) : SV_Target
            {
                float3 viewNormal;
                float viewDepth;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture,i.screenPos),viewDepth,viewNormal);
                float3 viewPos = viewDepth * i.viewRay;
                viewNormal = normalize(viewNormal) * float3(1,1,-1);//法线z方向相对于相机方向为负
                float3 randVec = float3(1,1,1);
                //构建正交基TODO 看视频
                float3 tangent = normalize(randVec - viewNormal * dot(randVec,viewNormal));
                float3 btangent = cross(tangent,viewNormal);
                float3x3 TBN = float3x3(tangent,btangent,viewNormal);
                float AO = 0.0f;
                for (int ii = 0; ii<_sampleKernelCount;ii++)
                {
                    float3 randomVec = mul(_sampleKernelPosList[ii].xyz,TBN);//随机采样点向量
                    randomVec = dot(randomVec,viewNormal)<0 ? -randomVec : randomVec;//防止随机采样点方向与法线方向相反
                    
                    float3 ranPos = viewPos + randomVec*_sampleKernelRadius;
                    float3 rClipPos = mul(unity_CameraProjection,float4(ranPos,1.0f)).xyz;//赚到裁剪空间
                    float2 rScreenPos = (rClipPos.xy/rClipPos.z) * 0.5f + 0.5f;//求出随机采样点的屏幕坐标（可以理解为该点的uv坐标）

                    float3 randomNormal;
                    float randomDepth;
                    DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture,rScreenPos),randomDepth,randomNormal);
                    AO+=randomDepth>viewDepth?1.0f:0.0f;//若随机点深度>顶点深度，认为存在遮蔽，AO = 1
                    
                    // float range = abs(randomDepth - viewDepth) * _ProjectionParams.z < _sampleKernelRadius ? 1.0f:0.0f;
                    // float selfCheck = randomDepth+_randomBias < viewDepth ? 1.0f : 0.0f;
                    // float weight = smoothstep(0.0f,0.2f,length(ranPos.xy));
                    // AO += range * selfCheck * weight;
                    
                    //float rangeCheck = smoothstep(0.0,1.0,_sampleKernelRadius / abs(randomDepth - viewDepth));
			        // AO += (randomDepth >= viewDepth ? 1.0 : 0.0) * rangeCheck;
                }
                AO/=_sampleKernelCount;//平均值
                AO = max(0,1-AO*_AOStrength);
                fixed4 col = tex2D(_MainTex,i.uv);
                col.rgb = AO;
                return col;
                
            }
            fixed4 blur_frag (v2f i) : SV_Target
            {
                //均值模糊
		        float2 delta = _MainTex_TexelSize.xy * _blurRadius.xy;
                fixed4 var_MainTex = tex2D(_MainTex,i.uv);
                var_MainTex += tex2D(_MainTex,i.uv + delta);
                var_MainTex += tex2D(_MainTex,i.uv - delta);
                var_MainTex += tex2D(_MainTex,i.uv + delta * 2);
                var_MainTex += tex2D(_MainTex,i.uv - delta * 2);
                // for (int it=1; it<4;it++)
                // {
                //     float2 blurUV = i.uv + delta * it;
                //     var_MainTex += tex2D(_MainTex,blurUV);
                // }
                var_MainTex *= 0.25f;
		        return var_MainTex;
            }
            fixed4 Combile_frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex,i.uv);
                fixed4 Ao = tex2D(_AOTex,i.uv);
                col.rgb *= Ao.r;
                return col;
            }
        ENDCG
    SubShader
    {
        Cull Off
        ZTest Always
        ZWrite Off
        

        Pass
        {
            CGPROGRAM //计算AO
            #pragma vertex AO_vert
            #pragma fragment Ao_frag
            ENDCG
        }
        Pass
        {
            CGPROGRAM //模糊
            #pragma vertex AO_vert
            #pragma fragment blur_frag
            ENDCG
        }
        Pass
        {
            CGPROGRAM //合并AO
            #pragma vertex AO_vert
            #pragma fragment Combile_frag
            ENDCG
        }
    }
}
