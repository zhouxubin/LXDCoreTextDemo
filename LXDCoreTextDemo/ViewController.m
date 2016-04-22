//
//  ViewController.m
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/21.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import "ViewController.h"
#import "LXDTextView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LXDTextView * textView = [[LXDTextView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [self.view addSubview: textView];
    textView.text = @"[这是链接](http://sindrilin.com)";
    textView.center = self.view.center;
    textView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
