# Unity-Post-Processing 屏幕后处理
## 一、Bloom
### 效果
![Bloom效果](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Bloom1.png) 
![ ](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Bloom2.png)


### 实现思路
#### 1、多个Pass负责不同的步骤
Bloom =提取较亮部像素 + 模糊 + 叠加。需要RenderTexture保存临时计算结果。
选择高斯正态分布函数对图像进行卷积（高斯模糊是一种方法，效果好但性能较差，）//TODO 尝试替换为均值模糊
因其正态分布特性，可以优化为水平+竖直方向两次卷积计算结果的累加

### 参考链接
[Unity Shader - Bloom(光晕、泛光)](https://developer.unity.cn/projects/5ebca6b0edbc2a00200fb9ef)
