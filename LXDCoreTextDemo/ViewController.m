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
    
    LXDTextView * textView = [[LXDTextView alloc] initWithFrame: CGRectMake(0, 0, 200, 200)];
    [self.view addSubview: textView];
    textView.center = self.view.center;
    textView.emojiTextMapper = @{
                                 @"[emoji]": @"me_kuaidixiangqing_phone_icon"
                                 };
    textView.hyperlinkMapper = @{
                                 @"牛人来了": @"niurenlaile",
                                 @"我是牛人爸爸": @"woshiniurenbaba",
                                 @"阿里": @"ali",
                                 @"葡萄": @"putao",
                                 };
    textView.text = @"很久很久以前，在一个群里，生活着牛人来了、我是牛人爸爸这样的居民，后来，一个叫做阿里的人入侵了这个村庄，他的同伙葡萄让整个群里变得淫荡无比。从此，迎来了污妖王的时代。污妖王，我当定了！[emoji]";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
