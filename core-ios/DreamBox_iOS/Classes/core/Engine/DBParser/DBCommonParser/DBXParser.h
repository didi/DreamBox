//
//  DBXParser.h
//  DreamBox-iOS
//
//  Created by didi on 2020/5/6.
//  Copyright © 2020 didi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBXViewModel.h"
#import "DBXView.h"


@class DBXTreeModel;

NS_ASSUME_NONNULL_BEGIN

@interface DBXParser : NSObject

+(DBXTreeModel *)parserDict:(NSDictionary *)dict;

+(NSDictionary *)parseOriginDict:(NSDictionary *)originDict withMap:(NSDictionary *)mapDict;
+(NSMutableDictionary *)recursiveParseOriginDict:(NSDictionary *)originDict withMap:(NSDictionary *)mapDict;

//模型到DBView
+ (DBXBaseView *)modelToView:(DBXViewModel *)model andPathId:(NSString *)pathId;

+ (NSString *)paserStr:(NSString *)str;

+ (void)circulationActionDict:(NSDictionary *)actionDict andPathId:(NSString *)pathId;

+ (id)getRealValueByPathId:(NSString *)pathId andKey:(NSString *)key;

+ (BOOL)isvalidAction:(NSString *)action;

+ (id)getMetaDictByPathId:(NSString *)pathId;

@end

NS_ASSUME_NONNULL_END
