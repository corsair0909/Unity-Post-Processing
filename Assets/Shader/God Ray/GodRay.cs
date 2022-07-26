using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GodRay : MonoBehaviour
{

    public Shader shader;

    private Material _mat;
    
    public Transform lightTransform;
    
    public Color thresholdCol = Color.grey;
    public Color lightCol = Color.white;
    [Range(0.1f,3)]
    public float lightRadius = 0.5f;
    public float lightFactor = 0.5f;
    [Range(1,5)]
    public float PowFactor = 1;
    
    //模糊迭代次数
    [Range(1, 4)] public int iterator = 1;
    //下采样次数（下采样次数越大，需要模糊的次数越小，开小越小）
    [Range(1,4)] public int downSample = 2;
    //方向模糊偏移量
    [Range(0.0f, 10.0f)] public float samplerScale = 1;

    public Camera targetCamera;
    
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        _mat = new Material(shader);
        if (_mat && targetCamera)
        {
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;
            RenderTexture RT0 = RenderTexture.GetTemporary(rtW,rtH,0,src.format);
            
            //灯光位置从世界空间 -> 相机空间
            Vector3 lightPos = lightTransform == null ? new Vector3(0.5f, 0.5f, 0) 
                : targetCamera.WorldToViewportPoint(lightTransform.position);
            _mat.SetVector("_LightPos",lightPos);
            _mat.SetVector("_ThresholdCol",thresholdCol);
            _mat.SetVector("_LightCol",lightCol);
            _mat.SetFloat("_LightRadius",lightRadius);
            _mat.SetFloat("_LightFactor",lightFactor);
            _mat.SetFloat("_PowFactor",PowFactor);

            //偏移uv，TexelSize表示一个像素，此处代表可以自己控制偏移的uv大小
            float samplerOffset = samplerScale / src.width; 
            Graphics.Blit(src,RT0,_mat,0);

            for (int i = 0; i < iterator; i++)
            {
                RenderTexture RT1 = RenderTexture.GetTemporary(rtW,rtH,0,src.format);
                float offset = samplerOffset * (i * 2 + 1);
                _mat.SetVector("_Offset",new Vector2(offset,offset));
                Graphics.Blit(RT0,RT1,_mat,1);
                
                offset = samplerOffset * (i * 2 + 2);
                _mat.SetVector("_Offset",new Vector2(offset,offset));
                Graphics.Blit(RT1,RT0,_mat,1);
                RenderTexture.ReleaseTemporary(RT1);
            }
            _mat.SetTexture("_BlurTex",RT0);
            //第三个pass完成后会返回到src上
            Graphics.Blit(src, dest, _mat, 2);
            RenderTexture.ReleaseTemporary(RT0);
        }
        else
        {
            Debug.Log(111);
            Graphics.Blit(src,dest);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
