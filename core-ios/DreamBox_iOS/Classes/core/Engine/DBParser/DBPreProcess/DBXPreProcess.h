//
//  DBPreProcess.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/14.
//  Copyright © 2020 didi. All rights reserved.
//  预处理层，data->json，校验等逻辑

#import <Foundation/Foundation.h>
#import "DBXProcesssModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DBXPreProcess : NSObject

+ (DBXProcesssModel *)preProcess:(NSString *)data;

@end

NS_ASSUME_NONNULL_END
