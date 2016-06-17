Shader "UnderWater/Underwater_3"
{
	Properties 
	{
	_MainTex("Texture", 2D) = "white" {}
	_BumpMap("BumpMap", 2D) = "black" {}
	_Color("Water Color", Color) = (1,1,1,1)
	_DistortionPower("Distortion Power", Range(0.0,0.03) ) = 0.01
	_Specular("Specular", Range(0,7) ) = 1
	_Gloss("Gloss", Range(0.3,10) ) = 0.3
	_Opacity("Opacity", Range(-0.1,5.0) ) = 0
	_ReflectPower("Reflection Power", Range(0,1) ) = 0
	_Reflection("Reflection Cube", Cube) = "black" {}
	

	}
	
	SubShader 
	{
		Tags
		{
			"Queue"="Transparent-1"
			"IgnoreProjector"="False"
			"RenderType"="Transparent"
		}

		
		Cull Back
		ZWrite On
		ZTest LEqual
		ColorMask RGBA
		Blend SrcAlpha OneMinusSrcAlpha
		Fog{
		}
		
		
		CGPROGRAM
		#pragma surface surf Underwater
		#pragma target 2.0
		
		
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
			
			float2 DistortUV=(IN.uv_MainTex.xy);
			
			//Create Normal from MainTex
			float4 DistortNormal1 = tex2D(_MainTex,DistortUV);
			
			//Create distortion effect through DistortionPower
			float2 FinalDistortion = DistortNormal1 * _DistortionPower;
						
			//Define Color
			float4 FinalDiffuse = _Color; 			
						
			//Apply Distortion to MainTex
			float2 Bump1UV=(IN.uv_MainTex.xy + FinalDistortion); 
			half4 DistortedTexture=tex2D(_MainTex,Bump1UV + FinalDistortion);			
			
			//Apply Distortion to BumpMap
			float2 Bump2UV=(IN.uv_BumpMap.xy + FinalDistortion); 
			fixed4 DistortedBumpMap=tex2D(_BumpMap,Bump2UV + FinalDistortion);
			
			//Get MainTex and BumpMap average
			fixed4 Avg= (DistortedTexture + DistortedBumpMap) / 2;
			
			//Unpack Normals
			fixed4 UnpackNormal1=float4(UnpackNormal(Avg).xyz, 1.0);
			
			//Fresnel
			float fresnel = 1.0 - saturate(dot ( o.Normal, normalize(IN.viewDir))); 
			
			float FinalAlpha = _Opacity  ;		 	
			o.Albedo = FinalDiffuse;
			o.Normal = UnpackNormal1;
			o.Specular = _Gloss;
			o.Gloss = _Specular;
			o.Alpha = FinalAlpha;

			o.Normal = normalize(o.Normal);
		}
	ENDCG


	Pass{
            Tags {
                "Queue"="Transparent"  "RenderType" = "Transparent" }
Blend  SrcAlpha OneMinusSrcAlpha

CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag alpha
        #include "UnityCG.cginc" 

            samplerCUBE _Reflection;
            float _ReflectPower;
            uniform sampler2D _MainTex;
            uniform sampler2D _BumpMap;
            float4 _MainTex_ST;
            float4 _BumpMap_ST;
            fixed _DistortionPower;
            float _Opacity;
			
            struct v2f {
                float4 pos : POSITION;
                float2 MainTexUV : TEXCOORD2;
                float2 BumpMapUV : TEXCOORD3;
                float3 I : TEXCOORD1;
                float3 viewDir : TEXCOORD4;
                float3 normal  : TEXCOORD5;
            }; 

            v2f vert( appdata_full v ) {
                v2f o;
                o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                o.MainTexUV = TRANSFORM_TEX (v.texcoord, _MainTex);
                o.BumpMapUV = TRANSFORM_TEX (v.texcoord, _BumpMap);
                
                //Get object space reflection vector	
			   	o.viewDir = normalize(ObjSpaceViewDir( v.vertex ));   
			   
                float3 I = reflect( float3(-o.viewDir.x,o.viewDir.y,-o.viewDir.z), v.normal );
                //Transform to world space reflection vector
				o.I = mul( (float3x3)_Object2World, I ); 
				o.normal = v.normal; 
                return o;
            }

        
        half4 frag( v2f IN ) : COLOR {
        		
        		float4 DistortNormal1 =  tex2D(_MainTex,IN.MainTexUV  ); 
        		float4 DistortNormal2 =  tex2D(_BumpMap,IN.BumpMapUV ); 
        		float FinalDistortion = (DistortNormal1.x - DistortNormal2.x) * _DistortionPower * 300;
        		
                
                half4 reflection = texCUBE( _Reflection, IN.I +  FinalDistortion);  
                
                
				float fresnel  = 1 - saturate ( dot ( IN.normal, normalize(IN.viewDir )) ); 
				
				
                reflection.a =  _ReflectPower * _Opacity * reflection; 
                return reflection; 
            }   
        ENDCG
}

	}

}