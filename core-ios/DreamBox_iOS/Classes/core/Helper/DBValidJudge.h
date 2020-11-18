//
//  DBValidJudge.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/14.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBValidJudge : NSObject

/*
 是否是有效字符串
 */
+ (BOOL)isValidString:(NSString *)aString;

/*
 是否是有效NSArray
 */
+ (BOOL)isValidArray:(NSArray *)aArray;

/*
 是否是有效NSDictionary
 */
+ (BOOL)isValidDictionary:(NSDictionary *)aDictionary;

@end

NS_ASSUME_NONNULL_END
