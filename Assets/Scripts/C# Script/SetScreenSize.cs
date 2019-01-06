using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class SetScreenSize : MonoBehaviour
{
    public float SW;
    public float SH;

    // Start is called before the first frame update
    void Start()
    {
       
    }

    // Update is called once per frame
    void Update()
    {
        SW = Screen.width;
        SH = Screen.height;
        Shader.SetGlobalVector("_ScreenSizeWH", new Vector4(SW, SH, 1, 1));
    }
}
