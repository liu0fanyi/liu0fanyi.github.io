## [tinyRenderer笔记-lesson5](https://github.com/ssloy/tinyrenderer/wiki/Lesson-5:-Moving-the-camera)

## 号称最后一点几何学
* 下面的人头用的是gouraud shading，一种多边形着色技术，跟phong着色法不一样，主要靠顶点插值
``` 引用
Gouraud着色是一种多边形着色技术,它的工作原理是:
1. 计算多边形的每个顶点的着色值(比如法向量和光照计算得到的颜色)。
2. 绘制多边形时,进行插值计算以获取多边形内部每个像素的着色值。
3. 它假定多边形内部的着色是由顶点着色值连续地插值而来的。
所以,Gouraud着色的主要步骤是:
1. 着色顶点:在顶点着色器中计算每个顶点的最终颜色(通常利用法向量和光照计算得到)。
2. 插值颜色:将顶点颜色插值到多边形内部的每个像素,以获取像素颜色。
3. 优点:比较简单,可以较好地处理光滑曲面,减少马赛克效应。
4. 缺点:不能很好地处理高光和硬边界,会产生“混浊”效果。
5. 适用场景:光滑曲面,复杂几何体等。
相比而言,Phong着色着重于在每个像素计算光照并着色,可以产生更加真实的高光和硬边界效果,但对复杂几何更加昂贵。
所以,总结来说,Gouraud着色的主要特征是:
1. 在顶点计算最终颜色,然后插值到像素
2. 产生光滑的着色效果,但高光和硬边界不够真实
3. 简单且高效,适用于光滑曲面
4. 三角形插值,所以多边形近似作为组成的三角形来着色
它是一种简单实用的多边形着色技术,能够在一定程度上减少马赛克效应,但不能像Phong着色那样产生真实的高光和阴影效果。
```
* 艺术家给我们normal vectors to each vertex，每个顶点的法线向量，可以在vn x y z，在obj file，计算每一个顶点的intensity，而不是每个三角形，然后简单做interpolate（插值）intensity，在每个三角形内，就像我们之前对z和uv坐标做的一样
* 如果没有提供好的法向量，可以recompute the normal vectors as an average of normals to all facets incident to the vertex，可以计算相邻facets(面片)的法向量的平均值，说实在不太懂TODO:应该举个栗子

## 更改3d space的basis
* 在欧拉space中，坐标系可以用 a point(the origin) and a basis表示，就是用一个原点和一组基来表示，如公式所示
* 假设我们有了另一个O和ijk，一个新的坐标系，我们如何把原本的xyz，转移到新的frame里去，（这里的frame看似是表示坐标系，实际有什么说法么），如果这俩都是3d里的一组基，那一定存在一个非退化的M(这个我知道，刚学过，就是eigenvalue不会相等，导致eigenvector的数量少于正常数量)能让一组基变成另一组基
* 然后就是算出来这个M
* 这里的向量都缺乏解释，很难看懂=_=，第一个能看到，就是ijk * O'的坐标，能得到OO'向量，ok，然后是后面的那个，基变了，看不懂了，TODO:，好吧，根据后面的x'y'z'要理解成在基为i'j'z'的时候，P点的坐标，也就是这个向量，虽然在不同坐标下，点坐标不同，但是向量本身还是一样的，是要这么理解么？也就是在整个3d空间里，frame不同，但是basis*point的坐标如果相等，得到的向量都是同一个
* 然后继续表示，将i'j'z'换成M*ijk表示
* 然后能获得转换后的公式

## 现在可以搞gluLookAt
* 在opengl里，我们只能渲染场景当camera在z轴上的时候，如果我们要移动cemara，没问题，我们移动整个scene，让相机固定
* 我们想搞个scene，camera，在point e，相机应该看向point c center，给一个vector u(up)，垂直于最终的渲染
* 看图
* 这说明我们想在frame c xyz坐标系里做渲染，但是我们的model是给在frame o xyz里，没问题，我们要做的就是计算坐标变换。
* 下面是4x4 matrix ModelView:
``` c++
void lookat(Vec3f eye, Vec3f center, Vec3f up) {
    // 眼睛到新原点的向量为z
    Vec3f z = (eye-center).normalize();
    // up和z的叉积出x
    Vec3f x = cross(up,z).normalize();
    // x和y的叉积出y
    Vec3f y = cross(z,x).normalize();
    Matrix Minv = Matrix::identity();
    Matrix Tr   = Matrix::identity();
    // 以及movelview变换
    // 这个矩阵的样子？
    // Minv
    /* [    x[0], x[1], x[2], 0
            y[0], y[1], y[2], 0
            z[0], z[1], z[2], 0
            0, 0 ,0 1
    ]*/
    // Tr，确实是平移到eye位置，但文章中对这个缺乏解释..
    /*[
        1, 0, 0, eye[0]
        0, 1, 0, eye[1]
        0, 0, 1, eye[2]
        0, 0, 0, 1
    ]*/
    
    for (int i=0; i<3; i++) {
        Minv[0][i] = x[i];
        Minv[1][i] = y[i];
        Minv[2][i] = z[i];
        Tr[i][3] = -eye[i];
    }
    ModelView = Minv*Tr;
}
```
* 注意z是由vector ce给出的（不要忘记标准化）
* 我们怎么计算x'?直接cross product u和z'，然后我们计算y',它正交于x',z'，在我们的问题中，ce和u不必须正交。
* 最后是把origin平移到e，matrix就准备好了TODO:这里不太清楚
* 名字modelview来自opengl，

## viewport
* 终于回到迷惑点上了
* 之前一直用的平移缩放操作
``` c++
screen_coords[j] = Vec2i((v.x+1.)*width/2., (v.y+1.)*height/2.);
```
* 表示有一个点v，在[-1, 1]\*[-1,1]内，我想把它画到(width, height)的image上，(v.x + 1) 映射到0-2，/2给干到0-1，然后\* width 就全了
* we effectively mapped the bi-unit square onto the image，我要认为obj默认的坐标范围都是-1,1和-1,1内的么？
* 现在改成矩阵形式，上节课的代码里已经改过了
``` c++
Matrix viewport(int x, int y, int w, int h) {
    Matrix m = Matrix::identity(4);
    m[0][3] = x+w/2.f;
    m[1][3] = y+h/2.f;
    m[2][3] = depth/2.f;

    m[0][0] = w/2.f;
    m[1][1] = h/2.f;
    m[2][2] = depth/2.f;
    return m;
}
```
* 具体matrix见矩阵
* 这就是把[-1,1][-1,1][-1,1]，映射到[x,x+w][y,y+h][0,d],一个cube，不是rectangle TODO:这句没看懂，深度是用来计算z-buffer的，所以d只是个深度的分辨率，这里习惯用255，因为方便dump到颜色上，opengl里面这个叫做viewport matrix

## chain of coordinate transformations
* 现在组合到一起去，首先我们的models，比如一个character，一个角色，在一个local frame(object coordinates)里诞生，它们被插进了scene，scene有一个world coordinates世界坐标系，然后用变换矩阵，从一个变换到另一个，使用的是matrix Model，然后我们希望把它在camera frame(eye coordinates)里表示，变换矩阵叫view。然后我们用Projection矩阵来将scene投影到到平面上，由于也变换了scene所以叫cilp coordinates。最后我们画scene,然后将clip coordinates变换到screen coordinates的叫做viewport
* v from obj， 左乘，所以是先Model将local frame换到world coordinates，然后View将world coordinates换到eye coordinates，然后Projection有了透视得到clip coordinates，然后viewport将clip coordinates变换到screen coordinates
``` c++
Viewport * Projection * View * Model * v.
```
* 由于只画了一个单个物体，matrix Model就是identity, 就加入到matrix View里面去了，叫做ModelView

## transformation of normal vectors
* 一个事实：
  * 如果我们有一个模型以及该模型的法向量normal vectors(由艺术家提供),并且该模型使用仿射变换affine mapping进行变化,则法向量也需要进行变换,这个变换矩阵等于原始变换矩阵的逆矩阵的转置。
* 我遇到过很多程序员知道法向量变换这一事实,但对他们来说这仍然是黑魔法。事实上,它并不那么复杂。
* 举个例子,画一个二维三角形(0,0),(0,1),(1,0),以及一个垂直于斜边hypothenuse的向量n,(1,1)。
然后,我们将y坐标的值扩大2倍,x坐标保持不变。这样,三角形变成(0,0),(0,2),(1,0)。
如果我们以同样的方式变换向量n,它变成(1,2),这不再垂直于变换后的三角形边。
* 所以,要消除法向量变换中的“黑魔法”,我们需要理解一件简单的事情:我们不需要简单地变换法向量(因为它们可能不再正常),我们需要计算变换后模型的(新)法向量。
* 回到三维空间,我们有一个向量n = (A,B,C)。我们知道,通过原点且法向量为n的平面具有方程Ax+By+Cz=0。让我们一开始就用齐次坐标的矩阵形式写出来:
* 这里有个区分，因为ABC是vector，所以最后是0，由于xyz是个点，所以最后是1TODO:这个区分还是要注意一下
* 中间插个单位阵，用M^-1M表示
* 右括号中的表达式是对象的变换后的点。左括号中的是变换后对象的法向量!
* 按照标准约定,我们通常将坐标写成列向量(请让我们不要提起反变和协变向量的所有内容TODO:这里的contra- and co-variant vectors我不了解),所以我们可以将前面的表达式重写如下:
* 左括号告诉我们可以通过对原法向量应用仿射变换的逆转置矩阵来计算变换后对象的法向量。
* 请注意,如果我们的变换矩阵M是统一缩放(uniform scalings)、旋转(rotations)和平移(translations)(欧几里得空间的等距变换,an isometry of euclidean space)的组合,那么M等于它的逆转置,因为在这种情况下逆矩阵和转置矩阵相互抵消。 但是,由于我们的矩阵包括透视变形(perspective deformations),这个技巧通常没有帮助。
* 在当前的代码中,我们没有使用法向量的变换,但在下一课中它将非常非常有用。