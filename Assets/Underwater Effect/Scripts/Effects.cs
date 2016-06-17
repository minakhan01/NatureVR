using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class Effects : MonoBehaviour {
	
	public float DepthEffectValue = 0.125F;
	public Color DepthEffectColor = new Color(0.086f, 0.216f, 0.714f);
	public Material Effect;

	private Material UnderwaterEffect;
	
	void Start () {

		Effect = Resources.Load("Material/Effect") as Material;
		
		if (Effect != null){
			Effect.shader = Shader.Find("UnderWater/Effects");
		}
		
		else {
			Resources.UnloadAsset(Effect);
			
		}	
			
	}
	
	// Update is called once per frame
	void OnRenderImage(RenderTexture source, RenderTexture destination) 
	{
		
		RenderTexture temp = RenderTexture.GetTemporary(source.width,source.height);
		
		Effect.SetColor("_DepthEffectColor", DepthEffectColor);
		Effect.SetFloat("_EffectFadeValue", DepthEffectValue);
		
		Effect.SetVector("offsets", new Vector4(1.0F,0.0F,0.0F,0.0F));
		Graphics.Blit(source, temp, Effect,0);
		Effect.SetVector("offsets", new Vector4(0.0F,1.0F,0.0F,0.0F));
		Graphics.Blit(temp, destination, Effect,0);
		
		RenderTexture.ReleaseTemporary(temp);		
	}
}
