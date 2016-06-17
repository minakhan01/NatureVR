Shader "UnderWater/Underwater_1" {
Properties {
	_MainTex("Texture", 2D) = "white" {}
	_BumpMap("BumpMap Texture", 2D) = "black" {}
	_Color("Water Color", Color) = (1,1,1,1)
	_DistortionPower("Distortion Power", Range(0.0,0.05) ) = 0.01
	_Opacity("Opacity", Range(0.5,1.0) ) = 0
}
SubShader {
	Tags { 
	"Queue"="Transparent"
	"RenderType"="Overlay" }
	

Blend SrcAlpha OneMinusSrcAlpha

CGPROGRAM
#pragma surface surf Lambert noforwardadd


		sampler2D _MainTex;
		sampler2D _BumpMap;
		fixed4 _Color;
		half _DistortionPower;
		float _Opacity;

struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;	
};	

void surf (Input IN, inout SurfaceOutput o) {
			
			float2 DistortUV=(IN.uv_BumpMap.xy);
			
			// Create Normal from BumpMap
			float4 DistortNormal1 = tex2D(_BumpMap,DistortUV);
			
			// Create distortion effect through DistortionPower
			float2 FinalDistortion = DistortNormal1 * _DistortionPower;
						
			//Apply Distortion to MainTex
			float2 Bump1UV=(IN.uv_MainTex.xy); 
			half4 DistortedTexture=tex2D(_MainTex,Bump1UV + FinalDistortion);			
			
			//Apply Distortion to BumpMap			
			float2 Bump2UV=(IN.uv_BumpMap.xy); 
			fixed4 DistortedBumpMap=tex2D(_BumpMap,Bump2UV + FinalDistortion);
			
			//Get MainTex and BumpMap average
			fixed4 c = (DistortedTexture + DistortedBumpMap) / 2;
			
			o.Albedo = c.rgb * _Color * _Opacity;
			o.Alpha = _Opacity; 
}
ENDCG
}

Fallback "Mobile/VertexLit"
}
