//
//  DBNav.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DBNavSuccessBlock)(void);
typedef void(^DBNavFailureBlock)(NSError *error);

@interface DBXNav : NSObject

+ (void)navigatorBySchema:(NSString *)schema;


@end

NS_ASSUME_NONNULL_END
