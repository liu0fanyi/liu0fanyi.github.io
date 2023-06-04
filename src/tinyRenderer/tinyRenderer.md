## 这里跟101作业联动
### 最简单的画线实现
![first_attempt](image/first_attempt.png)
* 简单步进
``` rust
void line(int x0, int y0, int x1, int y1, TGAImage &image, TGAColor color) { 
    for (float t=0.; t<1.; t+=.01) { 
        int x = x0 + (x1-x0)*t; 
        int y = y0 + (y1-y0)*t; 
        image.set(x, y, color); 
    } 
}
```
### second
* 上面的问题：低效，如果