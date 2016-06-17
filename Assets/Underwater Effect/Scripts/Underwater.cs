using UnityEngine;
using System.Collections;

[ExecuteInEditMode]

public class Underwater : MonoBehaviour {
	
	#region public data
	public Material AssignSkybox;
	public GameObject AssignCaustic;
	private Material Caustic;
	public bool enableCaustics = true;
	public Color CausticColor= Color.white;
	public float CausticSpeedX = 0.01f;
    public float CausticSpeedY = 0.01f;
	public bool enableUnderwaterFog = true;
	public Color underwaterFogColor = Color.cyan;
	public float underwaterFogDensity = 0.006f;
	public bool enableSkyFog = true;
	public Color skyFogColor = Color.cyan;
	public float skyFogDensity = 0.005f;
	private Color NoFogColor = Color.clear;
	private float NoFogDensity = 0.0f;
	private float m_UnderwaterCheckOffset = 0.0001F;	
	
	public Vector2 WaterTextureSpeed = new Vector2(0.01F, 0.01F);
	public Vector2 WaterBumpmapSpeed = new Vector2(0.01F, 0.01F);
	
	private Vector2 textureUV;
	private Vector2 bumpMapUV;
	
	#endregion
	
	
	#region private data
	private bool InUnderwater = false;
	#endregion
	
	void Start() {
	
		Caustic = Resources.Load("Material/Caustic") as Material;
		
		if (Caustic != null){
			Caustic.shader = Shader.Find("UnderWater/Caustics");
			}

		else {
			Resources.UnloadAsset(Caustic);
		
    	}
		
		
	}
	void Update () { 

Caustic.SetColor("_Color", CausticColor);		

Caustic.SetFloat("_ScrollX", CausticSpeedX);		
Caustic.SetFloat("_ScrollY", CausticSpeedY);
		
textureUV.x = Time.time * WaterTextureSpeed.x;
textureUV.y = Time.time * WaterTextureSpeed.y;

bumpMapUV.x = Time.time * WaterBumpmapSpeed.x;
bumpMapUV.y = Time.time * WaterBumpmapSpeed.y;			

GetComponent<Renderer>().sharedMaterial.SetTextureOffset("_MainTex", textureUV);
GetComponent<Renderer>().sharedMaterial.SetTextureOffset("_BumpMap", bumpMapUV);

	}
	
	public bool IsUnderwater(Camera cam) {
		return cam.transform.position.y + m_UnderwaterCheckOffset < transform.position.y ? true : false;	
	}



	public void OnWillRenderObject()
	{
		
		Camera cam = Camera.main;
		
		if(IsUnderwater(cam)) 
		{
			if(Camera.main == cam && !cam.gameObject.GetComponent(typeof(Effects)) ) {
					cam.gameObject.AddComponent(typeof(Effects));	
				}
				
				Effects effect = (Effects)cam.gameObject.GetComponent(typeof(Effects));				
				if(effect) {
					effect.enabled = true;
				
				}
					
				GetComponent<Renderer>().sharedMaterial.shader.maximumLOD = 50;	
				
			
				if(!InUnderwater){
					
					InUnderwater = true;
					
					
					//Enable caustic
					if(enableCaustics) {
					enableCaustics = true;
						 	
					AssignCaustic.SetActive(true);
				}
				else{
					AssignCaustic.SetActive(false);
				}
				
				if(enableUnderwaterFog) {
					enableUnderwaterFog = true;
					
					//Enable underwater fog
					RenderSettings.fog = true;
					RenderSettings.fogDensity = underwaterFogDensity;
					RenderSettings.fogColor = underwaterFogColor;
					cam.clearFlags = CameraClearFlags.SolidColor;
					cam.backgroundColor = underwaterFogColor;
				}
				else{
					RenderSettings.fog = false;
					RenderSettings.fogDensity = NoFogDensity;
					RenderSettings.fogColor = NoFogColor;
					cam.clearFlags = CameraClearFlags.SolidColor;
					cam.backgroundColor = underwaterFogColor;
					
				}
					
			}
		}
		else{
			
			Effects effect = (Effects)cam.gameObject.GetComponent(typeof(Effects));
				if(effect && effect.enabled) {
					effect.enabled = false;
				}

				GetComponent<Renderer>().sharedMaterial.shader.maximumLOD = 100;	
				
				if(InUnderwater){
				
					InUnderwater = false;	
					
					//Disable caustic
				AssignCaustic.SetActive(false);	
				
					if(enableSkyFog) {
					enableSkyFog = true;
				
					//Disable underwater fog
					RenderSettings.fog = false;
					RenderSettings.fogDensity = skyFogDensity;
					RenderSettings.fogColor = skyFogColor;
					RenderSettings.skybox = AssignSkybox;
					cam.clearFlags = CameraClearFlags.Skybox;
					cam.GetComponent<Skybox>();
				
				}else{
					
					RenderSettings.fog = false;
					RenderSettings.fogDensity = NoFogDensity;
					RenderSettings.fogColor = NoFogColor;
					RenderSettings.skybox = AssignSkybox;
					cam.clearFlags = CameraClearFlags.Skybox;
					cam.GetComponent<Skybox>();
				}					
							
				}
			}
		}
	}
