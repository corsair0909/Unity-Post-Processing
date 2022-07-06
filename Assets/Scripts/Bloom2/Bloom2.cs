using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Bloom2 : MonoBehaviour
{
    public Shader Shader;
    private Material material;
    public Material Mat//属性
    {
        get 
        {
            if(material==null)
            {
                material = new Material(Shader);
                return material;
            }
            else
            {
                return material;
            }
        }
    
    }


    [Range(0,4)]
    public int interation = 3;
    [Range(0,4)]
    public int downSample = 2;

    [Range(-1,1)]
    public float Threshold = 0.6f;

    [Range(0,1)]
    public float blurSpread =0.6f;

    public Color color = new Color(1,1,1,1);

    [Range(0,6)]
    public float BloomFractor = 1;
    
    [Range(0,1.2f)]
    public float lum = 0.1f;


    private void OnRenderImage(RenderTexture src, RenderTexture dest) 
    {
        int rtW = src.width/downSample;
        int rtH = src.height/downSample;
        Mat.SetFloat("_LuminanceThreshold",Threshold);
        Mat.SetVector("_BloomColor",color);
        Mat.SetFloat("_Fractor",BloomFractor);
        RenderTexture buffer0 = RenderTexture.GetTemporary(rtW,rtH,0);
        RenderTexture buffer1 = RenderTexture.GetTemporary(rtW,rtH,0);
        Graphics.Blit(src,buffer0,Mat,0);
        for (int i = 0; i < interation; i++)
        {
            Mat.SetFloat("_blurSize",1.0f+i+blurSpread);
            Graphics.Blit(buffer0,buffer1,Mat,1);//水平方向高斯模糊
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0=buffer1;//保存水平方向模糊结果
            buffer1 = RenderTexture.GetTemporary(rtW,rtH,0);
            //竖直方向高斯模糊
            Graphics.Blit(buffer0,buffer1,Mat,2);
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;//竖直方向结果

        }
        RenderTexture ToneMappint = RenderTexture.GetTemporary(rtW,rtH,0);
        Mat.SetTexture("_blurTex",buffer0);
        Graphics.Blit(buffer0,dest,Mat,3);
        RenderTexture.ReleaseTemporary(buffer0);
        Mat.SetFloat("_Lum",lum);
        Graphics.Blit(ToneMappint,dest,Mat,4);
        RenderTexture.ReleaseTemporary(ToneMappint);
    }
}
