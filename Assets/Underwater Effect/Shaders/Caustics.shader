Shader "UnderWater/Caustics" {
  Properties {
  	  _Color ("Caustic Color", Color) = (1,1,1,1)
  	  _Brightness("Caustic Brightness", Range(0.1, 1.0)) = 1
  	  _ScrollX ("Caustic Scroll Speed - X", Float) = 1.0
	  _ScrollY ("Caustic Scroll Speed - Y", Float) = 0.0   	
     _ShadowTex ("Cookie", 2D) = "" { }
     
  }

SubShader {
	Tags { "Queue"="Transparent+100"  "RenderType"="Transparent" }
	Lighting Off
	Fog { Color (0, 0, 0) } 
	ZWrite Off
	Blend SrcAlpha One

CGINCLUDE
#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
#include "UnityCG.cginc"
      
sampler2D _ShadowTex;
float4 _ShadowTex_ST;
float _ScrollX;
float _ScrollY;
float _Brightness;
float4 _Color;
float4x4 _Projector;
	
	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		fixed4 color : TEXCOORD1;
	};

	v2f vert (appdata_full v) {
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = TRANSFORM_TEX (mul (_Projector, v.vertex).xy, _ShadowTex) + frac(float2(_ScrollX, _ScrollY) * _Time);
		o.color = fixed4(0,0,0,_Brightness) * _Color ;
		return o;
	}
ENDCG
	Pass {
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#pragma target 2.0

	fixed4 frag (v2f i) : COLOR
	{
		fixed4 tex = tex2D (_ShadowTex, i.uv) * _Brightness * _Color;
		return tex;
	}
ENDCG
	}
}

  
  Subshader {
  Tags { "Queue" = "Transparent" }
     Pass {
        ZWrite off
        Fog { Color (0, 0, 0) }
        Color [_Color]
        ColorMask RGB
        Blend SrcAlpha One
		Offset -1, -1
        SetTexture [_ShadowTex] {
           constantColor (1,1,1,[_Brightness])
           combine texture * primary, constant
           //Matrix [_Projector]
        }
     
     }
  }
}