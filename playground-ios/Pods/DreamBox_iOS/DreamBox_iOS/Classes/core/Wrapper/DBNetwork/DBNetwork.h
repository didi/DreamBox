//
//  DBNetwork.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DBNetSuccessBlock)(id data);
typedef void(^DBNetFailureBlock)(NSError *error);

@interface DBNetwork : NSObject

+ (void)request:(NSString *)urlStr successBlock:(DBNetSuccessBlock)successBlock failureBlock:(DBNetFailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
