//
//  DBToast.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/17.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXToast : NSObject

+ (void)showToast:(NSString *)str;
+ (void)showToast:(NSString *)str longTime:(BOOL)longTime; 

@end

NS_ASSUME_NONNULL_END
