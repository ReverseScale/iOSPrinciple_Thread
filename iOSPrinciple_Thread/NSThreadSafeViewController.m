//
//  NSThreadSafeViewController.m
//  iOSPrinciple_Thread
//
//  Created by WhatsXie on 2018/5/9.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import "NSThreadSafeViewController.h"

@interface NSThreadSafeViewController ()
//售票员a
@property (nonatomic, strong) NSThread *thread01;
//售票员b
@property (nonatomic, strong) NSThread *thread02;
//售票员c
@property (nonatomic, strong) NSThread *thread03;

//总票数
@property(nonatomic, assign) NSInteger totalticket;
@end

@implementation NSThreadSafeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
