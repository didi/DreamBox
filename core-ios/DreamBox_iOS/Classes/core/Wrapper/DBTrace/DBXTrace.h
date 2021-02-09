//
//  DBTrace.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXTrace : NSObject

+ (void)trace:(NSString *)key value:(NSDictionary *)value;

@end

NS_ASSUME_NONNULL_END
