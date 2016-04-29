//
//  LXDTextDataManager.h
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/28.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief 文本二进制数据管理者
 */
@interface LXDTextDataManager : NSObject

/*!
 *  @brief 传入书名来获取二进制
 *
 *  @param name  书名，默认txt格式
 */
+ (void)textDataWithName: (NSString *)name handler: (void(^)(NSData * data))handler;

/*!
 *  @brief 传入书名和类型来获取书籍二进制文件
 *
 *  @param name  书名
 *  @param type    文件类型
 */
+ (void)textDataWithName: (NSString *)name type: (NSString *)type handler: (void(^)(NSData * data))handler;

@end
