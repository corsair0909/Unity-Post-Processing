# Unity-Post-Processing 屏幕后处理
## [一、Bloom](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Assets/Shader/Bloom1.shader)


### 效果
![Bloom效果](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Bloom1.png) 
### 实现思路
#### 1、多个Pass负责不同的步骤
Bloom =提取较亮部像素 + 模糊 + 叠加。需要RenderTexture保存临时计算结果。  
选择高斯正态分布函数对图像进行卷积（高斯模糊是一种方法，效果好但性能较差，）//TODO 尝试替换为均值模糊  
因其正态分布特性，可以优化为水平+竖直方向两次卷积计算结果的累加
#### 2、计算公式
像素亮度取决于RGB三个通道的贡献值  
L = Color.r * 0.2125 + Color.g * 0.7154 + Color.b * 0.0721
### Bloom扩展 GodRay   
<img width="1283" alt="截屏2022-07-26 11 59 57" src="https://user-images.githubusercontent.com/49482455/181155176-846d6ab4-9fca-434f-81dd-128aca6ed704.png">


<img width="1283" alt="截屏2022-07-26 11 59 48" src="https://user-images.githubusercontent.com/49482455/181155185-6ea0cd9d-3470-44a1-b1e4-9dc30a919166.png">


### 参考链接
[Unity Shader - Bloom(光晕、泛光)](https://developer.unity.cn/projects/5ebca6b0edbc2a00200fb9ef)

## [二、边缘检测](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Assets/Shader/Outline.shader).


### 效果图 
<img width="986" alt="截屏2022-06-01 16 36 46" src="https://user-images.githubusercontent.com/49482455/171429871-cd7b4444-7f0e-4112-9cc0-55053e2b50cf.png">   


### 实现思路  
#### 1、卷积运算      
如果一张图像的相邻像素之间存在比较明显的亮度/颜色差异，我们就认为像素之间存在一条边缘线，相邻像素之间的差值称之为梯度。      
选择合适的卷积核对图像像素进行计算，Sobel算子是边缘检测中常用的卷积核。卷积结果的值反映了像素块的梯度值，梯度值越大越有可能是边缘。即变化越剧烈，越有可能是边缘     
#### 2、灰度图      
计算前需要先将原始图像转化为灰度图，方便比较  
灰度心理学公式：Gray = Color.r * 0.299 + Color.g * 0.587 + Color.b * 0.0114       
### [基于深度法线纹理的边缘检测](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Assets/Shader/Outline2.shader)
<img width="657" alt="截屏2022-06-02 17 02 15" src="https://user-images.githubusercontent.com/49482455/171650106-7eb32459-2c86-4be0-b5e9-c4c1af74bf4e.png">     
基于深度法线纹理的边缘检测可以解决阴影等不该出现边缘的情况，深度法线纹理中只包含了渲染物品的信息，不会出现阴影部分的信息。使用Roberts算子。  
Robert算子是一个4x4的卷积核，比较（左上角和右下角的差）乘以（右上角和左下角的差）。  
<img width="137" alt="截屏2022-06-02 22 22 01" src="https://user-images.githubusercontent.com/49482455/171651558-25d772d2-9710-44e8-9791-56d7b5ccdcfb.png">     
### 参考链接
[Unity Shader - 边缘检测](https://developer.unity.cn/projects/5e5f8620edbc2a04780b586e)  
《Unity Shader入门精要》



### 后处理描边

先将图片模糊（本例使用高斯模糊算法）。模糊后的图像需要描边的部位会发生膨胀。然后用一个返回纯色的shader渲染画面保存到RenderTexture上。模糊图-RenderTexture = 膨胀部分（边缘）。

<img width="337" alt="截屏2022-07-06 12 35 15" src="https://user-images.githubusercontent.com/49482455/178142392-e4b2595c-5a9d-4f75-8fe5-44c938181762.png">



## [三、运动模糊](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Assets/Shader/MotionBlur2.shader)

### 基于速度缓冲的运动模糊  

### 效果图
![QQ20220616-113202-HD](https://user-images.githubusercontent.com/49482455/174082409-03033e34-aad1-455e-80b3-ebf7efd602f0.gif)


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

## [五、全局雾](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Assets/Shader/GlobalFog.shader)  
### 效果图  
<img width="668" alt="截屏2022-06-06 09 50 37" src="https://user-images.githubusercontent.com/49482455/172373466-8be5b0f1-75e8-4e13-b53c-13ebfdd64c8b.png">

### 实现思路  
 基于射线的重建世界坐标的方法。将近裁剪平面的四个角点传递到片元着色器中，片元着色器会进行插值得到其他位置的顶点。worldPos = WorldCameraPos + Depth * Ray（相机到顶点的射线）。    

 halfHeight = near * tan(FOV/2)  
 ToTop = cam.up * halfHeight    
 ToRight = cam.right * halfHeight * aspect  
 TL = cam.forward * near + ToTop - ToRight 以此类推即可求得其他三个角点的位置  

 以左上角点为例 根据相似三角形：Depth/dist = |TL| / NearClipPanel 。根据上述公式即可求得角点到相机的欧氏距离dist。
 其中Depth可由深度纹理采样得出，深度纹理采样的结果并不是角点到相机的欧式距离，而是角点再Z轴方向的距离。
 #### 雾因子计算  
 根据重建后的世界位置坐标的高度Y分量计算雾因子，再与雾系数相乘后得到雾强度因子，再源图和雾颜色直接过度。
 
 ### 参考链接  
 《Shader入门精要》  
 
## [基于屏幕后处理的故障效果](https://github.com/corsair0909/Unity-Post-Processing/blob/main/Assets/Shader/BadTV.shader)
### 效果图  
![QQ20220609-110514-HD](https://user-images.githubusercontent.com/49482455/172755611-33097489-0534-417b-a9ed-ae28c802fcc5.gif)

### 实现思路  
故障效果在水平方向上使用噪音，竖直方向上进行抖动，以及通道分离效果.   
1、噪音计算公式：frac(sin(X * float2(12.9898, 78.233))*43758.5453).     
2、抖动方向：故障效果在水平和竖直方向上均有抖动，在C#端分别设置抖动强度和抖动瓶频率传入着色器，竖直方向的抖动可将uv在该方向上根据时间偏移。水平方向上计算噪音.   
3、通道偏移：计算好通道偏移量后在对需要分离的通道加上偏移.   
4、噪音拉伸： step函数截断在0-阈值之间值，乘上拉伸强度.     
### 信号干扰。  
![信号干扰](https://user-images.githubusercontent.com/49482455/172756133-fc3d3b0d-87b1-4394-8985-9fb3985c394d.gif)
#### 思路。  
1、扭曲：根据参数在uv的连个分量上计算扭曲程度，合成distortUV。      
2、白噪音计算：噪音uv的两个分量上分别计算两次噪音，然后合成NoiseUV    
3、通道偏移：分别计算rgb通道的值，对其中的通道增加偏移量    
### 参考链接        
[Unity信号干扰Shader](https://blog.csdn.net/SnoopyNa2Co3/article/details/84673736).   
[Unity信号干扰shader（参照崩坏3源码翻译剧情对话效果）](https://blog.csdn.net/SnoopyNa2Co3/article/details/86629436).   
[大佬的github](https://github.com/csdjk/LearnUnityShader).  
[Unity缓动函数Lerp](https://www.cnblogs.com/louissong/p/3204447.html)    

## [场景深度扫描](https://github.com/corsair0909/Unity-Post-Processing/tree/main/Assets/Scripts/DepthScan).   

### 实现思路    
采样深度贴图并将其转换为线性深度，用于和深度控制值比较，符合条件的深度（深度大于当前值，当前值+扫描线宽度值）的位置着色为扫描线颜色。  
<img width="1311" alt="截屏2022-06-13 17 28 10" src="https://user-images.githubusercontent.com/49482455/173323598-92c5969a-b74b-45e8-a8da-3d8405f4eec4.png">

## [波浪](https://github.com/corsair0909/Unity-Post-Processing/tree/main/Assets/Shader/Wave)
### 效果图
![QQ20220614-145233-HD](https://user-images.githubusercontent.com/49482455/173618529-782f1047-2e6a-4cbe-8885-ef68e9411e4b.gif)

### 实现思路    
1、波浪属性：波浪的几种属性分别为波浪速度、波浪开始时间，当前距离、波浪宽度。    
开始时间=鼠标按下的时间，波浪距离 = 速度*时间
2、正弦波属性：使用正弦函数得到正弦波形，距离影响因子、时间影响因子、正弦波影响因子分别用于在单位距离内获得更多的波形、单位时间内获得更多波形、整体更多波形。   
3、波浪影响位置计算图下图所示，求出所有uv坐标点距离开始点的距离（插值得到所有uv坐标，勾股定理求的距离），当前距离-uv距离<波浪宽度说明要收到波浪影响，
![IMG_1147](https://user-images.githubusercontent.com/49482455/173620449-dd525536-ebac-43bf-8cbf-acadb79ad0d4.png)

## [SSAO](https://github.com/corsair0909/Unity-Post-Processing/tree/main/Assets/Shader/SSAO)   
    
<img width="1283" alt="截屏2022-07-26 18 19 00" src="https://user-images.githubusercontent.com/49482455/181150645-78b87c99-f817-44db-bdfc-b479be377f14.png">    

> 通过将褶皱、孔洞和非常靠近的墙面变暗的方法近似模拟出间接光照。这些区域很大程度上是被周围的几何体遮蔽的，光线会很难流入，所以这些地方看起来会更暗一些     
### SSAO算法实现思路    
#### 计算AO    
> AO值反映了该点反射出去的光被周围集合体遮挡住的比例，AO越大越暗，以下计算都在视角空间完成，视角空间下位置由深度反推出来     

1、使用屏幕坐标采样深度法线贴图，获取该像素的深度。    
2、通过获得的深度反推出顶点在视角空间下的位置。（百人计划教程选择了视角空间，空间选择无所谓，也可以从世界空间下计算）    
3、随机向量：采样深度法线图得到的法线结果与随机向量通过施密特正交化计算与法线垂直的向量，叉乘得到向量构建正交基组成TBN矩阵。    
4、在法线半球内设置随机采样点。将随机采样带你转进切线空间。    
5、求出每个采样点的屏幕空间坐标（透视除法后映射到[0-1]范围内），然后求出采样点的深度，与顶点深度比较，若深度大于顶点深度，则认为该采样点方向的光线被遮挡。得到的值加权到AO中。    
下图中，深色的采样点就是被遮挡的点。    
<img width="559" alt="截屏2022-06-16 21 46 30" src="https://user-images.githubusercontent.com/49482455/174086596-4528bc2b-90da-4f50-a1ea-11f78eebb286.png">     
#### 模糊（优化方案）  
高斯模糊或均值模糊均可，本例中采用均值模糊      
#### 范围判断(优化方案)    
防止距离过远的两个物体之间产生AO。    
abs（随机点深度 - 顶点深度）> 距离阈值 则表明对AO没有贡献。    
#### 同一平面(优化方案).    
随机点深度和顶点深度相差过小时，可能导致同一平面内差生AO，随机点深度 + bias < 顶点深度 则对AO有贡献
#### 合并图像               
AO图与源图混合完成SSAO                      
### 参考链接       
[百人计划 4.2 SSAO算法](https://blog.csdn.net/m0_37686228/article/details/121080869).          
[Unity Shader-Ambient Occlusion环境光遮蔽](https://blog.csdn.net/puppet_master/article/details/82929708).          
[游戏后期特效第四发 -- 屏幕空间环境光遮蔽(SSAO)](https://zhuanlan.zhihu.com/p/25038820).         
[Unity从深度缓冲中重建世界位置](https://zhuanlan.zhihu.com/p/92315967).           
[环境遮罩之SSAO原理](https://zhuanlan.zhihu.com/p/46633896).   
[Unity SSAO落地实现](https://zhuanlan.zhihu.com/p/510620589).   

