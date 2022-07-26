using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

[ExecuteInEditMode]
public class SSAO : MonoBehaviour
{
    public Shader aoShader;

    private Material aoMat;
    private Material blurMat;

    //public Camera Camera;

    [Range(0, 128)] public int samplerCount = 20;
    [Range(0.2f, 5)] public float aoRadius = 0.2f;
    [Range(0.2f, 10)] public float aoStrange = 0.2f;
    public Color aoColor = Color.black;
    public bool aoOnly = false;
    
    [Range(1,4)]
    public int dowmSample = 1;
    [Range(1, 5)] public int iterator = 2;
    [Range(0.2f, 10)] public float BlurSp = 2;
    
    private void Awake()
    {
        aoMat = new Material(aoShader);
        Camera.main.depthTextureMode |= DepthTextureMode.DepthNormals;
        //Debug.Log(8>>1);
    }
    
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (aoMat && !aoOnly)
        {
            int rtW = src.width;// >> dowmSample;
            int rtH = src.height;// >> dowmSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW,rtH,0,src.format);
            aoMat.SetFloat("_SampleCount",samplerCount);
            aoMat.SetFloat("_AoRadius",aoRadius);
            aoMat.SetFloat("_AoStrange",aoStrange);
            aoMat.SetVector("_aoColor",aoColor);
            //ao计算
            Graphics.Blit(src,buffer0,aoMat,0);
            
            aoMat.SetTexture("_AoTex",buffer0);

            if (aoOnly)
            {
                Graphics.Blit(buffer0,dest,aoMat,0);
            }
            
            //ao合并
            Graphics.Blit(buffer0,dest,aoMat,1);
            
            //RenderTexture.ReleaseTemporary(buffer1);
            RenderTexture.ReleaseTemporary(buffer0);

        }
        else
        {
            Graphics.Blit(src,dest);
        }

    }
}
