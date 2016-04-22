//
//  LXDTextView.m
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/22.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import "LXDTextView.h"
#import <CoreText/CoreText.h>
#import "NSString+LXDMarkdownExtension.h"


@interface LXDTextView ()

@property (nonatomic, strong) NSMutableDictionary * textTouchMapper;
@property (nonatomic, strong) NSMutableDictionary * emojiTouchMapper;

@end


@implementation LXDTextView
{
    CTFrameRef _frame;
}


#pragma mark - CTRunDelegateCallbacks
void RunDelegateDeallocCallback(void * refCon)
{
}

CGFloat RunDelegateGetAscentCallback(void * refCon)
{
    return 20;
}

CGFloat RunDelegateGetDescentCallback(void * refCon)
{
    return 0;
}

CGFloat RunDelegateGetWidthCallback(void * refCon)
{
    return 20;
}


- (void)setText: (NSString *)text
{
    _text = text.copy;
    [self setNeedsDisplay];
}

- (void)dealloc
{
    CFRelease(_frame);
}

- (NSMutableDictionary *)textTouchMapper
{
    return _textTouchMapper ?: (_textTouchMapper = @{}.mutableCopy);
}

- (NSMutableDictionary *)emojiTouchMapper
{
    return _emojiTouchMapper ?: (_emojiTouchMapper = @{}.mutableCopy);
}


#pragma mark - 绘制文本
- (void)drawRect: (CGRect)rect
{
    NSString * const imageKey = @"imageName";
    NSString * clickText = @"@骑着jm的hi";
    
    NSMutableAttributedString * content = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat: @"%@: this is a core text demo", clickText]];
    NSRange clickRange = [content.string rangeOfString: clickText];
    [self.textTouchMapper setValue: clickText forKey: NSStringFromRange(clickRange)];
    if (clickRange.location != NSNotFound) {
        [content addAttributes: @{ NSForegroundColorAttributeName: [UIColor blueColor] } range: clickRange];
    }
    
    NSString * imageName = @"me_kuaidixiangqing_phone_icon";
    
    /*!
     *  @brief 创建CTRunDelegate
     */
    CTRunDelegateCallbacks imageCallbacks;
    imageCallbacks.version = kCTRunDelegateVersion1;
    imageCallbacks.dealloc = RunDelegateDeallocCallback;
    imageCallbacks.getWidth = RunDelegateGetWidthCallback;
    imageCallbacks.getAscent = RunDelegateGetAscentCallback;
    imageCallbacks.getDescent = RunDelegateGetDescentCallback;
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge void *)imageName);
    
    NSMutableAttributedString * imageAttributedString = [[NSMutableAttributedString alloc] initWithString: @" "];
    [imageAttributedString addAttribute: (NSString *)kCTRunDelegateAttributeName value: (__bridge id)runDelegate range: NSMakeRange(0, 1)];
    CFRelease(runDelegate);
    [imageAttributedString addAttribute: imageKey value: imageName range: NSMakeRange(0, 1)];
    [content insertAttributedString: imageAttributedString atIndex: 15];
//    [content appendAttributedString: imageAttributedString];
    
    
    /*!
     *  @brief 设置字体属性
     */
    CTParagraphStyleSetting styleSetting;
    CTLineBreakMode lineBreak = kCTLineBreakByWordWrapping;
    styleSetting.spec = kCTParagraphStyleSpecifierLineBreakMode;
    styleSetting.value = &lineBreak;
    styleSetting.valueSize = sizeof(CTLineBreakMode);
    CTParagraphStyleSetting settings[] = { styleSetting };
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
    NSMutableDictionary * attributes = @{
                                         (id)kCTParagraphStyleAttributeName: (id)style
                                         }.mutableCopy;
    [content addAttributes: attributes range: NSMakeRange(0, content.length)];
    CTFontRef font = CTFontCreateWithName((CFStringRef)[UIFont systemFontOfSize: 16].fontName, 16, NULL);
    [content addAttributes: @{ (id)kCTFontAttributeName: (__bridge id)font } range: NSMakeRange(0, content.length)];
    
    /*!
     *  @brief 翻转坐标系
     */
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextConcatCTM(ctx, CGAffineTransformMake(1, 0, 0, -1, 0, self.bounds.size.height));
    
    /*!
     *  @brief 设置CTFrameSetter
     */
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    CGMutablePathRef paths = CGPathCreateMutable();
    CGPathAddRect(paths, NULL, self.bounds);
    _frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, content.length), paths, NULL);
    CTFrameDraw(_frame, ctx);        //绘制文字
    
    /*!
     *  @brief 获取所有行的坐标
     */
    CFArrayRef lines = CTFrameGetLines(_frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), lineOrigins);
    for (int idx = 0; idx < CFArrayGetCount(lines); idx++) {
        CGPoint origin = lineOrigins[idx];
        NSLog(@"第%d行起始坐标%@ --  坐标系倒转", idx, NSStringFromCGPoint(origin));
    }
    
    
    /*!
     *  @brief 遍历CTLine
     */
    for (int idx = 0; idx < CFArrayGetCount(lines); idx++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, idx);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        NSLog(@"上行距离%f --- 下行距离%f --- 左侧偏移%f", lineAscent, lineDescent, lineLeading);
        
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int index = 0; index < CFArrayGetCount(runs); index++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[idx];
            
            CTRunRef run = CFArrayGetValueAtIndex(runs, index);
            NSDictionary * attributes = (NSDictionary *)CTRunGetAttributes(run);
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
            runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runRect.size.width, runAscent + runDescent);
            
            /*!
             *  @brief 绘制图片
             */
            NSString * imageName = attributes[imageKey];
            if (imageName) {
                UIImage * image = [UIImage imageNamed: imageName];
                if (image) {
                    CGRect imageDrawRect;
                    CGFloat imageSize = ceil(runRect.size.height);
                    imageDrawRect.size = CGSizeMake(imageSize, imageSize);
                    imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                    imageDrawRect.origin.y = lineOrigin.y - lineDescent;
                    CGContextDrawImage(ctx, imageDrawRect, image.CGImage);
                    imageDrawRect.origin.y += lineDescent * 2;
                    [self.emojiTouchMapper setValue: imageName forKey: NSStringFromCGRect(imageDrawRect)];
                }
            }
        }
    }
    
    
    /*!
     *  @brief 释放变量
     */
    CGContextRestoreGState(ctx);
    CFRelease(font);
    CFRelease(style);
    CFRelease(paths);
    CFRelease(framesetter);
}

- (void)touchesEnded: (NSSet<UITouch *> *)touches withEvent: (UIEvent *)event
{
    CGPoint touchPoint = [touches.anyObject locationInView: self];
    
    CFArrayRef lines = CTFrameGetLines(_frame);
    CGPoint origins[CFArrayGetCount(lines)];
    
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), origins);
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    
    /*!
     *  @brief 查找点击行数
     */
    for (int idx = 0; idx < CFArrayGetCount(lines); idx++) {
        CGPoint origin = origins[idx];
        CGPathRef path = CTFrameGetPath(_frame);
        CGRect rect = CGPathGetBoundingBox(path);
        
        /*!
         *  @brief 坐标转换
         */
        CGFloat y = rect.origin.y + rect.size.height - origin.y;
        if (touchPoint.y <= y && (touchPoint.x >= origin.x && touchPoint.x <= rect.origin.x + rect.size.width)) {
            line = CFArrayGetValueAtIndex(lines, idx);
            lineOrigin = origin;
            NSLog(@"点击第%d行", idx);
            break;
        }
    }
    
    touchPoint.x -= lineOrigin.x;
    CFIndex index = CTLineGetStringIndexForPosition(line, touchPoint);
    
    BOOL textDidTouched = NO;
    for (NSString * textRange in self.textTouchMapper) {
        NSRange range = NSRangeFromString(textRange);
        if (index >= range.location && index <= range.location + range.length) {
            textDidTouched = YES;
            UIAlertController * alert = [UIAlertController alertControllerWithTitle: nil message: self.textTouchMapper[textRange] preferredStyle: UIAlertControllerStyleAlert];
            [alert addAction: [UIAlertAction actionWithTitle: @"确认" style: UIAlertActionStyleCancel handler: nil]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController: alert animated: YES completion: nil];
            break;
        }
    }
    if (textDidTouched) { return; }
    for (NSString * rectString in self.emojiTouchMapper) {
        CGRect textRect = CGRectFromString(rectString);
        if (CGRectContainsPoint(textRect, touchPoint)) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle: nil message: [NSString stringWithFormat: @"点击了emoji表情%@", self.emojiTouchMapper[rectString]] preferredStyle: UIAlertControllerStyleAlert];
            [alert addAction: [UIAlertAction actionWithTitle: @"确认" style: UIAlertActionStyleCancel handler: nil]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController: alert animated: YES completion: nil];
        }
    }
}


@end
