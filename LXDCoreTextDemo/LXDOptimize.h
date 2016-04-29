//
//  LXDOptimize.h
//  LXDCoreTextDemo
//
//  Created by 林欣达 on 16/4/27.
//  Copyright © 2016年 CNPay. All rights reserved.
//

#ifndef LXDOptimize_h
#define LXDOptimize_h
#import <mach/mach_time.h>


#define LXDTimeCode(block) {\
    mach_timebase_info_data_t info;\
    mach_timebase_info(&info);\
    uint64_t start = mach_absolute_time();\
    block();\
    uint64_t end = mach_absolute_time();\
    uint64_t elapsed = end - start;\
    uint64_t nanos = elapsed * info.numer / info.denom;\
    NSLog(@"code in %@.m line %d cost time: %g", self.class, __LINE__, (CGFloat)nanos / NSEC_PER_SEC);\
}


#endif /* LXDOptimize_h */
