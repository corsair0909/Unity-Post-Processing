Shader "Unlit/SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off
        ZTest Always
        ZWrite Off
        
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
                float4 farClip = float4(v.texcoord*2-1,1.0f,1.0f)*_ProjectionParams.z;
                float4 Ray = mul(unity_CameraInvProjection,farClip);
                o.viewRay = Ray.xyz/Ray.w;
                float4 scrPos = ComputeScreenPos(o.vertex);
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
                float AO = 0.0f;
                for (int ii = 0; ii<_sampleKernelCount;ii++)
                {
                    float3 randomVec = _sampleKernelPosList[ii];
                    randomVec = dot(randomVec,viewNormal)<0 ? -randomVec : randomVec;//防止随机采样点方向与法线方向相反
                    
                    float3 ranPos = viewPos + randomVec*_sampleKernelRadius;
                    float3 rClipPos = mul(unity_CameraProjection,float4(ranPos,1.0f)).xyz;
                    float2 rScreenPos = (rClipPos.xy/rClipPos.z) * 0.5f + 0.5f;

                    float3 randomNormal;
                    float randomDepth;
                    DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture,rScreenPos),randomDepth,randomNormal);
                    
                    float range = abs(randomDepth - viewDepth) < _sampleKernelRadius ? 1.0f:0.0f;
                    float selfCheck = abs(randomDepth-viewDepth) > 0 ? 1.0f:0.0f;
                    float weight = smoothstep(0.0f,0.2f,length(ranPos.xy));
                    AO += range * selfCheck * weight;
                }
                AO/=_sampleKernelCount;
                AO = max(0.0f,1-AO*_AOStrength);
                fixed4 col = tex2D(_MainTex,i.uv);
                col.rgb = AO;
                return col;
                
            }
            fixed4 blur_frag (v2f i) : SV_Target
            {
		        float2 delta = _MainTex_TexelSize.xy * _blurRadius.xy;
                fixed4 var_MainTex = tex2D(_MainTex,i.uv);
                for (int it=1; it<4;it++)
                {
                    float2 blurUV = i.uv + delta * it;
                    var_MainTex += tex2D(_MainTex,blurUV);
                }
                var_MainTex *= 0.25f;
		        return var_MainTex;
            }
            fixed4 Combile_frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex,i.uv);
                fixed4 Ao = tex2D(_AOTex,i.uv);
                col.rgb *= Ao.rgb;
                return col;
            }
        ENDCG
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
