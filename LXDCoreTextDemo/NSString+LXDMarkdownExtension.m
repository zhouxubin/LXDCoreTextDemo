//
//  NSString+LXDMarkdownExtension.m
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/22.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import "NSString+LXDMarkdownExtension.h"

@implementation NSString (LXDMarkdownExtension)

- (BOOL)vaildateIfContainLink
{
    NSString * regExp = @".*\\[.*\\]\\(.*\\).*";
    return [self matchWithRegExp: regExp];
}

- (BOOL)matchWithRegExp: (NSString *)regExp
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regExp];
    return [predicate evaluateWithObject: self];
}

@end
