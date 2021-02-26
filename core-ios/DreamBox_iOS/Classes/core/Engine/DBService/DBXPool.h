//
//  DBPool.h
//  DreamBox_iOS
//
//  Created by didi on 2020/6/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBXPool : NSObject

@property (nonatomic, strong) NSRegularExpression *regex;

+(instancetype)shareDBPool;


//accessKey -> tidArray 缓存记录
- (void)setAllAccessKeyAndTidDict:(NSString *)accessKey andTid:(NSString *)tid;

- (NSDictionary *)getAccessKeyAndTidDict;

- (void)removeAccessKeyAndTidDict:(NSString *)accessKey andTid:(NSString *)tid;


//pathId -> accessKey 查询表
- (void)setAccessKey:(NSString *)object ToSearchAccessPoolWithPathId:(NSString *)pathId;

- (NSString *)getAccessKeyWithPathId:(NSString *)pathId;

- (void)removeAccessKeyWithPathId:(NSString *)pathId;


//pathId -> tid 查询表
- (void)setTid:(NSString *)object ToSearchTidPoolWithPathId:(NSString *)pathId;

- (NSString *)getTidWithPathId:(NSString *)pathId;

- (void)removeTidWithPathId:(NSString *)pathId;


//pathId -> DBView 查询表 
- (id)getDBViewWithPathId:(NSString *)pathId;

- (void)setObject:(id)object toViewMapTableWithPathId:(NSString *)pathId;

- (id)getDBViewWithTid:(NSString *)tid andAccessKey:(NSString *)accessKey;


//pathId -> meta 查询表
- (void)setObject:(NSDictionary *)object ToDBMetaPoolWithPathId:(NSString *)pathId;

- (id)getObjectFromDBMetaPoolWithPathId:(NSString *)pathId;

- (void)removeObjectFromMetaPoolWithPathId:(NSString *)pathId;


//pathId -> extData 查询表
- (id)getObjectFromDBExtPoolWithPathId:(NSString *)pathId;

- (void)setObject:(NSDictionary *)object ToDBExtPoolWithPathId:(NSString *)pathId;

- (void)removeObjectFromDBExtPoolWithPathId:(NSString *)pathId;


//pathId -> Alias 查询表
- (void)setObject:(NSDictionary *)object ToDBAliasPoolWithPathId:(NSString *)pathId;

- (id)getObjectFromAliasPoolWithPathId:(NSString *)pathId;

- (void)removeObjectFromAliasPoolWithPathId:(NSString *)pathId;


//pathId -> OnEvent 查询表
- (void)setObject:(NSDictionary *)object ToDBOnEventDictWithPathId:(NSString *)pathId;

- (NSDictionary *)getOnEventDictWithPathId:(NSString *)pathId;

- (void)removeOnEventDictWithPathId:(NSString *)pathId;


//pathId -> globalObj 查询表
- (void)setObject:(NSDictionary *)object ToDBGlobalPoolWithPathId:(NSString *)pathId;

- (id)getObjectFromDBGlobalPoolWithPathId:(NSString *)pathId;


//自增tid
-(NSString *)getAutoIncrementTid;

@end

NS_ASSUME_NONNULL_END
