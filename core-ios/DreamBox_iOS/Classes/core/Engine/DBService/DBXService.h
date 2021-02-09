//
//  DBXService.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/7.
//  Copyright © 2020 didi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBXWrapper.h"
#import "DBXPool.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^DBSuccessBlock)(id data);
typedef void(^DBFailureBlock)(NSError *error);
typedef void(^DBCompletionBlock)(NSError *error,NSString *data);
@interface DBXService : NSObject

+(instancetype)shareDBService;

@property (nonatomic, strong) DBXPool *dbPool;//dbPool
@property (nonatomic, copy, readonly) NSString *uuid;

#pragma mark -
- (void)registerAccessKey:(NSString *)accessKey;
- (void)registerAccessKey:(NSString *)accessKey wrapper:(DBXWrapper *)wrapper;
// 开放一个注册公告pool池的方法, 根据ChannelKey不同还可以有多个子池
- (void)putPoolDataByAccessKey:(NSString *)accessKey dataKey:(NSString *)dataKey dataValue:(NSString *)dataValue;
- (NSString *)getValueByGlobalPoolKeyPath:(NSString *)keyPath;
// 全局设置
- (void)setConfig:(DBXWrapperConfigModel *)config accessKey:(NSString *)accessKey;


@end

NS_ASSUME_NONNULL_END
