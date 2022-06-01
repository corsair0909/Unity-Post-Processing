using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Outline : MonoBehaviour
{
    public Shader shader;
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
    public int EdgeOnly = 1;
    public Color backColor = Color.white;
    public Color edgeColor = Color.black;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (_material)
        {
            _material.SetFloat("_EdgeOnly",EdgeOnly);
            _material.SetVector("_BackColor",backColor);
            _material.SetVector("_EdgeColor",edgeColor);
            Graphics.Blit(src,dest,_material,0);
        }
        else
        {
            
            Graphics.Blit(src,dest);
        }
    }
}
