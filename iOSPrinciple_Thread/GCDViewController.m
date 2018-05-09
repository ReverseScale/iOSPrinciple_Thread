//
//  GCDViewController.m
//  iOSPrinciple_Thread
//
//  Created by WhatsXie on 2018/5/9.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self loadImage];
}
- (IBAction)landAction:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);

    dispatch_barrier_async(queue, ^{
        NSLog(@"---dispatch_barrier_async-");
    });
}
- (IBAction)laterAction:(id)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"---%@",[NSThread currentThread]);
    });
}
- (IBAction)onceAction:(id)sender {
    //整个程序运行过程中只会执行一次
    //onceToken用来记录该部分的代码是否被执行过
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"-----");
    });
}
- (IBAction)fastloadAction:(id)sender {
    NSArray *subpaths = @[];
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_apply(subpaths.count, queue, ^(size_t index) {
    });
}
- (IBAction)linelandAction:(id)sender {
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
}

- (void)loadImage {
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
