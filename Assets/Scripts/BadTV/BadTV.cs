using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class BadTV : MonoBehaviour
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
    
    //扫描线抖动
    [Range(0,1)]
    public float scanLineShake = 0.02f;
    //竖直方向抖动
    [Range(0.0f,1.0f)]
    public float vertivalShake = 0;
    //水平方向抖动
    [Range(0.0f,1.0f)]
    public float horizontalShake = 0;
    //颜色分离抖动
    [Range(0.0f, 1.0f)] 
    public float colorDirft = 0;

    private float verticalShakeTime;
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mate)
        {
            verticalShakeTime = Time.deltaTime * vertivalShake * 11.3f; //经验值
            //扫描线抖动设置
            var sl_thresh = Mathf.Clamp01(1.0f - scanLineShake * 1.2f);//阈值
            var sl_disp = 0.002f + Mathf.Pow(scanLineShake, 3) * 0.05f;
            Mate.SetVector("_ScanLineJitter", new Vector2(sl_disp, sl_thresh));

            var vj = new Vector2(verticalShakeTime, vertivalShake);
            Mate.SetVector("_VerticalJump",vj);
            
            Mate.SetFloat("_HorizontalShake",horizontalShake*0.2f);
            
            //颜色通道分离偏移量
            var cd = new Vector2(colorDirft * 0.04f, Time.time * 606.11f);
            Mate.SetVector("_ColorDrift", cd);
            Graphics.Blit(src,dest,Mate);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
