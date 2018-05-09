//
//  ViewController.m
//  iOSPrinciple_Thread
//
//  Created by WhatsXie on 2018/5/9.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import "ViewController.h"
#import "PthreadViewController.h"
#import "NSThreadAndLoadingViewController.h"
#import "GCDViewController.h"
#import "GCDTestsViewController.h"
#import "GCDImagesFinishedViewController.h"
#import "NSThreadSafeViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)pthreadAction:(id)sender {
    PthreadViewController *vc = [PthreadViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)nsthreadAction:(id)sender {
    NSThreadAndLoadingViewController *vc = [NSThreadAndLoadingViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)gcdAction:(id)sender {
    GCDViewController *vc = [GCDViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)gcdtestAction:(id)sender {
    GCDTestsViewController *vc = [GCDTestsViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)gcdimagefinishedAction:(id)sender {
    GCDImagesFinishedViewController *vc = [GCDImagesFinishedViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)nsthreadTicketAction:(id)sender {
    NSThreadSafeViewController *vc = [NSThreadSafeViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
