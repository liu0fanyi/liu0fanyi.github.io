## [tinyRenderer笔记-lesson4](https://github.com/ssloy/tinyrenderer/wiki/Lesson-4:-Perspective-projection)

## 2d 几何学
### linear transformations 线性变换
* 可以写成关系矩阵，corresponding matrix，这个中文翻译都怪怪的，就这样吧
* 最简单的是单位阵identity，不干任何事
* 对角系数矩阵可以缩放大小,diagonal coefficients of the matrix, slong coordinate axes，沿着坐标系轴向，
* 红绿线是unit length vectors 单位长度向量，白色边框通过缩放矩阵会变成黄色的那个
* 代码
* 在这个表达式(expression)中,变换矩阵(transformation matrix)与前一个表达式中的相同,但是2x5的矩阵实际上就是我们正方体对象的顶点(vertices of our squarish object)。我们简单地取出数组中的所有顶点(multiplied it by the transformation),将其与变换矩阵相乘,就可以得到变换后的对象。
* 真实情况是，需要做多次变换，如果正常使用，会无限嵌套比如：
``` rust
vec2 foo(vec2 p) return vec2(ax+by, cx+dy);
vec2 bar(vec2 p) return vec2(ex+fy, gx+hy);
[..]
for (each p in object) {
    p = foo(bar(p));
}
```
* 这玩意儿进行了两次线性变换，对每一个顶点，经常我们要折腾vertices in millions，tens of transformations in a row，并不是很稀罕，很常见。这样开销非常昂贵，但在矩阵形式下，就可以提前将变换矩阵乘在一起，然后一次变换所有的顶点。
* For an expression with multiplications only we can put parentheses where we want, can we?对于只有乘法的表达式我们可以任意添加括号么(parentheses)可以，矩阵乘法支持结合律
* 另一个对角填数字会导致倾斜，这里叫shearing,切变，中文不是很形象，分别会沿着x轴和y轴倾斜
* 而rotation，可以被表现为composite action of three shears，这里白色的先shear到红色，然后到绿色，最后到蓝色，三次shear
* 实际上rotation有自己的transform 式子
* 注意矩阵乘法不满足交换律
* 所以先shear再rotate不等于先rotate再shear

## 2d 仿射变换 affine transformations
* 在线性后添加平移
* 可以旋转，缩放，shear，和平移
* 但当我们需要处理很多的类似操作时，变得难看了起来
  
## Homogeneous coordinates齐次坐标
* 将平移的部分translate与前面线性的部分进行组合，组合成3x3矩阵，然后再补充一排001，和1，能得出我们要的结果
* 道理上是，原本加上平移变换的整体变换，在2d上是非线性的，因而扩展2d到3d。说明原来的2d部分位于一个z=1的3d平面上，然后做一个3d的线性变换，然后投影到2d平面上去。
* 简单的3d投影到2d平面就是通过dividing by the 3d component

## wait a second, it is forbidden to divide by zero
* 这里得注意之前的式子，主要是通过三维的变换，将x,y,1变换成一个新的，并需要/z
* 步骤
  * embed 2d into 3d，放到plane z = 1
  * 做点啥我们想的在3d里，这里有点太糊弄人了吧
  * 对于任意点，我们希望从3d映射回2d，我们画一个直线，在origin和需要Porject的point，然后我们能找到他与plane z=1的交点 intersection
* 这图里，那个粉红色的是z=1平面，xyz与z平面的交点是x/z,y/z,1
* 想象一个垂线经过了xy1,会把xy1映射到xy0
* 然后不知道为啥又找了个xy1/2，之后能找到2x,2y,1，这里是通过与xy1/2连线与平面z=1交点是2x，2x，1，但不清楚这一步的意义
* 继续，在x,y,1/4上能找到4x,4y,1
* 如果我们继续这个过程，直到z = 0，然后projection 越走越远，从xy1,到2x2y1到4x4y1，也就是point xy0被projected onto（投影到） 到一个无限的点，在xy的方向上的一个无限远的点，就是一个向量。我不太清楚这里要表达的意思TODO:这是一个向量这怎么了？这里不明白，感觉没说清楚在干啥，目的是什么？
* 齐次坐标系可以区分vector和point，如果programmer 写了个vec2(x,y)是vector还是point。很难说，在齐次坐标系里，所有z=0都是vectors，所有剩下的都是points。

## A composite transormation
* 我们现在知道如何平移translate和旋转rotate，因而现在需要在任意位置旋转，只需要先平移回原点，旋转，再平移回来即可，显示的这个M需要左乘，所以是先-x0,-y0最后再加回去
* 3d同理

## Wait a minute, may i touch this magical bottom row of the 3x3 matrix
* 现在动一下第三行的数字
* 是否记得y-buffer exercise？这里做的是相似的：我们投影我们的2d object 到vertical line x = 0（就是由于是2d的，所以我们的屏幕现在只有一条线，可以理解为屏幕的侧边），将我们的2d形状，投影到x=0的垂线上，强化一些规则：我们必须使用中心投影（TODO:啥？central projection)我们的照相机在5，0位置，并指向了原点。要找到投影,我们需要在相机和要投影的点(黄色)之间绘制直线,并找到与屏幕线(白色垂直线)的交点。要找到投影，需要在相机和要投影的点(yellow)之间找交点
* 标准正交投影是一种简单的投影方式,它的特点是:
1. 平行于投影平面(屏幕)的线段在投影后仍然平行。
2. 它会保持图像的几何形状不变,只有尺寸会有变化。
3. 它的变换矩阵是一个简单的缩放矩阵,没有斜方向的因子。
4. 标准正交投影产生的图像没有透视效果,不同距离的物体 size 的变化比例是一致的。
标准正交投影的变换矩阵是:
[s   0   0   0]
[0   s   0   0]  
[0   0   s   0]
[0   0   0   1]
其中s是缩放因子。
相比而言,透视投影的变换矩阵是:
[s   0   0   0]  
[0   s   0   0]
[0   0   s   0]
[0   0   1/s  0] 
* 如果我们投影红色物体在屏幕上，使用了标准正交投影（standard orthogonal projection), 我们会得到完全相同的点。看一下how the transformation works: 所有垂直的线段，被变换成垂直的线段，但是那些接近相机的，被拉伸，而远离摄像机的，被压缩。如果我们选择的系数正确（这里选择的是-1/5)，我们会得到一个image in perpective(central) projection，会得到一个透视投影

## Time to work in full 3d
* 根据之前的变换，得到了变换矩阵
* 这个retro-projectionTODO:没理解是什么意思，虽然我大概记得要除以w来得到真实坐标位置
* 现在来看一下中心投影central projection， 一个点P xyz, 投影到z= 0，相机在00c的位置
* 三角形ABC和ODC是相似的，因而能写出下式，以及y的运算是相似的
* 对于这个透视变换，为什么放在w[2]位置就能形成透视变换呢？因为乘起来后，刚好能在结果里得到那个相似三角形的计算结果

## 总结今日的公式
* 如果根据一个camera来计算central projectiong。camera在z轴，距离c from origin，然后我们扩展到4d by augmenting it with 1，乘那个矩阵，将其投影进3d
* 忽略z坐标就会获得透视效果。但如果要使用z-buffer，就需要使用z

* TODO:公式和图片后边补充，感觉还有些部分需要整理