//
//  DBStorage.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/14.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBStorage.h"
#import "DBHelper.h"
@implementation DBStorage

+ (void)setStorage:(NSString *)value forkey:(NSString *)key {
    
    if (![DBValidJudge isValidString:value] || ![DBValidJudge isValidString:key]) {
        return;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:value forKey:key];
    [ud synchronize];
}
+ (NSString *)getStorageBykey:(NSString *)key {
    
    if (![DBValidJudge isValidString:key]) {
        return nil;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString * value = [ud valueForKey:key];
    return value;
}

@end
