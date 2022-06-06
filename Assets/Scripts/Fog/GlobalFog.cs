using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GlobalFog : MonoBehaviour
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
    
    private Camera _camera;
    public Camera Cam
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
    
    private Transform _transform;
    public Transform CamTrans
    {
        get
        {
            if (_transform==null)
            {
                _transform = Cam.transform;
                return _transform;
            }
            else
            {
                return _transform;
            }
        }
    }
    
    [Range(0.0f,3.0f)]
    public float fogDensity = 0;
    public Color fogColor = Color.white;
    [Range(0,5)]
    public float fogStart = 0;
    [Range(0,5)]
    public float fogEnd = 2;

    private void OnEnable()
    {
        Cam.depthTextureMode  |= DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mate)
        {
            Matrix4x4 furstum = Matrix4x4.identity;
            float fov = Cam.fieldOfView;
            float aspect = Cam.aspect;
            float near = Cam.nearClipPlane;
            float far = Cam.farClipPlane;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toTop = halfHeight * CamTrans.up;
            Vector3 toRight = halfHeight * CamTrans.right * aspect;

            Vector3 LT = CamTrans.forward * near + toTop - toRight;
            //采样四个顶点的深度得到的并非顶点到相机的欧式距离，而是在Z轴方向上的距离
            //深度/距离（顶点到相机距离） = 近裁剪平面距离/距离的模长（顶点到相机距离）
            float scale = LT.magnitude / near;
            LT.Normalize();
            LT *= scale ;
        
            Vector3 RT = CamTrans.forward * near + toTop + toRight;
            RT.Normalize();
            RT *= scale;
        
            Vector3 LB = CamTrans.forward * near - toTop - toRight;
            LB.Normalize();
            LB *= scale;
        
            Vector3 RB = CamTrans.forward * near - toTop + toRight;
            RB.Normalize();
            RB *= scale;
        
            furstum.SetRow(0,LT);
            furstum.SetRow(1,RT);
            furstum.SetRow(2,LB);
            furstum.SetRow(3,RB);
        
            Mate.SetMatrix("_furstum",furstum);
            Mate.SetMatrix("ViewPrjiectionInverseMatrix",(Cam.worldToCameraMatrix*Cam.projectionMatrix).inverse);
            Mate.SetFloat("_Density",fogDensity);
            Mate.SetColor("_fogColor",fogColor);
            Mate.SetFloat("_fogStart",fogStart);
            Mate.SetFloat("_forEnd",fogEnd);
        
            Graphics.Blit(src,dest,Mate);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
