using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class OutLine3 : MonoBehaviour
{
    public Shader PreuColorShader;
    public Shader Shader;

    private Material material;
    public Material Mate
    {
        get
        {
            if (material == null)
            {
                material = new Material(Shader);
                return material;
            }
            else
            {
                return material;
            }
        }
    }

    private Camera mainCamera;

    private Camera outlineCamera;
    public Camera OutlineCamera
    {
        get
        {
            if (outlineCamera == null)
            {
                outlineCamera = transform.GetChild(0).GetComponent<Camera>();
                return outlineCamera;
            }
            else
            {
                return outlineCamera;
            }
        }
    }

    private RenderTexture _renderTexture;

    [Range(0, 4)] public int dowmSample;
    [Range(0, 4)] public int interation;
    public Color outlineColor = new Color(1, 1, 1, 1);
    [Range(0.2f, 4)] public float BlurSize;
    
    [Header("描边强度")]
    [Range(0.2f, 10.0f)]
    public float outlinePower = 2;

    private void Awake()
    {
        mainCamera = GetComponent<Camera>();
        CreatRenderTexture();
    }

    private void CreatRenderTexture()
    {
        OutlineCamera.cullingMask = 1 << LayerMask.NameToLayer("Player");
        int width = OutlineCamera.pixelWidth >> dowmSample;
        int height = OutlineCamera.pixelHeight >> dowmSample;
        _renderTexture = RenderTexture.GetTemporary(width, height, 0);
    }

    private void OnPreRender()
    {
        if (OutlineCamera.enabled)
        {
            OutlineCamera.targetTexture = _renderTexture;
            OutlineCamera.RenderWithShader(PreuColorShader,"");
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mate)
        {
            int width = Screen.width >> dowmSample;
            int height = Screen.height >> dowmSample;
            RenderTexture temp1 = RenderTexture.GetTemporary(width, height);
            RenderTexture temp2 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(_renderTexture,temp1);
            for (int i = 0; i < interation; i++)
            {
                Mate.SetFloat("_BlurSize",(1+BlurSize * i));
                
                Graphics.Blit(temp1,temp2,Mate,0);
                Graphics.Blit(temp2,temp1,Mate,1);
            }
            Mate.SetColor ("_OutlineColor", outlineColor);
            Mate.SetTexture ("_BlurTex", temp1);
            Mate.SetTexture ("_SrcTex", _renderTexture);
            Mate.SetFloat("_outlinePower",outlinePower);
            Graphics.Blit (src, dest, Mate, 2);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
