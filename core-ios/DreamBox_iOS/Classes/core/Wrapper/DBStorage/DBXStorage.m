//
//  DBStorage.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/14.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBXStorage.h"
#import "DBXHelper.h"
@implementation DBXStorage

+ (void)setStorage:(NSString *)value forkey:(NSString *)key {
    
    if (![DBXValidJudge isValidString:value] || ![DBXValidJudge isValidString:key]) {
        return;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:value forKey:key];
    [ud synchronize];
}
+ (NSString *)getStorageBykey:(NSString *)key {
    
    if (![DBXValidJudge isValidString:key]) {
        return nil;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString * value = [ud valueForKey:key];
    return value;
}

@end
