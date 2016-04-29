//
//  LXDTextDataManager.m
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/28.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#import "LXDTextDataManager.h"

#ifndef MAX_CACHE_NUMBER
#define MAX_CACHE_NUMBER 1024 * 1024 * 2
#endif

static NSString * const kLXDTextDataAttributeName = @"kLXDTextDataAttributeName";
static NSString * const kLXDDataVisitTimeAttributeName = @"kLXDDataVisitTimeAttributeName";
static NSString * const kLXDCacheStorageMemoryAttributeName = @"kLXDCacheStorageMemoryAttributeName";

static inline dispatch_queue_t kSerialQueue()
{
    static dispatch_queue_t serialQueue;
    static dispatch_once_t queueOnce;
    dispatch_once(&queueOnce, ^{
        serialQueue = dispatch_queue_create("com.sindrilin.serial_queue", DISPATCH_QUEUE_SERIAL);
    });
    return serialQueue;
}

static inline NSMutableDictionary * kTextCacheStorage()
{
    static NSMutableDictionary * textStorage;
    static dispatch_once_t storageOnce;
    dispatch_once(&storageOnce, ^{
        textStorage = @{}.mutableCopy;
    });
    return textStorage;
}

static inline void kCacheData(NSData * data, NSString * name)
{
    NSMutableDictionary * textStorage = kTextCacheStorage();
    textStorage[name] = data;
    
    __block NSInteger cacheMemory = [textStorage[kLXDCacheStorageMemoryAttributeName] integerValue];
    cacheMemory += data.length;
    /*!
     *  @brief 缓存数据超过2M时清空访问量少的数据
     */
    dispatch_async(kSerialQueue(), ^{
        @autoreleasepool {
            NSInteger lessVisitTime = 1;
            while (cacheMemory > MAX_CACHE_NUMBER) {
                
                NSMutableArray * removeKeys = @[].mutableCopy;
                for (NSString * name in textStorage) {
                    NSDictionary * cacheData = textStorage[name];
                    if ([cacheData[kLXDDataVisitTimeAttributeName] integerValue] <= lessVisitTime) {
                        [removeKeys addObject: name];
                    }
                }
                [textStorage removeObjectsForKeys: removeKeys];
                lessVisitTime++;
                cacheMemory = [textStorage[kLXDCacheStorageMemoryAttributeName] integerValue];
            }
            textStorage[kLXDCacheStorageMemoryAttributeName] = @(cacheMemory);
        }
    });
    
}

static inline NSData * kDataFrom(NSString * name)
{
    NSMutableDictionary * textStorage = kTextCacheStorage();
    NSDictionary * cacheData = textStorage[name];
    if (cacheData) {
        NSInteger visitTime = [cacheData[kLXDDataVisitTimeAttributeName] integerValue];
        textStorage[name] = @{
                              kLXDTextDataAttributeName: cacheData[kLXDTextDataAttributeName],
                              kLXDDataVisitTimeAttributeName: @(++visitTime),
                              };
    }
    return cacheData[kLXDTextDataAttributeName];
}

static inline void kTextDataFrom(NSString * name, NSString * type, void(^handler)(NSData * textData))
{
    if (!handler) { return; }
    NSString * textName = [name stringByAppendingFormat: @".%@", type];
    NSData * textData = kDataFrom(textName);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!textData) {
            NSString * filePath = [[NSBundle mainBundle] pathForResource: name ofType: type];
            NSData * data = [NSData dataWithContentsOfFile: filePath options: NSDataReadingMappedIfSafe error: nil];
            kCacheData(data, textName);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(textData);
        });
    });
}


@implementation LXDTextDataManager

+ (void)textDataWithName: (NSString *)name handler: (void (^)(NSData *))handler
{
    [self textDataWithName: name type: @"txt" handler: handler];
}

+ (void)textDataWithName: (NSString *)name type: (NSString *)type handler: (void (^)(NSData *))handler
{
    kTextDataFrom(name, type, handler);
}


@end
