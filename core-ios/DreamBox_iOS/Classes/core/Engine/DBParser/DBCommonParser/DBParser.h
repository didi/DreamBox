//
//  DBParser.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBViewModel.h"
#import "DBView.h"
#import "DBRecyclePool.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBParser : NSObject

+(DBTreeModel *)parserDict:(NSDictionary *)dict;

+(NSDictionary *)parseOriginDict:(NSDictionary *)originDict withMap:(NSDictionary *)mapDict;
+(NSDictionary *)recursiveParseOriginDict:(NSDictionary *)originDict withMap:(NSDictionary *)mapDict;


+(BOOL)isHandleDependOn:(NSDictionary *)originDict andTid:(NSString *)tid;

//模型到DBView
+ (DBView *)modelToView:(DBViewModel *)model andPathId:(NSString *)pathId;

//nslayout
+ (void)layoutAllViews:(DBViewModel *)model andView:(DBView *)view andRelativeViewPool:(DBRecyclePool *)pool;

+ (NSString *)paserStr:(NSString *)str;

+ (void)circulationActionDict:(NSDictionary *)actionDict andPathId:(NSString *)pathId;

+ (id)getRealValueByPathId:(NSString *)pathId andKey:(NSString *)key;


+ (NSDictionary *)parseLogWithDict:(NSDictionary *)originDict andPathId:(NSString *)pathId;

+ (BOOL)isvalidAction:(NSString *)action;

+ (id)getMetaDictByPathId:(NSString *)pathId;
@end

NS_ASSUME_NONNULL_END
