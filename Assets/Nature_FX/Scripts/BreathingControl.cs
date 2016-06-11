using UnityEngine;
using System.Collections;

public class BreathingControl : MonoBehaviour {

	GameObject micController;
	// Use this for initialization
	void Start () {

	}

	// Update is called once per frame
	void Update () {
		micController = GameObject.Find ("MicController");
		var loudness = micController.GetComponent<MicControl>().loudness;
		Debug.Log ("loudness: "+loudness);
		transform.localScale= new Vector3(1+10*loudness,1+10*loudness,1+10*loudness);
	}

}