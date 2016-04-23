//
//  ViewController.m
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/21.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import "ViewController.h"
#import "LXDTextView.h"

@interface ViewController ()<LXDTextViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LXDTextView * textView = [[LXDTextView alloc] initWithFrame: CGRectMake(0, 0, 200, 300)];
    textView.delegate = self;
    [self.view addSubview: textView];
    textView.emojiUserInteractionEnabled = YES;
    textView.center = self.view.center;
    textView.emojiTextMapper = @{
                                 @"[emoji]": @"emoji"
                                 };
    textView.hyperlinkMapper = @{
                                 @"@百度": @"https://www.baidu.com",
                                 @"@腾讯": @"https://www.qq.com",
                                 @"@谷歌": @"https://www.google.com",
                                 @"@脸书": @"https://www.facebook.com",
                                 };
    textView.text = @"很久很久以前[emoji]，在一个群里，生活着@百度、@腾讯这样的居民，后来，一个[emoji]叫做@谷歌的人入侵了这个村庄，他的同伙@脸书让整个群里变得淫荡无比。从此[emoji]，迎来了污妖王的时代。污妖王，我当定了！[emoji]";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)textView: (LXDTextView *)textView didSelectedHyperlink: (NSString *)hyperlink
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle: nil message: hyperlink preferredStyle: UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle: @"yes" style: UIAlertActionStyleCancel handler: nil]];
    [self presentViewController: alert animated: YES completion: nil];
}

- (void)textView: (LXDTextView *)textView didSelectedEmoji: (NSString *)emojiName
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle: nil message: emojiName preferredStyle: UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle: @"yes" style: UIAlertActionStyleCancel handler: nil]];
    [self presentViewController: alert animated: YES completion: nil];
}

@end
