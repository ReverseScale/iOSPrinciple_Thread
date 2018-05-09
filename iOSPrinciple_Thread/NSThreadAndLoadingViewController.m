//
//  NSThreadAndLoadingViewController.m
//  iOSPrinciple_Thread
//
//  Created by WhatsXie on 2018/5/9.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import "NSThreadAndLoadingViewController.h"

@interface NSThreadAndLoadingViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NSThreadAndLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
//    [self createNSThread];
    
    [self runUsedtime];
}

- (void)createNSThread {
    //第一种创建线程的方式：alloc init.
    //特点：需要手动开启线程，可以拿到线程对象进行详细设置
    //创建线程
    /*
     第一个参数：目标对象
     第二个参数：选择器，线程启动要调用哪个方法
     第三个参数：前面方法要接收的参数（最多只能接收一个参数，没有则传nil）
     */
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(run) object:@"wendingding"];
    
    //设置线程的名称
    thread.name = @"线程A";
    
    //设置线程的优先级,注意线程优先级的取值范围为0.0~1.0之间，1.0表示线程的优先级最高,如果不设置该值，那么理想状态下默认为0.5
    thread.threadPriority = 1.0;
    
    //启动线程
    [thread start];
    
    
    [NSThread exit];//退出当前线程
    
    //线程的各种状态：新建-就绪-运行-阻塞-死亡
    //常用的控制线程状态的方法
    [NSThread sleepForTimeInterval:2.0];//阻塞线程
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];//阻塞线程
    //注意：线程死了不能复生
}

- (void)createThreadOther {
    //第二种创建线程的方式：分离出一条子线程
    //特点：自动启动线程，无法对线程进行更详细的设置
    /*
     第一个参数：线程启动调用的方法
     第二个参数：目标对象
     第三个参数：传递给调用方法的参数
     */
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:@"我是分离出来的子线程"];
    
    //第三种创建线程的方式：后台线程
    //特点：自动启动县城，无法进行更详细设置
    [self performSelectorInBackground:@selector(run) withObject:@"我是后台线程"];
}

- (void)run {
    NSLog(@"running NSthread");
}

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

- (void)runUsedtime {
    NSURL *url = [NSURL URLWithString:@"http://p6.qhimg.com/t01d2954e2799c461ab.jpg"];
    
//    //第一种方法
//    NSDate *start = [NSDate date];
//    //2.根据url地址下载图片数据到本地（二进制数据）
//    NSData *data = [NSData dataWithContentsOfURL:url];
//
//    NSDate *end = [NSDate date];
//    NSLog(@"第二步操作花费的时间为%f",[end timeIntervalSinceDate:start]);
    
    //第二种方法
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    NSData *data = [NSData dataWithContentsOfURL:url];

    CFTimeInterval end = CFAbsoluteTimeGetCurrent();
    NSLog(@"第二步操作花费的时间为%f",end - start);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
