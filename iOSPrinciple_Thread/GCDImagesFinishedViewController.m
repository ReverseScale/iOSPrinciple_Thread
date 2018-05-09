//
//  GCDImagesFinishedViewController.m
//  iOSPrinciple_Thread
//
//  Created by WhatsXie on 2018/5/9.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import "GCDImagesFinishedViewController.h"

@interface GCDImagesFinishedViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage  *image1; /**< 图片1 */
@property (nonatomic, strong) UIImage  *image2; /**< 图片2 */  
@end

@implementation GCDImagesFinishedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self groupABCD];
    
    [self group];
}

- (void)groupABCD {
    /**
     有a、b、c、d 4个异步请求，如何判断a、b、c、d都完成执行？如果需要a、b、c、d顺序执行，该如何实现？
     对于这四个异步请求，要判断都执行完成最简单的方式就是通过GCD的group来实现：
     
     当然，我们还可以使用非常老套的方法来处理，通过四个变量来标识a、b、c、d四个任务是否完成，然后在runloop中让其等待，当完成时才退出runloop。但是这样做会让后面的代码得不到执行，直到Run loop执行完毕。
     解释：要求顺序执行，那么可以将任务放到串行队列中，自然就是按顺序来异步执行了。
     
     */
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{ /*任务a */ NSLog(@"执行a");
    });
    dispatch_group_async(group, queue, ^{ /*任务b */ NSLog(@"执行b");
    });
    dispatch_group_async(group, queue, ^{ /*任务c */ NSLog(@"执行c");
    });
    dispatch_group_async(group, queue, ^{ /*任务d */ NSLog(@"执行d");
    });
    dispatch_group_notify(group,dispatch_get_main_queue(), ^{
        // 在a、b、c、d异步执行完成后，会回调这里
        NSLog(@"执行完成");
    });
}

- (void)group {
    //下载图片1
    
    //创建队列组
    dispatch_group_t group =  dispatch_group_create();
    
    //1.开子线程下载图片
    //创建队列(并发)
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_async(group, queue, ^{
        //1.获取url地址
        NSURL *url = [NSURL URLWithString:@"http://www.huabian.com/uploadfile/2015/0914/20150914014032274.jpg"];
        
        //2.下载图片
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        //3.把二进制数据转换成图片
        self.image1 = [UIImage imageWithData:data];
        
        NSLog(@"1---%@",self.image1);
    });
    
    //下载图片2
    dispatch_group_async(group, queue, ^{
        //1.获取url地址
        NSURL *url = [NSURL URLWithString:@"http://img1.3lian.com/img2011/w12/1202/19/d/88.jpg"];
        
        //2.下载图片
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        //3.把二进制数据转换成图片
        self.image2 = [UIImage imageWithData:data];
        NSLog(@"2---%@",self.image2);
        
    });
    
    //合成
    dispatch_group_notify(group, queue, ^{
        
        //开启图形上下文
        UIGraphicsBeginImageContext(CGSizeMake(200, 200));
        
        //画1
        [self.image1 drawInRect:CGRectMake(0, 0, 200, 100)];
        
        //画2
        [self.image2 drawInRect:CGRectMake(0, 100, 200, 100)];
        
        //根据图形上下文拿到图片
        UIImage *image =  UIGraphicsGetImageFromCurrentImageContext();
        
        //关闭上下文
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            NSLog(@"%@--刷新UI",[NSThread currentThread]);
        });
    });
}
- (void)applay {
    //    for (NSInteger i=0; i<10; i++) {
    //        NSLog(@"%zd--%@",i,[NSThread currentThread]);
    //    }
    
    //创建队列(并发队列)
    dispatch_queue_t queue = dispatch_queue_create("com.downloadqueue", DISPATCH_QUEUE_CONCURRENT);
    /*
     第一个参数:迭代的次数
     第二个参数:在哪个队列中执行
     第三个参数:block要执行的任务
     */
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%zd--%@",index,[NSThread currentThread]);
    });
}

- (void)moveFile {
    //文件在哪个地方(文件夹)
    NSString *form = @"/Users/xxx/Desktop/form";
    //要剪切到什么地方
    NSString *to = @"/Users/xxx/Desktop/to";
    
    NSFileManager *manager = [NSFileManager defaultManager];
    //    NSArray *subpaths =  [manager subpathsAtPath:form];
    //    NSDirectoryEnumerator *enumer = [manager enumeratorAtPath:to];
    NSDirectoryEnumerator *enumer = [manager directoryContentsAtPath:form];
    
    //    for (NSDirectoryEnumerator *en in enumer) {
    //        NSLog(@"%@",en);
    //    }
    //
    //    //创建队列(并发队列)
    //    dispatch_queue_t queue = dispatch_queue_create("com.downloadqueue", DISPATCH_QUEUE_CONCURRENT);
    //
    //    NSInteger count = [subpaths count];
    //    dispatch_apply(count, queue, ^(size_t index) {
    //
    //        NSString *subpath = subpaths[index];
    //
    //        NSString *fullPath = [form stringByAppendingPathComponent:subpath];
    //
    //        //拼接目标文件全路径
    //        NSString *fileName = [to stringByAppendingPathComponent:subpath];
    //
    //        //剪切操作
    //        [manager moveItemAtPath:fullPath toPath:fileName error:nil];
    //
    //        NSLog(@"%@",[NSThread currentThread]);
    //    });
}

- (void)moveFiles {
    //文件在哪个地方(文件夹)
    NSString *form = @"/Users/xxx/Desktop/form";
    //要剪切到什么地方
    NSString *to = @"/Users/xxx/Desktop/to";
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *subpaths =  [manager subpathsAtPath:form];
    //    NSLog(@"%@",subpaths);
    
    NSInteger count = [subpaths count];
    
    for (NSInteger i = 0; i<count; i++) {
        //拼接文件全路径
        //        NSString *fullPath = [form stringByAppendingString:<#(nonnull NSString *)#>]
        
        NSString *subpath = subpaths[i];
        
        NSString *fullPath = [form stringByAppendingPathComponent:subpath];
        
        //拼接目标文件全路径
        NSString *fileName = [to stringByAppendingPathComponent:subpath];
        
        //剪切操作
        [manager moveItemAtPath:fullPath toPath:fileName error:nil];
        
        NSLog(@"%@--%@",fullPath,fileName);
    }
    
}
- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"+++++++++");
    });
}

- (void)delay {
    NSLog(@"----");
    //表名2秒钟之后调用run
    //    [self performSelector:@selector(run) withObject:nil afterDelay:2.0];
    
    //    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];
    
    /*
     第一个参数:延迟时间
     第二个参数:要执行的代码
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        NSLog(@"---%@",[NSThread currentThread]);
    });
    
}

- (void)run {
    NSLog(@"++++");
}
- (void)barrier {
    //1.创建队列(并发队列)
    dispatch_queue_t queue = dispatch_queue_create("com.downloadqueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"%zd-download1--%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"%zd-download2--%@",i,[NSThread currentThread]);
        }
    });
    
    //栅栏函数
    dispatch_barrier_async(queue, ^{
        NSLog(@"我是一个栅栏函数");
    });
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"%zd-download3--%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"%zd-download4--%@",i,[NSThread currentThread]);
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

