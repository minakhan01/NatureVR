using UnityEngine;
using System.Collections;

public class BreathingControl : MonoBehaviour {

	GameObject micController;
	GameObject dandelion;
	ParticleSystem particleSystem;

	// Use this for initialization
	void Start () {
		micController = GameObject.Find ("MicController");
		dandelion = GameObject.Find ("Dandelions_A");
		particleSystem = dandelion.GetComponent<ParticleSystem>();
//		var ex = particleSystem.externalForces;
//		ex.enabled = true;
//		ex.multiplier = 500f;
//		Debug.Log ("particleSystem: "+particleSystem.ToString());
	}

	// Update is called once per frame
	void Update () {
		var loudness = micController.GetComponent<MicControl>().loudness;
//		Debug.Log ("loudness: "+loudness);
		if (loudness > 0.05f) {
			Debug.Log ("loudness > 0.05f");
			IncreaseRate ();
		} else {
			DecreaseRate();
		}
	}

	void IncreaseRate() {
//		ParticleSystem.EmissionModule em = particleSystem.emission;
//		em.enabled = true;
//		var ex = particleSystem.externalForces;
//		ex.multiplier = 500f;
//		ex.enabled = true;
////		em.rate = new ParticleSystem.MinMaxCurve(100000);
////		var ex = particleSystem.externalForces;
////		ex.enabled = true;
////		ex.multiplier = 500f;
//		em.SetBursts(
//			new ParticleSystem.Burst[]{
//				new ParticleSystem.Burst(2.0f, 10000),
//				new ParticleSystem.Burst(4.0f, 10000)
//			});
		particleSystem.Play ();
		StartCoroutine(ExecuteAfterTime(5));
	}

	void DecreaseRate() {
		
//		var ex = particleSystem.externalForces;
//		ex.multiplier = 5f;
//		ex.enabled = false;
//		particleSystem = GetComponent<ParticleSystem>();
//		var em = particleSystem.emission;
////		em.rate = new ParticleSystem.MinMaxCurve(100000);
//		var ex = particleSystem.externalForces;
//		ex.enabled = true;
//		ex.multiplier = 1f;
	}

	IEnumerator ExecuteAfterTime(float time)
	{
		yield return new WaitForSeconds(time);

		// Code to execute after the delay
		particleSystem.Pause();
	}
}