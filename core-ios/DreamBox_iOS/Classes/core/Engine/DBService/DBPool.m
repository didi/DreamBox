//
//  DBPool.m
//  DreamBox_iOS
//
//  Created by didi on 2020/6/18.
//

#import "DBPool.h"
#import "NSDictionary+DBExtends.h"

@interface DBPool()

@property(nonatomic ,strong) NSMutableDictionary *dbGBPoolDict;// 全局 accessKey 需要暴露
@property(nonatomic ,strong) NSMutableDictionary *dbExtPoolDict;// tid级别 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *dbMetaPoolDict;// tid级别 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *dbAliasPoolDict;// tid级别 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *searchAccessDict; // 全局 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *searchTidDict; // 全局 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *dbOnEventDict; // tid级别 无需暴露
@property(nonatomic ,strong) NSMapTable *dbViewMapTable; // tid级别 无需暴露
@property(nonatomic ,strong) NSMutableDictionary *dbAllAccessKeyAndTidDict; // tid级别 无需暴露
@property(nonatomic ,assign) int autoTid; // 默认为0,生成时自增

@end

@implementation DBPool

+(instancetype)shareDBPool{
    static DBPool *dbPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbPool =  [[DBPool alloc] init];
        dbPool.dbGBPoolDict = [NSMutableDictionary dictionary];
        dbPool.dbExtPoolDict = [NSMutableDictionary dictionary];
        dbPool.dbMetaPoolDict = [NSMutableDictionary dictionary];
        dbPool.dbAliasPoolDict = [NSMutableDictionary dictionary];
        dbPool.searchAccessDict = [NSMutableDictionary dictionary];
        dbPool.searchTidDict = [NSMutableDictionary dictionary];
        dbPool.dbAllAccessKeyAndTidDict = [NSMutableDictionary dictionary];
        dbPool.dbViewMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        dbPool.autoTid = 0;
    });
    return dbPool;
}

-(id)getDataFromPoolWithPathId:(NSString *)pathId andKey:(nonnull NSString *)key{
    if ([self getObjectFromDBMetaPoolWithPathId:pathId] && [[self getObjectFromDBMetaPoolWithPathId:pathId] objectForKey:key]) {
        return [[self getObjectFromDBMetaPoolWithPathId:pathId] objectForKey:key];
    }
    
    if ([self getObjectFromDBExtPoolWithPathId:pathId] && [[self getObjectFromDBExtPoolWithPathId:pathId] objectForKey:key]) {
        return [[self getObjectFromDBExtPoolWithPathId:pathId] objectForKey:key];
    }
    
    if ([self getObjectFromDBGlobalPoolWithPathId:pathId] && [[self getObjectFromDBGlobalPoolWithPathId:pathId] objectForKey:key]) {
        return [[self getObjectFromDBGlobalPoolWithPathId:pathId] objectForKey:key];
    }

    return nil;
}

-(id)getObjectFromDBGlobalPoolWithPathId:(NSString *)pathId
{
    id objc = [[DBPool shareDBPool].dbGBPoolDict db_objectForKey:pathId];
    
    return objc;
}

-(id)getObjectFromDBExtPoolWithPathId:(NSString *)pathId
{
    id objc = [[DBPool shareDBPool].dbExtPoolDict db_objectForKey:pathId];
    
    return objc;
}

-(id)getObjectFromDBMetaPoolWithPathId:(NSString *)pathId
{
    id objc = [[DBPool shareDBPool].dbMetaPoolDict db_objectForKey:pathId];
    
    return objc;
}

-(id)getObjectFromAliasPoolWithPathId:(NSString *)pathId
{
    id objc = [[DBPool shareDBPool].dbAliasPoolDict db_objectForKey:pathId];
    
    return objc;
}

-(NSString *)getAccessKeyWithPathId:(NSString *)pathId
{
    NSString *objc = [[DBPool shareDBPool].searchAccessDict db_objectForKey:pathId];
    
    return objc;
}

-(NSString *)getTidWithPathId:(NSString *)pathId
{
    NSString *objc = [[DBPool shareDBPool].searchTidDict db_objectForKey:pathId];
    
    return objc;
}

-(NSDictionary *)getOnEventDictWithPathId:(NSString *)pathId
{
    NSDictionary *objc = [[DBPool shareDBPool].dbOnEventDict db_objectForKey:pathId];
    return objc;
}

-(id)getDBViewWithPathId:(NSString *)pathId andAccessKey:(NSString *)accessKey;
{
    NSString *pathTid = [accessKey stringByAppendingString:pathId];
    id objc = [[DBPool shareDBPool].dbViewMapTable objectForKey:pathTid];
    return objc;
}

-(id)getDBViewWithPathId:(NSString *)pathId{
    id objc = [[DBPool shareDBPool].dbViewMapTable objectForKey:pathId];
    return objc;
}

-(NSDictionary *)getAccessKeyAndTidDict
{
    
    return self.dbAllAccessKeyAndTidDict;;
    
}

-(void)setObject:(NSDictionary *)object ToDBMetaPoolWithPathId:(NSString *)pathId
{
    if (!pathId || !object) {
        return;
    }
        
    if ([[DBPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId]) {
        NSMutableDictionary *dict = [[DBPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId];
        [object enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [dict setValue:obj forKeyPath:key];
        }];
    }else{
        NSMutableDictionary *objectM = [object mutableDicDeepCopy];
        NSMutableDictionary *dictM = [NSMutableDictionary new];
        [objectM enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [dictM setValue:obj forKeyPath:key];
        }];
        [[DBPool shareDBPool].dbMetaPoolDict setObject:dictM forKey:pathId];
    }
}

-(void)setObject:(NSDictionary *)object ToDBExtPoolWithPathId:(NSString *)pathId
{
    if (!pathId || !object) {
        return;
    }
    
    if ([[DBPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId]) {
        NSMutableDictionary *dict = [[[DBPool shareDBPool] getObjectFromDBExtPoolWithPathId:pathId] mutableCopy];
        [dict addEntriesFromDictionary:object];
        [DBPool shareDBPool].dbExtPoolDict = [NSMutableDictionary dictionary];
        [[DBPool shareDBPool].dbExtPoolDict setObject:dict forKey:pathId];
    }else{
        [[DBPool shareDBPool].dbExtPoolDict setObject:object forKey:pathId];
    }
}

-(void)setObject:(NSDictionary *)object ToDBGlobalPoolWithPathId:(NSString *)pathId
{
    if (!pathId || !object) {
        return;
    }
    
    if ([[DBPool shareDBPool] getObjectFromDBGlobalPoolWithPathId:pathId]) {
        NSMutableDictionary *dict = [[[DBPool shareDBPool] getObjectFromDBGlobalPoolWithPathId:pathId] mutableCopy];
        [dict addEntriesFromDictionary:object];
        [DBPool shareDBPool].dbGBPoolDict = [NSMutableDictionary dictionary];
        [[DBPool shareDBPool].dbGBPoolDict setObject:dict forKey:pathId];
    }else{
        [[DBPool shareDBPool].dbGBPoolDict setObject:object forKey:pathId];
    }
}

-(void)setObject:(NSDictionary *)object ToDBAliasPoolWithPathId:(NSString *)pathId
{
    if (!pathId || !object) {
        return;
    }
    
    if ([[DBPool shareDBPool] getObjectFromAliasPoolWithPathId:pathId]) {
        NSMutableDictionary *dict = [[[DBPool shareDBPool] getObjectFromAliasPoolWithPathId:pathId] mutableCopy];
        [dict addEntriesFromDictionary:object];
        [DBPool shareDBPool].dbAliasPoolDict = [NSMutableDictionary dictionary];
        [[DBPool shareDBPool].dbAliasPoolDict setObject:dict forKey:pathId];
    }else{
        [[DBPool shareDBPool].dbAliasPoolDict setObject:object forKey:pathId];
    }
}

-(void)setAccessKey:(NSString *)object ToSearchAccessPoolWithPathId:(NSString *)pathId
{
    if (!pathId || !object) {
        return;
    }
    
    if (![[DBPool shareDBPool] getAccessKeyWithPathId:pathId]) {
        [[DBPool shareDBPool].searchAccessDict setObject:object forKey:pathId];
    }
}

-(void)setTid:(NSString *)object ToSearchTidPoolWithPathId:(NSString *)pathId
{
    if (!pathId || !object) {
        return;
    }
    
    if (![[DBPool shareDBPool] getTidWithPathId:pathId]) {
        [[DBPool shareDBPool].searchTidDict setObject:object forKey:pathId];
    }
}

-(void)setObject:(NSDictionary *)object ToDBOnEventDictWithPathId:(NSString *)pathId
{
    if (!pathId || !object) {
        return;
    }
        
    if ([[DBPool shareDBPool] getOnEventDictWithPathId:pathId]) {
        NSMutableDictionary *dict = [[[DBPool shareDBPool] getOnEventDictWithPathId:pathId] mutableCopy];
        [dict addEntriesFromDictionary:object];
        [DBPool shareDBPool].dbOnEventDict = [NSMutableDictionary dictionary];
        [[DBPool shareDBPool].dbOnEventDict setObject:dict forKey:pathId];
    }else{
        [[DBPool shareDBPool].dbOnEventDict setObject:object forKey:pathId];
    }
}



-(void)setObject:(id)object toViewMapTableWithPathId:(NSString *)pathId
{
    if (!pathId || !object) {
        return;
    }

    [[DBPool shareDBPool].dbViewMapTable setObject:object forKey:pathId];
}


-(void)setAllAccessKeyAndTidDict:(NSString *)accessKey andTid:(NSString *)tid
{
    if (!tid || !accessKey) {
        return;
    }

    if ([[DBPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] && [[[DBPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [[[DBPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] mutableCopy];
        if(![array containsObject:tid]){
            [array addObject:tid];
            [[DBPool shareDBPool].dbAllAccessKeyAndTidDict setObject:array forKey:accessKey];
        }
    }else{
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:tid];
        [[DBPool shareDBPool].dbAllAccessKeyAndTidDict setObject:array forKey:accessKey];
    }
}

-(NSString *)getAutoIncrementTid
{
    [DBPool shareDBPool].autoTid ++;
    NSString *autoTid = [NSString stringWithFormat:@"%d",[DBPool shareDBPool].autoTid];
    return autoTid;
}

-(void)removeObjectFromMetaPoolWithPathId:(NSString *)pathId{
    if (!pathId) {
        return;
    }

    if ([[DBPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId]) {
        [[DBPool shareDBPool].dbMetaPoolDict removeObjectForKey:pathId];
    }
}

@end
