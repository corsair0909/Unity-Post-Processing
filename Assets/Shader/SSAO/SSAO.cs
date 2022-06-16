using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

[ExecuteInEditMode]
public class SSAO : MonoBehaviour
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

    public List<Vector4> sampleKernelPosList = new List<Vector4>();

    [Range(0.01f,1.0f)] //半球半径
    public float sampleKernelRadius = 1;
    [Range(4,32)]//半球内采样点数
    public int sampleKernelCount = 16;
    [Range(0.0f,5.0f)]//AO强度
    public float AOStrength = 1;
    [Range(0, 2)] //下采样
    public int dowmSample = 2;
    [Range(1,4)] //模糊系数
    public int blurRadius = 1;

    public float BilaterFilterFactor = 0;


    public bool isOnlyAO;
    enum PassName
    {
        AOPass,
        BlurPass,
        CombilePass
    }
    
    private void OnEnable()
    {
        Cam.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    private void OnDisable()
    {
        Cam.depthTextureMode &= ~ DepthTextureMode.DepthNormals;
    }

    private void CreatSampleKernel(int num)
    {
        if (sampleKernelPosList.Count == sampleKernelCount)
        {
            return;
        }
        sampleKernelPosList.Clear();
        for (int i = 0; i < num; i++)
        {
            Vector4 sample = new Vector4(Random.Range(-1.0f, 1.0f), Random.Range(-1.0f, 1.0f), Random.Range(-1.0f, 1.0f), 1);
            sample.Normalize();//不会生成新的向量
            float scale = 1.0f / num;
            scale = Mathf.Lerp(0.01f, 1.0f, scale*scale);
            sample *= scale;
            sampleKernelPosList.Add(sample);
        }
    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mate)
        {
            CreatSampleKernel(sampleKernelCount);
            Mate.SetFloat("_sampleKernelRadius",sampleKernelRadius);
            Mate.SetFloat("_sampleKernelCount",sampleKernelCount);
            Mate.SetVectorArray("_sampleKernelPosList",sampleKernelPosList.ToArray());
            Mate.SetFloat("_AOStrength",AOStrength);
            Mate.SetFloat("_BilaterFilterFactor",BilaterFilterFactor);
            Mate.SetMatrix("_InverseProjectMatrix",Cam.projectionMatrix.inverse);
            RenderTexture AOTex = RenderTexture.GetTemporary(Screen.width/dowmSample,Screen.height/dowmSample);
            Graphics.Blit(src,AOTex,Mate,(int)PassName.AOPass);
            RenderTexture BlurTex = RenderTexture.GetTemporary(Screen.width/dowmSample,Screen.height/dowmSample);
            Mate.SetVector("_blurRadius",new Vector4(blurRadius,0,0,0));
            Graphics.Blit(AOTex,BlurTex,Mate,(int)PassName.BlurPass);
            Mate.SetVector("_blurRadius",new Vector4(0,blurRadius,0,0));
            Graphics.Blit(BlurTex,AOTex,Mate,(int)PassName.BlurPass);
            if (isOnlyAO)
            {
                Graphics.Blit(BlurTex,dest,Mate,(int)PassName.BlurPass);
            }
            else
            {
                Mate.SetTexture("_AOTex",AOTex);
                Graphics.Blit(src,dest,Mate,(int)PassName.CombilePass);
            }
            
            RenderTexture.ReleaseTemporary(AOTex);
            RenderTexture.ReleaseTemporary(BlurTex);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
