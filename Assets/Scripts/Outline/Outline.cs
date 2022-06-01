using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Outline : PostEffectsBase
{
    public Shader shader;
    private Material _material;
    public Material Material
    {
        get
        {
            _material = CheckShaderAndCreateMaterial(shader, _material);
            return _material;
        }
    }

    [Range(0,1)]
    public int EdgeOnly = 1;
    public Color backColor = Color.white;
    public Color edgeColor = Color.black;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Material)
        {
            Material.SetFloat("_EdgeOnly",EdgeOnly);
            Material.SetVector("_BackColor",backColor);
            Material.SetVector("_EdgeColor",edgeColor);
            Graphics.Blit(src,dest,Material);
        }
        else
        {
            
            Graphics.Blit(src,dest);
        }
    }
}
