//
//  DBStorage.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/14.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXStorage : NSObject

+ (void)setStorage:(NSString *)value forkey:(NSString *)key;
+ (NSString *)getStorageBykey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
