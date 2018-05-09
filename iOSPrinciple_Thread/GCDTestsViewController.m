//
//  GCDTestsViewController.m
//  iOSPrinciple_Thread
//
//  Created by WhatsXie on 2018/5/9.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import "GCDTestsViewController.h"

@interface GCDTestsViewController ()

@end

@implementation GCDTestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    [self syncMain];
//    [self asyncMain];
//    [self syncSerial];
//    [self syncConcurrent];
//    [self asyncSerial];
    [self asyncCONCURRENT];

}

//同步函数+主队列:死锁
- (void)syncMain {
    NSLog(@"----");
    //1.获得主队列
    dispatch_queue_t queue =  dispatch_get_main_queue();
    
    //2.同步函数
    dispatch_sync(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
    
}


//异步函数+主队列:不会开线程,任务串行执行
- (void)asyncMain {
    //1.获得主队列
    dispatch_queue_t queue =  dispatch_get_main_queue();
    
    //2.异步函数
    dispatch_async(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
    
}

//同步函数+串行队列:不会开线程,任务串行执行
- (void)syncSerial {
    
    //创建串行队列
    /*
     第一个参数:C语言字符串,标签
     第二个参数:
     DISPATCH_QUEUE_CONCURRENT:并发队列
     DISPATCH_QUEUE_SERIAL:串行队列
     */
    dispatch_queue_t queue =  dispatch_queue_create("hello apple", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
}
//同步函数+并发队列:不会开线程,任务串行执行
- (void)syncConcurrent {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    NSLog(@"--syncConcurrent--start-");
    
    dispatch_sync(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
    
    NSLog(@"--syncConcurrent--end-");
}
//异步函数+串行队列:会开启一条线程,任务串行执行
- (void)asyncSerial {
    //创建串行队列
    /*
     第一个参数:C语言字符串,标签
     第二个参数:
     DISPATCH_QUEUE_CONCURRENT:并发队列
     DISPATCH_QUEUE_SERIAL:串行队列
     */
    dispatch_queue_t queue =  dispatch_queue_create("hello apple", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
}
//异步函数+并发队列:会开启新的线程,并发执行
- (void)asyncCONCURRENT {
    //创建并发队列
    /*
     第一个参数:C语言字符串,标签
     第二个参数:
     DISPATCH_QUEUE_CONCURRENT:并发队列
     DISPATCH_QUEUE_SERIAL:串行队列
     */
    //    dispatch_queue_t queue =  dispatch_queue_create("com.520it.download", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"--asyncCONCURRENT--start-");
    //获得全局并发队列
    /*
     第一个参数:队列的优先级DISPATCH_QUEUE_PRIORITY_DEFAULT
     第二个参数:永远传0
     */
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //异步函数
    /*
     第一个参数:队列
     第二个参数:block,在里面封装任务
     */
    dispatch_async(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
    
    NSLog(@"--asyncCONCURRENT--end-");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
