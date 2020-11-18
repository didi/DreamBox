//
//  DBPool.h
//  DreamBox_iOS
//
//  Created by didi on 2020/6/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBPool : NSObject

+(instancetype)shareDBPool;

-(id)getObjectFromDBGlobalPoolWithPathId:(NSString *)pathId;

-(id)getObjectFromDBExtPoolWithPathId:(NSString *)pathId;

-(id)getObjectFromDBMetaPoolWithPathId:(NSString *)pathId;

-(id)getObjectFromAliasPoolWithPathId:(NSString *)pathId;

-(id)getDataFromPoolWithPathId:(NSString *)pathId andKey:(NSString *)key;


-(NSDictionary *)getOnEventDictWithPathId:(NSString *)pathId;

-(NSString *)getAccessKeyWithPathId:(NSString *)pathId;

-(NSString *)getTidWithPathId:(NSString *)pathId;

//根据tid获取dbview
-(id)getDBViewWithPathId:(NSString *)pathId andAccessKey:(NSString *)accessKey;

-(id)getDBViewWithPathId:(NSString *)pathId;
//获取所有 accessKey -> tidArray
-(NSDictionary *)getAccessKeyAndTidDict;

-(void)setObject:(NSDictionary *)object ToDBMetaPoolWithPathId:(NSString *)pathId;

-(void)setObject:(NSDictionary *)object ToDBExtPoolWithPathId:(NSString *)pathId;

-(void)setObject:(NSDictionary *)object ToDBGlobalPoolWithPathId:(NSString *)pathId;

-(void)setObject:(NSDictionary *)object ToDBAliasPoolWithPathId:(NSString *)pathId;

-(void)setAccessKey:(NSString *)object ToSearchAccessPoolWithPathId:(NSString *)pathId;

-(void)setTid:(NSString *)object ToSearchTidPoolWithPathId:(NSString *)pathId;

-(void)setObject:(NSDictionary *)object ToDBOnEventDictWithPathId:(NSString *)pathId;

-(void)setObject:(NSMapTable *)object toViewMapTableWithPathId:(NSString *)pathId;

-(void)setAllAccessKeyAndTidDict:(NSString *)accessKey andTid:(NSString *)tid;
// 获取生成的唯一tid
-(NSString *)getAutoIncrementTid;
// 删除pathid对应的meta数据
-(void)removeObjectFromMetaPoolWithPathId:(NSString *)pathId;
@end

NS_ASSUME_NONNULL_END
