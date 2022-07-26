Shader "Custom/TVDistortion" 
{
	Properties 
	{
		_MainTex("Sprite Texture", 2D) = "white" { }
		_Color("Tint", Color) = (1,1,1,1)
		_BackgroundColor("Barckground Color (RGBA)", Color) = (0,0,0,1)
		_AdjustColor("Adjust Color (RGB)", Color) = (0,0,0,1)
		_DistortionTex("Distortion Tex (RG)", 2D) = "gray" { }
		_DistortionFrequency("Distortion Frequency", Float) = 1
		_DistortionAmplitude("Distortion Amplitude", Range(0, 1)) = 1
		_DistortionAnmSpeed("Distortion Animation Speed", Float) = 1
		_ColorScatterStrength("Color Scatter Strength（通道分离）", Range(-0.1, 0.1)) = 0.01
		_NoiseTex("Noise Tex (RGB)", 2D) = "black" { }
		_NoiseAnmSpeed("Noise Animation Speed（噪音抖动速度）", Float) = 1
		_NoiseStrength("Noise Strength(雪花点强度)", Float) = 1
	}
 
	SubShader
	{
		Pass
		{
			//图片总是会通过深度测试但不写入深度缓冲
			//确保图片一定会显示在最上方
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
 
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct v2f
			{
				float4 uv : TEXCOORD0;
				//float4 Color : COLOR;
				float4 Distortion_UV : TEXCOORD1;//扭曲贴图UV
				float4 Noise_UV : TEXCOORD2;//噪音贴图UV
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};
 
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _BackgroundColor;
			float4 _AdjustColor;
			sampler2D _DistortionTex;
			float _DistortionFrequency;
			float _DistortionAmplitude;
			float _DistortionAnmSpeed;
			float _ColorScatterStrength;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _NoiseAnmSpeed;
			float _NoiseStrength;
 
		v2f vert(appdata v)
		{
			v2f o;
			o.uv.xy = v.uv.xy;
			o.vertex = UnityObjectToClipPos(v.vertex);
 
			float4 distortUV;
			//扭曲图UV
			distortUV.x = (_Time.y * _DistortionAnmSpeed);
			distortUV.y = (v.uv.y * _DistortionFrequency);
			o.Distortion_UV = distortUV;
 
			//噪音图UV
			float2 noiseUV = TRANSFORM_TEX(v.uv, _NoiseTex);
			//噪音计算公式
			float3 noise1 = frac((sin((_SinTime.w * float3(12.9898, 78.233, 45.5432))) * 43758.55));
			float3 noise2 = frac((sin((_CosTime.x * float3(12.9898, 78.233, 45.5432))) * 43758.55));
			noiseUV.x = (noiseUV.x + ((noise1.x + noise2.x) * _NoiseAnmSpeed));
 
			float3 noise3 = frac((sin((_SinTime.x * float3(12.9898, 78.233, 45.5432))) * 43758.55));
			float3 noise4 = frac((sin((_CosTime.w * float3(12.9898, 78.233, 45.5432))) * 43758.55));
			noiseUV.y = (noiseUV.y + ((noise3.x + noise4.x) * _NoiseAnmSpeed));
 
 
			o.Noise_UV = float4(noiseUV, 0, 0);
			UNITY_TRANSFER_FOG(o, o.vertex);
			return o;
		}
 
		half4 frag(v2f i) : SV_Target
		{
			float4 color;
			color.yz = float2(0.0, 0.0);
			//获取扭曲图的偏移位置
			//减去0.498是为了防止图片被扭曲超出范围
			//对UV进行扭曲
			half offset = (tex2D(_DistortionTex, i.Distortion_UV.xy) -0.498 ).x * _DistortionAmplitude;
			//颜色偏移强度（左右），偏移颜色通道
			float2 ColorStrength = float2(_ColorScatterStrength, 0.0);
			//红色偏移
			float4 redOffset = tex2D(_MainTex, ((i.uv.xy + offset) + ColorStrength));
			color.xw = redOffset.xw;
			//绿色位置不变
			float4 greenOffset = tex2D(_MainTex, i.uv.xy + offset);
			color.yw = (color.yw + greenOffset.yw);
			//蓝色偏移
			float4 blueOffset = tex2D(_MainTex,(i.uv.xy + offset) - ColorStrength);
			color.zw = (color.zw + blueOffset.zw);
 
			color.w = clamp(color.w, 0.0, 1.0);
			//如果是半透则使用背景颜色
			if ((color.w < 0.5)) 
			{
				color = _BackgroundColor;
			}
 
			//颜色调整
			color.xyz = (1.0 - ((1.0 - color.xyz) * (1.0 - _AdjustColor)));
 
			//噪音图叠加
			float4 noiseColor;
			noiseColor = tex2D(_NoiseTex, i.Noise_UV.xy);
			color.xyz = (1.0 - ((1.0 - color.xyz) * (1.0 -(noiseColor * _NoiseStrength).xyz)));
			return color;
		}
			ENDCG
		}
	}
	FallBack "Diffuse"
}