using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

public class ButtonActions : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	public void load3D() {
		SceneManager.LoadScene("Nature_Plain", LoadSceneMode.Single);
	}

	public void loadVR() {
		SceneManager.LoadScene("Nature_FX", LoadSceneMode.Single);
	}
}
