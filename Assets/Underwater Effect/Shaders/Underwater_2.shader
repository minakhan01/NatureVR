Shader "UnderWater/Underwater_2"
{
	Properties 
	{
	_MainTex("_MainTex", 2D) = "black" {}
	_BumpMap("_BumpMap", 2D) = "black" {}
	_Color("Water Color", Color) = (1,1,1,1)
	_DistortionPower("DistortionPower", Range(0,0.03) ) = 0
	_Specular("Specular", Range(0,7) ) = 1
	_Gloss("Gloss", Range(0.3,2) ) = 0.3
	_Opacity("Opacity", Range(0.001,2.0) ) = 0

	}
	
	SubShader 
	{
		Tags
		{
		"Queue"="Transparent"
		"IgnoreProjector"="True"
		"RenderType"="Transparent"
		}

		
		Cull Back
		ZWrite On
		ZTest LEqual
		ColorMask RGBA
		Blend SrcAlpha OneMinusSrcAlpha
		
		
		CGPROGRAM
		#pragma surface surf Underwater   
		#pragma target 3.0
		
		
		uniform sampler2D _MainTex;
		uniform sampler2D _BumpMap;
		fixed4 _Color;
		half _DistortionPower;
		fixed _Specular;
		fixed _Gloss;
		float _Opacity;

		
		
			
		half4 LightingUnderwater (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
		
		  lightDir.z = 1-lightDir.z;
          half3 h = normalize (lightDir + viewDir);
          half diff = max (0, dot (s.Normal, lightDir));
          float nh = max (0, dot (s.Normal, h));
          float spec = pow (nh, s.Specular*256.0)* s.Gloss;
          half4 c;
          c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten * 2);
          c.a = s.Alpha;
          return c;
          }
		
		struct Input {
			
			float3 viewDir;
			float2 uv_MainTex;
			float2 uv_BumpMap;
			
		};

		void surf (Input IN, inout SurfaceOutput o) {
			o.Normal = float3(0.0,0.0,1.0);
			
			float4 ViewDirection=float4( IN.viewDir.x, IN.viewDir.y,IN.viewDir.z *10,0 );
			float4 Normalize0=normalize(ViewDirection);
						
			float2 DistortUV=(IN.uv_BumpMap.xy);
			
			//Create Normal from BumpMap
			float4 DistortNormal =  tex2D(_BumpMap,DistortUV);
			
			//Create distortion effect through DistortionPower
			float FinalDistortion = DistortNormal.r * _DistortionPower;
			
			//Apply Distorion to MainTex
			float2 MainTexUV=(IN.uv_MainTex.xy  + FinalDistortion); 
			float4 Tex=tex2D(_MainTex,MainTexUV);
			
			//Apply Distorion to BumpMap
			float2 BumpMapUV=(IN.uv_BumpMap.xy  + FinalDistortion); 
			float4 Bump=tex2D(_BumpMap,BumpMapUV); 
			
			//Define Color
			float4 FinalDiffuse = _Color;			
			
			//Get MainTex and BumpMap Average
			fixed4 Avg= (Tex + Bump) / 2;
			
			//Unpack Normals
			fixed4 UnpackNormal1=float4(UnpackNormal(Avg).xyz, 1.0);
			
			o.Albedo = FinalDiffuse;
			o.Normal = UnpackNormal1;
			o.Specular = _Gloss;
			o.Gloss = _Specular;
			o.Alpha = _Opacity;

			o.Normal = normalize(o.Normal);
		}
	ENDCG
	}
	Fallback "Diffuse"
}