using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class Wave : MonoBehaviour
{

    public Shader shaer;
    private Material _material;

    public Material Mate
    {
        get
        {
            if (_material==null)
            {
                _material = new Material(shaer);
                return _material;
            }
            else
            {
                return _material;
            }
        }
    }

    [Range(0.0f, 30.0f)] public float DisFactor = 10;//用于在一定距离内获得更多波峰
    [Range(0.0f, 30.0f)] public float TimeFactor = 10;//一定时间内获得更多波峰
    [Range(0.0f, 30.0f)] public float SinFactor = 10;//整体获得更多波峰
    [Range(0.0f,1.0f)]
    public float WaveWidth = 0.0f;
    [Range(0.0f, 2.0f)] 
    public float WaveSpeed = 0.0f;
    public float WaveStartTime;
    public Vector4 startPos = new Vector4(0.5f, 0.5f, 0, 0);
    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Vector2 pos = Input.mousePosition;
            //记录波纹中心点，映射到 0-1区间
            startPos = new Vector4(pos.x/Screen.width, pos.y/Screen.height, 0,0);
            WaveStartTime = Time.time;//记录波纹开始时间
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mate)
        {
            float CurWaveDis = (Time.time - WaveStartTime) * WaveSpeed;
            Mate.SetFloat("_DisFactor",DisFactor);
            Mate.SetFloat("_TimeFactor",TimeFactor);
            Mate.SetFloat("_SinFactor",SinFactor);
            Mate.SetFloat("_WaveWidth",WaveWidth);
            Mate.SetFloat("_WaveSpeed",WaveSpeed);
            Mate.SetFloat("_CurWaveDis",CurWaveDis);
            Mate.SetVector("_startPos",startPos);
            Graphics.Blit(src,dest,Mate);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
