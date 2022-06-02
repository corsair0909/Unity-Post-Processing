using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ChromaticAberration : MonoBehaviour
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

    [Range(0.0f, 0.5f)] public float rgbSplit = 0.1f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mate)
        {
            Mate.SetFloat("_rgbSplit",rgbSplit);
            Graphics.Blit(src,dest,Mate);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
