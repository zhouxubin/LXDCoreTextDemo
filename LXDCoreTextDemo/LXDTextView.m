//
//  LXDTextView.m
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/22.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import "LXDTextView.h"
#import <CoreText/CoreText.h>


static NSString * const LXDEmojiImageNameKey = @"LXDEmojiImageNameKey";
static NSString * const LXDObserverKey = @"superview";


@interface LXDTextView ()

/*!
 *  @brief 富文本字符串
 */
@property (nonatomic, strong) NSMutableAttributedString * content;

/*!
 *  @brief 文本点击范围的映射字典
 */
@property (nonatomic, strong) NSMutableDictionary * textTouchMapper;

/*!
 *  @brief emoji图片点击范围映射字典
 */
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


#pragma mark - 构造器
- (instancetype)init
{
    if (self = [super init]){
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame: (CGRect)frame
{
    if (self = [super initWithFrame: frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder: (NSCoder *)aDecoder
{
    if (self = [super initWithCoder: aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor yellowColor];
}

- (void)dealloc
{
    CFRelease(_frame);
}


#pragma mark - setter
- (void)setEmojiTextMapper: (NSDictionary *)emojiTextMapper
{
    _emojiTextMapper = emojiTextMapper;
    [self setNeedsDisplay];
}

- (void)setHyperlinkMapper: (NSDictionary *)hyperlinkMapper
{
    _hyperlinkMapper = hyperlinkMapper;
    [self setNeedsDisplay];
}

- (void)setText: (NSString *)text
{
    _text = text.copy;
    [self setNeedsDisplay];
}


#pragma mark - 懒加载
- (NSDictionary *)textAttributes
{
    if (!_textAttributes) {
        _textAttributes = @{
                            NSForegroundColorAttributeName: [UIColor blackColor],
                            NSFontAttributeName: [UIFont systemFontOfSize: 16]
                            };
    }
    return _textAttributes;
}

- (NSMutableDictionary *)textTouchMapper
{
    return _textTouchMapper ?: (_textTouchMapper = @{}.mutableCopy);
}

- (NSMutableDictionary *)emojiTouchMapper
{
    return _emojiTouchMapper ?: (_emojiTouchMapper = @{}.mutableCopy);
}


#pragma mark - 富文本绘制
- (void)insertEmojiAttributed: (NSString *)imageName emojiRange: (NSRange)emojiRange
{
    CTRunDelegateCallbacks imageCallbacks;
    imageCallbacks.version = kCTRunDelegateVersion1;
    imageCallbacks.dealloc = RunDelegateDeallocCallback;
    imageCallbacks.getWidth = RunDelegateGetWidthCallback;
    imageCallbacks.getAscent = RunDelegateGetAscentCallback;
    imageCallbacks.getDescent = RunDelegateGetDescentCallback;
    
    /*!
     *  @brief 插入图片属性文本
     */
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge void *)imageName);
    NSMutableAttributedString * imageAttributedString = [[NSMutableAttributedString alloc] initWithString: @" "];
    [imageAttributedString addAttribute: (NSString *)kCTRunDelegateAttributeName value: (__bridge id)runDelegate range: NSMakeRange(0, 1)];
    [imageAttributedString addAttribute: LXDEmojiImageNameKey value: imageName range: NSMakeRange(0, 1)];
    [_content deleteCharactersInRange: emojiRange];
    [_content insertAttributedString: imageAttributedString atIndex: emojiRange.location];
    CFRelease(runDelegate);
}

/*!
 *  @brief 在绘制富文本之前构建富文本字符串
 */
- (void)constructAttributed
{
    _content = [[NSMutableAttributedString alloc] initWithString: _text attributes: self.textAttributes];
    /*!
     *  @brief 获取所有转换emoji表情的文本位置
     */
    for (NSString * emojiText in self.emojiTextMapper) {
        NSRange range = [_text rangeOfString: emojiText];
        if (range.location != NSNotFound) {
            [self insertEmojiAttributed: self.emojiTextMapper[emojiText] emojiRange: range];
        }
    }
    
    /*!
     *  @brief 获取所有转换超链接的文本位置
     */
    for (NSString * hyperlinkText in self.hyperlinkMapper) {
        NSRange range = [_text rangeOfString: hyperlinkText];
        if (range.location != NSNotFound) {
            [self.textTouchMapper setValue: self.hyperlinkMapper[hyperlinkText] forKey: NSStringFromRange(range)];
            [_content addAttributes: @{ NSForegroundColorAttributeName: [UIColor blueColor] } range: range];
            [_content addAttributes: @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) } range: range];
        }
    }
    
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
    [_content addAttributes: attributes range: NSMakeRange(0, _content.length)];
    CTFontRef font = CTFontCreateWithName((CFStringRef)[UIFont systemFontOfSize: 16].fontName, 16, NULL);
    [_content addAttributes: @{ (id)kCTFontAttributeName: (__bridge id)font } range: NSMakeRange(0, _content.length)];
    CFRelease(font);
    CFRelease(style);
}


#pragma mark - 绘制文本
- (void)drawRect: (CGRect)rect
{
    [self constructAttributed];
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
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_content);
    CGMutablePathRef paths = CGPathCreateMutable();
    CGPathAddRect(paths, NULL, self.bounds);
    _frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _content.length), paths, NULL);
    CTFrameDraw(_frame, ctx);        //绘制文字
    
    /*!
     *  @brief 获取所有行的坐标
     */
    CFArrayRef lines = CTFrameGetLines(_frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), lineOrigins);
    for (int idx = 0; idx < CFArrayGetCount(lines); idx++) {
        CGPoint origin = lineOrigins[idx];
        NSLog(@"第%d行起始坐标%@", idx, NSStringFromCGPoint(origin));
    }
    
    /*!
     *  @brief 遍历CTLine
     */
    CGFloat maxHeight = 0;
    for (int idx = 0; idx < CFArrayGetCount(lines); idx++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, idx);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
//        NSLog(@"上行距离%f --- 下行距离%f --- 左侧偏移%f", lineAscent, lineDescent, lineLeading);
        
        CGFloat lineHeight = 0;
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
            lineHeight = MAX(lineHeight, runRect.size.height);
            
            /*!
             *  @brief 绘制图片
             */
            NSString * imageName = attributes[LXDEmojiImageNameKey];
            if (imageName) {
                UIImage * image = [UIImage imageNamed: imageName];
                if (image) {
                    CGRect imageDrawRect;
                    CGFloat imageSize = ceil(runRect.size.height);
                    imageDrawRect.size = CGSizeMake(imageSize, imageSize);
                    imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                    imageDrawRect.origin.y = lineOrigin.y - lineDescent;
                    CGContextDrawImage(ctx, imageDrawRect, image.CGImage);
                    self.emojiTouchMapper[NSStringFromCGRect(imageDrawRect)] = imageName;
                    lineHeight = MAX(lineHeight, imageDrawRect.size.height);
                }
            }
        }
        maxHeight += lineHeight;
    }
    
    for (NSString * imageRect in self.emojiTouchMapper) {
        id value = self.emojiTouchMapper[imageRect];
        self.emojiTouchMapper[imageRect] = nil;
        
        CGRect rect = CGRectFromString(imageRect);
        rect.origin.y = maxHeight - rect.origin.y;
        self.emojiTouchMapper[NSStringFromCGRect(rect)] = value;
    }
    
    /*!
     *  @brief 释放变量
     */
    CGContextRestoreGState(ctx);
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
    
    if (line == NULL) { return; }
    
    touchPoint.x -= lineOrigin.x;
    CFIndex index = CTLineGetStringIndexForPosition(line, touchPoint);
    
    for (NSString * textRange in self.textTouchMapper) {
        NSRange range = NSRangeFromString(textRange);
        if (index >= range.location && index <= range.location + range.length) {
            if ([_delegate respondsToSelector: @selector(textView:didSelectedHyperlink:)]) {
                [_delegate textView: self didSelectedHyperlink: self.textTouchMapper[textRange]];
            }
            return;
        }
    }
    
    if (!_emojiUserInteractionEnabled) { return; }
    for (NSString * rectString in self.emojiTouchMapper) {
        CGRect textRect = CGRectFromString(rectString);
        if (CGRectContainsPoint(textRect, touchPoint)) {
            if ([_delegate respondsToSelector: @selector(textView:didSelectedEmoji:)]) {
                [_delegate textView: self didSelectedEmoji: self.emojiTouchMapper[rectString]];
            }
        }
    }
}


@end
