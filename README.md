# Unity-Post-Processing 屏幕后处理
## [一、Bloom](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Assets/Shader/Bloom1.shader)


### 效果
![Bloom效果](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Bloom1.png) 
### 实现思路
#### 1、多个Pass负责不同的步骤
Bloom =提取较亮部像素 + 模糊 + 叠加。需要RenderTexture保存临时计算结果。  
选择高斯正态分布函数对图像进行卷积（高斯模糊是一种方法，效果好但性能较差，）//TODO 尝试替换为均值模糊  
因其正态分布特性，可以优化为水平+竖直方向两次卷积计算结果的累加
#### 2、亮度计算公式
像素亮度取决于RGB三个通道的贡献值  
L = Color.r * 0.2125 + Color.g * 0.7154 + Color.b * 0.0721
### 参考链接
[Unity Shader - Bloom(光晕、泛光)](https://developer.unity.cn/projects/5ebca6b0edbc2a00200fb9ef)

## [二、边缘检测](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Assets/Shader/Outline.shader).  
### 效果图 
<img width="986" alt="截屏2022-06-01 16 36 46" src="https://user-images.githubusercontent.com/49482455/171429871-cd7b4444-7f0e-4112-9cc0-55053e2b50cf.png">   
### 实现思路  
#### 1、卷积运算  
选择合适的卷积核对图像像素进行计算，Sobel算子是边缘检测中常用的卷积核，卷积结果的值反映了像素块的梯度值，梯度值越大越有可能是边缘。即变化越剧烈，越有可能是边缘  
#### 2、灰度图  
计算前需要先将原始图像转化为灰度图，方便比较  
灰度心理学公式：Gray = Color.r * 0.299 + Color.g * 0.587 + Color.b * 0.0114  
### 参考链接
[Unity Shader - 边缘检测](https://developer.unity.cn/projects/5e5f8620edbc2a04780b586e)

## [三、运动模糊](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Assets/Shader/MotionBlur2.shader)

### 基于速度缓冲的运动模糊  

### 效果图
<img width="987" alt="截屏2022-06-01 16 36 09" src="https://user-images.githubusercontent.com/49482455/171433152-0174697f-0fce-4b49-b085-0617feb6081f.png">  

### 实现思路

C#端中取得当前帧的VP矩阵（相机*投影矩阵）的逆矩阵用于根据NDC坐标计算顶点在世界空间中的坐标  

C#端取得上一帧的VP矩阵用于根据世界空间坐标计算上一帧的NDC坐标.   

根据上一帧和当前帧两点之间的位移量计算该点的速度.     

对像素周围几个点采样后取平均值（均值模糊）.   

NDC坐标：NDC坐标是经过MVP矩阵变换后再进行了归一化的坐标，只需要一步就能变成屏幕空间坐标  
深度纹理和NDC坐标的关系：深度纹理记录的深度对应的是NDC坐标的Z分量，深度纹理取值范围[0,1],NDC坐标取值范围[-1,1]。因此 深度和NDC的Z分量存在  
D = Zndc * 0.5 + 0.5;
NDC = (uv,Depth * 2 - 1)

### 参考链接
[Unity Shader实现运动模糊](https://blog.csdn.net/h5502637/article/details/85002792)

《Unity Shader入门精要》

## [四、色差](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Assets/Shader/ChromaticAberration.shader)

### 效果图
<img width="658" alt="截屏2022-06-02 17 10 12" src="https://user-images.githubusercontent.com/49482455/171648378-c91b60b7-bdf7-4aec-9713-f35f28ed0703.png">

### 实现思路
对原图的R通道和B通道添加偏移量  
#### 点积Dot
两个向量方向相同时，其夹角为0，点积结果为1，也就是说相同向量的点积气结果是向量的平方。  
> float1的dot(a,b)是a * b，float2的dot(ab,cd)是 (a * c + b * d)。相同向量进行内积计算时，float1的dot(x,x)是x^2 (x平方)，float2的dot(xy,xy)是 x^2 + Y^2(同理float3的dot(xyz,xyz)是 x平方 + y平方 + z平方)。  
圆的标准方程 ：X^2 + Y^2 = r^2
上述公式可以得到一个圆，使得色差效果的影响范围是一个圆。




