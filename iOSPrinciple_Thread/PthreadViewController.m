//
//  PthreadViewController.m
//  iOSPrinciple_Thread
//
//  Created by WhatsXie on 2018/5/9.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import "PthreadViewController.h"
#import <pthread.h>

@interface PthreadViewController ()

@end

@implementation PthreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self createpthread];
}

- (void)createpthread {
    /**
     说明：
     1.在c语言中，没有对象的概念，对象类型是以-t/Ref结尾的;
     2.c语言中的void * 和OC的id是等价的;
     3.在混合开发时，如果在 C 和 OC 之间传递数据，需要使用 __bridge 进行桥接，桥接的目的就是为了告诉编译器如何管理内存，MRC 中不需要使用桥接;
     4.在 OC 中，如果是 ARC 开发，编译器会在编译时，根据代码结构， 自动添加 retain/release/autorelease。但是，ARC 只负责管理 OC 部分的内存管理，而不负责 C 语言 代码的内存管理。因此，开发过程中，如果使用的 C 语言框架出现retain/create/copy/new 等字样的函数，大多都需要 release，否则会出现内存泄漏
     */
    
    //1.创建线程对象
    pthread_t thread;
    
    //2.创建线程
    NSString *param = @"参数";
    int result = pthread_create(&thread, NULL, task, (__bridge void *)(param));
    result == 0?NSLog(@"success"):NSLog(@"failure");
    
    //3.设置子线程的状态设置为detached,则该线程运行结束后会自动释放所有资源，或者在子线程中添加 pthread_detach(pthread_self()),其中pthread_self()是获得线程自身的id
    pthread_detach(thread);
    
    /**
     pthread_create(<#pthread_t  _Nullable *restrict _Nonnull#>, <#const pthread_attr_t *restrict _Nullable#>, <#void * _Nullable (* _Nonnull)(void * _Nullable)#>, <#void *restrict _Nullable#>)
     参数：
     1.指向线程标识符的指针，C 语言中类型的结尾通常 _t/Ref，而且不需要使用 *;
     2.用来设置线程属性;
     3.指向函数的指针,传入函数名(函数的地址)，线程要执行的函数/任务;
     4.运行函数的参数;
     */
}

/**
 void *    (*)   (void *)
 返回值    函数名  函数参数
 */
void *task(void * param) {
    //在此做耗时操作
    NSLog(@"new thread : %@  参数是: %@",[NSThread currentThread],(__bridge NSString *)(param));
    return NULL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
