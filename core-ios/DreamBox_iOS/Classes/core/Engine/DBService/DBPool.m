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
@property(nonatomic ,strong) NSMutableDictionary *dbAllAccessKeyAndTidDict; // tid级别,存放注册过的accessKey&tid列表，给playGround&debugTool使用
@property(nonatomic ,assign) int autoTid; // 默认为0,生成时自增

@end

@implementation DBPool

+(instancetype)shareDBPool{
    static DBPool *dbPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbPool =  [[DBPool alloc] init];
        dbPool.dbAllAccessKeyAndTidDict = [NSMutableDictionary dictionary];
        dbPool.searchAccessDict = [NSMutableDictionary dictionary];
        dbPool.searchTidDict = [NSMutableDictionary dictionary];
        dbPool.dbExtPoolDict = [NSMutableDictionary dictionary];

        
        dbPool.dbGBPoolDict = [NSMutableDictionary dictionary];
        dbPool.dbMetaPoolDict = [NSMutableDictionary dictionary];
        dbPool.dbAliasPoolDict = [NSMutableDictionary dictionary];
        
        
        dbPool.dbViewMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        dbPool.autoTid = 0;
    });
    return dbPool;
}

#pragma mark - accessKey列表，accessKey - tid列表
- (void)setAllAccessKeyAndTidDict:(NSString *)accessKey andTid:(NSString *)tid {
    if (!tid || !accessKey) {
        return;
    }

    if ([[DBPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] && [[[DBPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [[[DBPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] mutableCopy];
        if(![array containsObject:tid]){
            [array addObject:tid];
            [[DBPool shareDBPool].dbAllAccessKeyAndTidDict db_setValue:array forKey:accessKey];
        }
    }else{
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:tid];
        [[DBPool shareDBPool].dbAllAccessKeyAndTidDict db_setValue:array forKey:accessKey];
    }
}

- (NSDictionary *)getAccessKeyAndTidDict {
    return self.dbAllAccessKeyAndTidDict;
}

- (void)removeAccessKeyAndTidDict:(NSString *)accessKey andTid:(NSString *)tid {
    if (!tid || !accessKey) {
        return;
    }
    
    if ([[DBPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] && [[[DBPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] isKindOfClass:[NSArray class]]){
        NSMutableArray *array = [[[DBPool shareDBPool].dbAllAccessKeyAndTidDict objectForKey:accessKey] mutableCopy];
        if(![array containsObject:tid]){
            [array removeObject:tid];
            if(array.count > 0){
                [[DBPool shareDBPool].dbAllAccessKeyAndTidDict db_setValue:array forKey:accessKey];
            } else {
                [[DBPool shareDBPool].dbAllAccessKeyAndTidDict removeObjectForKey:accessKey];
            }
        }
    }
}

#pragma mark - accessKey与pathId的对应关系，根据pathId索引accessKey
- (void)setAccessKey:(NSString *)object ToSearchAccessPoolWithPathId:(NSString *)pathId {
    if (!pathId || !object) {
        return;
    }

    if (![[DBPool shareDBPool] getAccessKeyWithPathId:pathId]) {
        [[DBPool shareDBPool].searchAccessDict db_setValue:object forKey:pathId];
    }
}

- (NSString *)getAccessKeyWithPathId:(NSString *)pathId {
    NSString *objc = [[DBPool shareDBPool].searchAccessDict db_objectForKey:pathId];
    return objc;
}

- (void)removeAccessKeyWithPathId:(NSString *)pathId {
    if([[DBPool shareDBPool].searchAccessDict db_objectForKey:pathId]){
        [[DBPool shareDBPool].searchAccessDict removeObjectForKey:pathId];
    }
}

#pragma mark - tid与pathId的对应关系，根据pathId索引tid
- (void)setTid:(NSString *)object ToSearchTidPoolWithPathId:(NSString *)pathId {
    if (!pathId || !object) {
        return;
    }
    
    if (![[DBPool shareDBPool] getTidWithPathId:pathId]) {
        [[DBPool shareDBPool].searchTidDict db_setValue:object forKey:pathId];
    }
}

- (NSString *)getTidWithPathId:(NSString *)pathId {
    NSString *objc = [[DBPool shareDBPool].searchTidDict db_objectForKey:pathId];
    return objc;
}

- (void)removeTidWithPathId:(NSString *)pathId {
    if([[DBPool shareDBPool].searchTidDict db_objectForKey:pathId]){
        [[DBPool shareDBPool].searchTidDict removeObjectForKey:pathId];
    }
}

#pragma mark - view与pathId的对应关系，根据pathId索引view
-(id)getDBViewWithPathId:(NSString *)pathId {
    id objc = [[DBPool shareDBPool].dbViewMapTable objectForKey:pathId];
    return objc;
}

-(void)setObject:(id)object toViewMapTableWithPathId:(NSString *)pathId {
    if (!pathId || !object) {
        return;
    }

    [[DBPool shareDBPool].dbViewMapTable setObject:object forKey:pathId];
}

- (id)getDBViewWithTid:(NSString *)tid andAccessKey:(NSString *)accessKey {
    NSString *pathTid = [accessKey stringByAppendingString:tid];
    id objc = [[DBPool shareDBPool].dbViewMapTable objectForKey:pathTid];
    return objc;
}


#pragma mark - metaData与pathId的对应关系，根据pathId索引metaData
-(void)setObject:(NSDictionary *)object ToDBMetaPoolWithPathId:(NSString *)pathId {
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

- (id)getObjectFromDBMetaPoolWithPathId:(NSString *)pathId {
    id objc = [[DBPool shareDBPool].dbMetaPoolDict db_objectForKey:pathId];
    return objc;
}

- (void)removeObjectFromMetaPoolWithPathId:(NSString *)pathId{
    if (!pathId) {
        return;
    }

    if ([[DBPool shareDBPool] getObjectFromDBMetaPoolWithPathId:pathId]) {
        [[DBPool shareDBPool].dbMetaPoolDict removeObjectForKey:pathId];
    }
}

#pragma mark - ext与pathId的对应关系，根据pathId索引metaData
- (void)setObject:(NSDictionary *)object ToDBExtPoolWithPathId:(NSString *)pathId {
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


- (id)getObjectFromDBExtPoolWithPathId:(NSString *)pathId {
    id objc = [[DBPool shareDBPool].dbExtPoolDict db_objectForKey:pathId];
    return objc;
}

- (void)removeObjectFromDBExtPoolWithPathId:(NSString *)pathId {
    if([[DBPool shareDBPool].dbExtPoolDict db_objectForKey:pathId]){
        [[DBPool shareDBPool].dbExtPoolDict removeObjectForKey:pathId];
    }
}


#pragma mark - alias与pathId的对应关系，根据pathId索引metaData
-(void)setObject:(NSDictionary *)object ToDBAliasPoolWithPathId:(NSString *)pathId {
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

- (id)getObjectFromAliasPoolWithPathId:(NSString *)pathId {
    id objc = [[DBPool shareDBPool].dbAliasPoolDict db_objectForKey:pathId];
    return objc;
}

- (void)removeObjectFromAliasPoolWithPathId:(NSString *)pathId {
    if([[DBPool shareDBPool].dbAliasPoolDict db_objectForKey:pathId]){
        [[DBPool shareDBPool].dbAliasPoolDict removeObjectForKey:pathId];
    }
}


#pragma mark - alias与pathId的对应关系，根据pathId索引metaData
- (void)setObject:(NSDictionary *)object ToDBOnEventDictWithPathId:(NSString *)pathId {
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


- (NSDictionary *)getOnEventDictWithPathId:(NSString *)pathId {
    NSDictionary *objc = [[DBPool shareDBPool].dbOnEventDict db_objectForKey:pathId];
    return objc;
}

- (void)removeOnEventDictWithPathId:(NSString *)pathId {
    if([[DBPool shareDBPool].dbOnEventDict db_objectForKey:pathId]){
        [[DBPool shareDBPool].dbOnEventDict removeObjectForKey:pathId];
    }
}

#pragma mark - alias与pathId的对应关系，根据pathId索引metaData
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

-(id)getObjectFromDBGlobalPoolWithPathId:(NSString *)pathId {
    id objc = [[DBPool shareDBPool].dbGBPoolDict db_objectForKey:pathId];
    return objc;
}

#pragma mark - 自增tid
-(NSString *)getAutoIncrementTid
{
    [DBPool shareDBPool].autoTid ++;
    NSString *autoTid = [NSString stringWithFormat:@"%d",[DBPool shareDBPool].autoTid];
    return autoTid;
}

@end
