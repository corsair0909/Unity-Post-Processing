using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DepthScan : MonoBehaviour
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
    public float scanValue = 0;
    [Range(0,0.1f)]
    public float scanLineWidth = 0;
    [Range(0,10)]
    public float scanLineStranger = 0;

    public Color scanLineColor;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mate)
        {
            Mate.SetFloat("_ScanValue",scanValue);
            Mate.SetFloat("_ScanLineWidth",scanLineWidth);
            Mate.SetFloat("_ScanLineStranger",scanLineStranger);
            Mate.SetVector("_ScanColor",scanLineColor);
            Graphics.Blit(src,dest,Mate);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
