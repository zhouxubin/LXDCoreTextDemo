//
//  NSString+LXDMarkdownExtension.h
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/22.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief Markdown语法扩展
 */
@interface NSString (LXDMarkdownExtension)

/*!
 *  @brief 检测文本中是否包括链接
 *
 *  @return 检测结果
 */
- (BOOL)vaildateIfContainLink;

@end
