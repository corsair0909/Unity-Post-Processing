using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MotionBlurFromDepth : MonoBehaviour
{
    public Shader shader;
    [Range(0,1)]
    public float BlurSize = 0.5f;
    
    
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

    private Camera _camera;
    public Camera Camera
    {
        get
        {
            if (_camera==null)
            {
                _camera = GetComponent<Camera>();
                return _camera;
            }
            else
            {
                return _camera;
            }
        }
    }

    private Matrix4x4 preViewProjectionMatrix4X4;
    private Matrix4x4 currViewProjectionInverseMatrix4X4;
    
    //需要传递当前帧的相机*投影矩阵的逆矩阵和上一帧的相机*投影矩阵
    //根据当前VP的逆矩阵获得当前帧的世界坐标
    //在将其于上一帧的VP矩阵计算上一帧的屏幕坐标
    //即可得出运动速度
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Material)
        {
            Material.SetFloat("_BlurSize",BlurSize);
            Material.SetMatrix("_PreVpMatrix",preViewProjectionMatrix4X4);
            Matrix4x4 currentVPMatrix = Camera.projectionMatrix * Camera.worldToCameraMatrix;//当前的VP矩阵
            Matrix4x4 currentInverseVpMatrix4X4 = currentVPMatrix.inverse;
            Material.SetMatrix("CurInverseVPMatrix",currentInverseVpMatrix4X4);
            //保存当前帧的VP矩阵，在新一帧开始时传递给着色器
            //也就是相对于新一帧来说，上一帧的VP矩阵
            preViewProjectionMatrix4X4 = currentVPMatrix;
            
            Graphics.Blit(src,dest,Material);
        }
        else
        {
            Graphics.Blit(src,dest);
        }

    }
}
