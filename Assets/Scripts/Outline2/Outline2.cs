using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Outline2 : MonoBehaviour
{
    public Shader shader;

    private Material _material;
    public Material Mate
    {
        get
        {
            if (_material==null)
            {
                _material = new Material(shader);
                return _material;
            }
            else
            {
                return _material;
            }
        }
    }
    
    [Range(0,1)]
    public int EdgeOnly = 1;
    public Color EdgeColor = Color.black;
    public Color BackColor = Color.white;

    public float SampleDistance = 1.0f;//用于控制边线宽度
    public float SensitivityDepth = 1.0f;//下面两个属性控制的是采样灵明度，灵明度越高，深度和法线变化很小也会被识别为一个边缘
    public float SensitivityNormal = 1.0f;
    [Range(0.1f,1)]
    public float Theshold = 0.1f;

    private void OnEnable()
    {
        //textureMode 改为深度法线贴图，可以通过_CameraDepthNormalTexture变量访问深度贴图和法线贴图
        //变量的xy分量为法线，zw分量为深度
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mate)
        {
            Mate.SetFloat("_EdgeOnly", EdgeOnly);
            Mate.SetVector("_EdgeColor",EdgeColor);
            Mate.SetVector("_BackColor",BackColor);
            Mate.SetFloat("_SampleDistance", SampleDistance);
            Mate.SetFloat("_TheShold",Theshold);
            Mate.SetVector("_Sensitivity",new Vector4(SensitivityDepth,SensitivityNormal,1,1));
            Graphics.Blit(src,dest,Mate);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
