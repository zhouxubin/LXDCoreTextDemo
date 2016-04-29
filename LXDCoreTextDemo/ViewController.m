//
//  ViewController.m
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/21.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import "ViewController.h"
#import "LXDTextView.h"
#import "LXDOptimize.h"



@interface ViewController ()<LXDTextViewDelegate>

@property (nonatomic, strong) LXDTextView * textView;
@property (nonatomic, strong) NSFileManager * txtManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * filePath = [[NSBundle mainBundle] pathForResource: @"三体" ofType: @"txt"];
    NSData * data = [NSData dataWithContentsOfFile: filePath];
    NSInteger length = 900;
    NSData * subData = [data subdataWithRange: NSMakeRange(0, length)];
    NSString * text = [[NSString alloc] initWithData: subData encoding: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    while (!text) {
        length++;
        subData = [data subdataWithRange: NSMakeRange(0, length)];
        text = [[NSString alloc] initWithData: subData encoding: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    }
    NSLog(@"read text: %@ \n ----- length: %lu", text, text.length);
    
//    NSString * fileText = [[NSString alloc] initWithData: txtData encoding: encoding];
//    NSLog(@"fileText %@", fileText);
    
    LXDTextView * textView = [[LXDTextView alloc] initWithFrame: self.view.bounds];
    textView.delegate = self;
    [self.view addSubview: textView];
    textView.text = text;
    textView.center = self.view.center;
    _textView = textView;
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

- (void)textView: (LXDTextView *)textView didFinishTextRender: (NSInteger)reasonableLength
{
    
}


@end
