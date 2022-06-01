using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : MonoBehaviour
{
    public Shader shader;
    private RenderTexture amoundTexture;
    private Material _material;
    public Material Material
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
    public float blurAmount = 0.5f;//拖尾效果系数

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Material)
        {
            if (amoundTexture == null && amoundTexture.width != Screen.width && amoundTexture.height != Screen.height)
            {
                DestroyImmediate(amoundTexture);
                amoundTexture = new RenderTexture(Screen.width, Screen.height, 0);
                amoundTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(src,amoundTexture);
            }
            Material.SetFloat("_Amount",1-blurAmount);
            amoundTexture.MarkRestoreExpected();
            Graphics.Blit(src,amoundTexture,Material);
            Graphics.Blit(amoundTexture,dest);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
