## Copy
 Rust 有一个叫做 Copy 的特征，可以用在类似**整型**这样**在栈中存储**的类型。如果**一个类型拥有 Copy 特征**，一个**旧的变量在被赋值给其他变量后仍然可用**。

那么什么类型是可 Copy 的呢？可以查看给定类型的文档来确认，不过作为一个通用的规则： **任何基本类型的组合可以 Copy **，不需要分配内存或某种形式资源的类型是可以 Copy 的。如下是一些 Copy 的类型：

所有**整数类型**，比如 u32
**布尔类型**，bool，它的值是 true 和 false
所有**浮点数类型**，比如 f64
**字符类型**，char
**元组**，**当且仅当其包含的类型也都是 Copy 的时候**。比如，(i32, i32) 是 Copy 的，但 (i32, String) 就不是
**不可变引用 &T** ，例如转移所有权中的最后一个例子，但是注意: 可变引用 **&mut T** 是不可以 Copy的

``` rust
fn main() {
    let x: &str = "hello, world";
    let y = x;
    println!("{},{}",x,y);
}
```
这段代码，大家觉得会否报错？如果参考之前的 String 所有权转移的例子，那这段代码也应该报错才是，但是实际上呢？

这段代码和之前的 String 有一个本质上的区别：在 String 的例子中 s1 持有了通过String::from("hello") 创建的值的所有权，而这个例子中，x 只是引用了存储在二进制中的字符串 "hello, world"，并没有持有所有权。

因此 let y = x 中，仅仅是对该引用进行了**拷贝**，此时 **y 和 x 都引用了同一个字符串**。如果还不理解也没关系，当学习了下一章节 "引用与借用" 后，大家自然而言就会理解。

## 创建数组
``` rust
fn main() {
    let a = [1, 2, 3, 4, 5];
}
```

由于它的**元素类型大小固定**，且**长度也是固定**，因此数组 array 是**存储在栈上**，性能也会非常优秀。与此对应，动态数组 Vector 是存储在堆上，因此长度可以动态改变。当你不确定是使用数组还是动态数组时，那就应该使用后者，具体见动态数组 Vector。

## 奇怪的&结构体定义
``` rust
use std::thread;
use std::sync::Arc;
use std::sync::Mutex;
#[derive(Debug)]
struct MyBox(*const u8);
unsafe impl Send for MyBox {}
unsafe impl Sync for MyBox {}

fn main() {
    let b = &MyBox(5 as *const u8);
    // let b = MyBox(5 as *const u8);
    let v = Arc::new(Mutex::new(b));
    // let v = Arc::new(Mutex::new(&b));
    let t = thread::spawn(move || {
        let _v1 =  v.lock().unwrap();
    });
    t.join().unwrap();
}
```
* 其中&MyBox拥有了’static的lifetime,目前还不知道为什么，使用注释里的会报错，因为b的lifetime不够长

## 