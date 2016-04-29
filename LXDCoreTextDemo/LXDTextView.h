//
//  LXDTextView.h
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/22.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LXDTextView;
@protocol LXDTextViewDelegate <NSObject>

@optional
- (void)textView: (LXDTextView *)textView didSelectedEmoji: (NSString *)emojiName;
- (void)textView: (LXDTextView *)textView didSelectedHyperlink: (NSString *)hyperlink;
- (void)textView: (LXDTextView *)textView didFinishTextRender: (NSInteger)reasonableLength;

@end


/*!
 *  @brief 超链接富文本/emoji表情控件
 */
@interface LXDTextView : UIView

/*!
 *  @brief emoji图片是否能够响应点击
 */
@property (nonatomic, assign) BOOL emojiUserInteractionEnabled;

/*!
 *  @brief 回调代理
 */
@property (nonatomic, weak) id<LXDTextViewDelegate> delegate;

/*!
 *  @brief 显示文本（所有的链接文本、图片名称都应该放到这里面）
 */
@property (nonatomic, copy) NSString * text;

/*!
 *  @brief 文本属性
 */
@property (nonatomic, strong) NSDictionary * textAttributes;

/*!
 *  @brief 超链接文本映射
 *  @abstract   key值为文本，value是地址链接。比如@{ @"百度": @"https://www.baidu.com" }
 */
@property (nonatomic, strong) NSDictionary * hyperlinkMapper;

/*!
 *  @brief emoji表情映射
 *  @abstract   key值为图片文本，value为图片名称。比如@{ @"[emoji11]": @"emoji11" }
 */
@property (nonatomic, strong) NSDictionary * emojiTextMapper;

@end
