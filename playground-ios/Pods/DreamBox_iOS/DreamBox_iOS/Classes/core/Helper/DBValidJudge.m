//
//  DBValidJudge.m
//  DreamBox-iOS
//
//  Created by didi on 2020/5/14.
//  Copyright © 2020 didi. All rights reserved.
//

#import "DBValidJudge.h"

@implementation DBValidJudge

/*
 是否是有效字符串
 */
+ (BOOL)isValidString:(NSString *)aString{
    if ([aString isKindOfClass:[NSString class]] && [aString length] > 0){
        return YES;
    }else{
        return NO;
    }
}

/*
 是否是有效NSArray
 */
+ (BOOL)isValidArray:(NSArray *)aArray{
    if ([aArray isKindOfClass:[NSArray class]]){
        return YES;
    }else{
        return NO;
    }
}

/*
 是否是有效NSDictionary
 */
+ (BOOL)isValidDictionary:(NSDictionary *)aDictionary{
    if ([aDictionary isKindOfClass:[NSDictionary class]]){
        return YES;
    }else{
        return NO;
    }
}

@end
