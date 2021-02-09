//
//  DBTrace.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXTrace.h"

@implementation DBXTrace

+ (void)trace:(NSString *)key value:(NSDictionary *)value {
    
    // trace
    NSLog(@"trace : key:(%@) \n value:(%@)",key,value);
}

@end
