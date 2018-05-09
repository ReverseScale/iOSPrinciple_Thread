# iOSPrinciple_Thread
Principle Thread

### 一.相关概念

#### 1.1 进程

进程是指在系统中正在运行的一个应用程序。每个进程之间是独立的，每个进程均运行在其专用且受保护的内存空间内。

#### 1.2 线程

*线程和进程的关系*

1个进程要想执行任务，必须得有线程（每1个进程至少要有1条线程），线程是进程的基本执行单元，一个进程（程序）的所有任务都在线程中执行。

*线程内部是串行执行的*

1个线程中任务的执行是串行的，如果要在1个线程中执行多个任务，那么只能一个一个地按顺序执行这些任务。也就是说，在同一时间内，1个线程只能执行1个任务。

#### 1.3 多线程

即1个进程中可以开启多条线程，每条线程可以并行（同时）执行不同的任务。比如同时开启3条线程分别下载3个文件（分别是文件A、文件B、文件C）。

*多线程并发执行的原理*

在同一时间里，CPU只能处理1条线程，只有1条线程在工作（执行）。多线程并发（同时）执行，其实是CPU快速地在多条线程之间调度（切换），如果CPU调度线程的时间足够快，就造成了多线程并发执行的假象。

*多线程的优缺点*

优点：
* 1）能适当提高程序的执行效率。
* 2）能适当提高资源利用率（CPU、内存利用率）

缺点：
* 1）开启线程需要占用一定的内存空间（默认情况下，主线程占用1M，子线程占用512KB），如果开启大量的线程，会占用大量的内存空间，降低程序的性能。
* 2）线程越多，CPU在调度线程上的开销就越大。
* 3）程序设计更加复杂：比如线程之间的通信、多线程的数据共享

#### 1.4 多线程在 iOS 开发中的应用

*iOS 的主线程*

一个 iOS 程序运行后，默认会开启1条线程，称为“主线程”或“UI线程”，用于刷新显示UI,处理UI事件。
 
 > 不要将耗时操作放到主线程中去处理，会卡住线程。

*iOS 的多线程*

1）第一种：pthread

特点：
* 一套通用的多线程API
* 适用于Unix\Linux\Windows等系统
* 跨平台\可移植
* 使用难度大

使用语言：c语言

使用频率：几乎不用

线程生命周期：由程序员进行管理



2）第二种：NSThread

特点：
* 使用更加面向对象
* 简单易用，可直接操作线程对象

使用语言：OC语言

使用频率：偶尔使用

线程生命周期：由程序员进行管理



3）第三种：GCD

特点：
* 旨在替代NSThread等线程技术
* 充分利用设备的多核(自动)

使用语言：OC语言

使用频率：经常使用

线程生命周期：自动管理



4）第四种：NSOperation

特点：
* 基于GCD（底层是GCD）
* 比GCD多了一些更简单实用的功能
* 使用更加面向对象

> - 在NSOperationQueue中，可以建立各个NSOperation之间的依赖关系
- 有KVO，可以监测operation是否正在执行（isExecuted）、是否结束（isFinished），是否取消（isCanceld）
- NSOperationQueue可以方便的管理并发、NSOperation之间的优先级

使用语言：OC语言

使用频率：经常使用

线程生命周期：自动管理


### 二.代码示例

由于要使用一些 c 来演示，先说明些规范，防懵逼 😳
* 1.在c语言中，没有对象的概念，对象类型是以-t/Ref结尾的;
* 2.c语言中的void * 和OC的id是等价的;
* 3.在混合开发时，如果在 C 和 OC 之间传递数据，需要使用 __bridge 进行桥接，桥接的目的就是为了告诉编译器如何管理内存，MRC 中不需要使用桥接;
* 4.在 OC 中，如果是 ARC 开发，编译器会在编译时，根据代码结构， 自动添加 retain/release/autorelease。但是，ARC 只负责管理 OC 部分的内存管理，而不负责 C 语言 代码的内存管理。因此，开发过程中，如果使用的 C 语言框架出现retain/create/copy/new 等字样的函数，大多都需要 release，否则会出现内存泄漏。

#### 2.1 pthread 基本使用

需要引入 pthread 头文件
```objc
#import <pthread.h>
```
使用 pthread_create 方法
```objc
/**
pthread_create(<#pthread_t  _Nullable *restrict _Nonnull#>, <#const pthread_attr_t *restrict _Nullable#>, <#void * _Nullable (* _Nonnull)(void * _Nullable)#>, <#void *restrict _Nullable#>)
参数：
1.指向线程标识符的指针，C 语言中类型的结尾通常 _t/Ref，而且不需要使用 *;
2.用来设置线程属性;
3.指向函数的指针,传入函数名(函数的地址)，线程要执行的函数/任务;
4.运行函数的参数;
*/
```
完整代码
```objc
{
    //1.创建线程对象
    pthread_t thread;

    //2.创建线程
    NSString *param = @"参数";
    int result = pthread_create(&thread, NULL, task, (__bridge void *)(param));
    result == 0?NSLog(@"success"):NSLog(@"failure");

    //3.设置子线程的状态设置为detached,则该线程运行结束后会自动释放所有资源，或者在子线程中添加 pthread_detach(pthread_self()),其中pthread_self()是获得线程自身的id
    pthread_detach(thread);
}
void *task(void * param) {
    //在此做耗时操作
    NSLog(@"new thread : %@  参数是: %@",[NSThread currentThread],(__bridge NSString *)(param));
    return NULL;
}
```

#### 2.2 NSThread 基本使用

1.1）第一种 创建线程的方式：alloc init.

特点：需要手动开启线程，可以拿到线程对象进行详细设置

* 第一个参数：目标对象
* 第二个参数：选择器，线程启动要调用哪个方法
* 第三个参数：前面方法要接收的参数（最多只能接收一个参数，没有则传nil）

```objc
NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(run) object:@"wendingding"];
//启动线程
[thread start];
```

1.2）第二种 创建线程的方式：分离出一条子线程

特点：自动启动线程，无法对线程进行更详细的设置

* 第一个参数：线程启动调用的方法
* 第二个参数：目标对象
* 第三个参数：传递给调用方法的参数

```objc
[NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:@"我是分离出来的子线程"];
```

1.3）第三种 创建线程的方式：后台线程

特点：自动启动县城，无法进行更详细设置

```objc
[self performSelectorInBackground:@selector(run) withObject:@"我是后台线程"];
```

2）常用的控制线程方法

为线程命名，以便区分
```objc
//设置线程的名称
thread.name = @"线程A";
```

设置优先级，取值范围为0.0~1.0之间，1.0表示线程的优先级最高,如果不设置该值，那么理想状态下默认为0.5
```objc
//设置线程的优先级
thread.threadPriority = 1.0;
```

退出当前线程
```objc
//退出当前线程
[NSThread exit];
```

线程的各种状态：新建-就绪-运行-阻塞-死亡，阻塞线程方法来了
```objc
[NSThread sleepForTimeInterval:2.0]; //阻塞线程
[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]]; //阻塞线程
//注意：线程死了不能复生
```

3）线程安全
* 前提：多个线程访问同一块资源会发生数据安全问题
* 解决方案：加互斥锁
* 相关代码：@synchronized(self){}
* 专业术语-线程同步
* 原子和非原子属性（是否对setter方法加锁）

死锁：是指两个或两个以上的进程在执行过程中，因争夺资源而造成的一种互相等待的现象，若无外力作用，它们都将无法推进下去。

产生死锁的四个必要条件：
* 互斥条件：一个资源每次只能被一个进程使用。
* 占有且等待：一个进程因请求资源而阻塞时，对已获得的资源保持不放。
* 不可强行占有:进程已获得的资源，在末使用完之前，不能强行剥夺。
* 循环等待条件:若干进程之间形成一种头尾相接的循环等待资源关系。

产生死锁的原因主要是：
* 因为系统资源不足。
* 进程运行推进的顺序不合适。
* 资源分配不当等。

售票员售票问题
```objc
@interface NSThreadSafeViewController ()
//三只售票员🐱🐶🐭
@property (nonatomic, strong) NSThread *thread01;
@property (nonatomic, strong) NSThread *thread02;
@property (nonatomic, strong) NSThread *thread03;
//总票数
@property(nonatomic, assign) NSInteger totalticket;
@end

@implementation NSThreadSafeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //假设有10张票
    self.totalticket = 10;

    //创建线程
    self.thread01 =  [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
    self.thread01.name = @"小🐱";

    self.thread02 =  [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
    self.thread02.name = @"小🐶";

    self.thread03 =  [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
    self.thread03.name = @"小🐭";
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //启动线程
    [self.thread01 start];
    [self.thread02 start];
    [self.thread03 start];
}
//售票
- (void)saleTicket {
    while (1) {
        //2.加互斥锁
        @synchronized(self) {
            [NSThread sleepForTimeInterval:0.03];
            //1.先查看余票数量
            NSInteger count = self.totalticket;
            if (count > 0) {
                self.totalticket = count - 1;
                NSLog(@"%@卖出去了一张票,还剩下%zd张票",[NSThread currentThread].name,self.totalticket);
            } else {
                NSLog(@"%@发现当前票已经买完了--",[NSThread currentThread].name);
                break;
            }
        }
    }
}
```

运行结果：

![](http://og1yl0w9z.bkt.clouddn.com/18-5-9/56476833.jpg)

4）NSThread 线程间通信（子线程加载图片完成通知主线程更新UI）
```objc
- (void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    //开启一条子线程来下载图片
    [NSThread detachNewThreadSelector:@selector(downloadImage) toTarget:self withObject:nil];
}
- (void)downloadImage {
    //1.确定要下载网络图片的url地址，一个url唯一对应着网络上的一个资源
    NSURL *url = [NSURL URLWithString:@"http://p6.qhimg.com/t01d2954e2799c461ab.jpg"];

    //2.根据url地址下载图片数据到本地（二进制数据
    NSData *data = [NSData dataWithContentsOfURL:url];

    //3.把下载到本地的二进制数据转换成图片
    UIImage *image = [UIImage imageWithData:data];

    //4.回到主线程刷新UI
    //4.1 第一种方式
    //    [self performSelectorOnMainThread:@selector(showImage:) withObject:image waitUntilDone:YES];

    //4.2 第二种方式
    //    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];

    //4.3 第三种方式
    [self.imageView performSelector:@selector(setImage:) onThread:[NSThread mainThread] withObject:image waitUntilDone:YES];
}
```

5）特殊用法（计算代码段的执行时间）
```objc
NSURL *url = [NSURL URLWithString:@"http://p6.qhimg.com/t01d2954e2799c461ab.jpg"];

//第一种方法
NSDate *start = [NSDate date];
//2.根据url地址下载图片数据到本地（二进制数据）
NSData *data = [NSData dataWithContentsOfURL:url];

NSDate *end = [NSDate date];
NSLog(@"第二步操作花费的时间为%f",[end timeIntervalSinceDate:start]);


//第二种方法
CFTimeInterval start = CFAbsoluteTimeGetCurrent();
NSData *data = [NSData dataWithContentsOfURL:url];

CFTimeInterval end = CFAbsoluteTimeGetCurrent();
NSLog(@"第二步操作花费的时间为%f",end - start);
```

#### 2.3 GCD 基本使用

1）GCD 核心概念
* 队列和任务
* 同步函数和异步函数

2）GCD 组合拳 🤣

异步函数：
* 异步函数+并发队列：开启多条线程，并发执行任务
* 异步函数+串行队列：开启一条线程，串行执行任务

同步函数：
* 同步函数+并发队列：不开线程，串行执行任务
* 同步函数+串行队列：不开线程，串行执行任务

主队列：
* 异步函数+主队列：不开线程，在主线程中串行执行任务
* 同步函数+主队列：不开线程，串行执行任务（注意死锁发生）

3）GCD 线程间通信
```objc
//0.获取一个全局的队列
dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//1.先开启一个线程，把下载图片的操作放在子线程中处理
dispatch_async(queue, ^{
    //2.下载图片
    NSURL *url = [NSURL URLWithString:@"http://h.hiphotos.baidu.com/zhidao/pic/item/6a63f6246b600c3320b14bb3184c510fd8f9a185.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];

    NSLog(@"下载操作所在的线程--%@",[NSThread currentThread]);

    //3.回到主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
        //打印查看当前线程
        NSLog(@"刷新UI---%@",[NSThread currentThread]);
    });
});
```

4）GCD 常用小功能

栅栏函数（控制任务的执行顺序）
```objc
dispatch_barrier_async(queue, ^{
    NSLog(@"--dispatch_barrier_async-");
});
```

延迟执行（延迟·控制在哪个线程执行）
```objc
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_  queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"---%@",[NSThread currentThread]);
});
```

一次性代码（注意不能放到懒加载）
```objc
- (void)once {
    //整个程序运行过程中只会执行一次
    //onceToken用来记录该部分的代码是否被执行过
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"-----");
    });
}
```

快速迭代（开多个线程并发完成迭代操作）
```objc
dispatch_apply(subpaths.count, queue, ^(size_t index) {
});
```

队列组（同栅栏函数）
```objc
//创建队列组
dispatch_group_t group = dispatch_group_create();
dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);

dispatch_group_enter(group);
//模拟多线程耗时操作
dispatch_group_async(group, globalQueue, ^{
    sleep(3);
    NSLog(@"%@---block1结束。。。",[NSThread currentThread]);
    dispatch_group_leave(group);
});
NSLog(@"%@---1结束。。。",[NSThread currentThread]);

dispatch_group_enter(group);
//模拟多线程耗时操作
dispatch_group_async(group, globalQueue, ^{
    sleep(3);
    NSLog(@"%@---block2结束。。。",[NSThread currentThread]);
    dispatch_group_leave(group);
});
NSLog(@"%@---2结束。。。",[NSThread currentThread]);

dispatch_group_notify(group, globalQueue, ^{
    NSLog(@"%@---全部结束。。。",[NSThread currentThread]);
});
```

















